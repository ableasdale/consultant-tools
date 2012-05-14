package com.xmlmachines.utils.pstack;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.regex.Pattern;

public class PStackManager {

	static boolean isInteresting = false;
	static Map<String, Integer> totals = new HashMap<String, Integer>();
	static List<String> numThreads = new ArrayList<String>();
	static List<String> interesting = new ArrayList<String>();

	public static void main(String[] args) throws IOException {
		File inputDir = new File("incoming");
		File[] filesInInputDir = inputDir.listFiles();
		for (File f : filesInInputDir) {
			// if ((f.getName()).endsWith(".txt")) {
			System.out
					.println((MessageFormat.format("File: {0}", f.getName())));
			processFile(f);
			fileSummary();
			// }
		}
	}

	private static void fileSummary() {
		System.out.println(MessageFormat.format("Threads: {0}\n",
				numThreads.size()));

		List<Map.Entry<String, Integer>> resultList = extractAndSort(totals);

		for (Object e : resultList) {
			System.out.println(MessageFormat.format("{0}: {1}",
					((Entry<?, ?>) e).getKey(), ((Entry<?, ?>) e).getValue()));
		}

		if (interesting.size() > 0) {
			System.out.println("\nInteresting Threads:\n");
			for (String s : interesting) {
				System.out.println(s);
			}
		}
		totals.clear();
		numThreads.clear();
		interesting.clear();
		System.out.println("\n=============================\n");
	}

	private static void processFile(File f) throws IOException {
		BufferedReader br = new BufferedReader(new FileReader(f));
		String line;
		while ((line = br.readLine()) != null) {
			analyseLine(line);
		}
	}

	private static List<Map.Entry<String, Integer>> extractAndSort(
			Map<String, Integer> m) {
		List<Map.Entry<String, Integer>> resultList = new LinkedList<Map.Entry<String, Integer>>(
				m.entrySet());

		Collections.sort(resultList, new Comparator<Object>() {

			public int compare(Object o1, Object o2) {
				// Switch o2 and o1 to order from lowest to highest
				return ((Comparable<Object>) ((Map.Entry<?, ?>) (o2))
						.getValue()).compareTo(((Map.Entry<?, ?>) (o1))
						.getValue());
			}
		});
		return resultList;
	}

	private static void analyseLine(String line) {
		if (line.startsWith("Thread")) {
			numThreads.add(line);
		} else {
			processTraceData(line);
		}
	}

	private static boolean isStackInteresting(String result) {
		if ("sem_wait".equals(result) || "poll".equals(result)
				|| "accept".equals(result) || "nanosleep".equals(result)) {
			return false;
		} else {
			isInteresting = true;
			return true;
		}
	}

	private static void processTraceData(String line) {
		if (isInteresting == true && line.startsWith("#6")) {
			addLineToStack(line);
			interesting.add("------------");
			isInteresting = false;
		}
		if (isInteresting == true) {
			addLineToStack(line);
		}
		if (line.startsWith("#0")) {
			String pattern = "[\\s]+";
			Pattern splitter = Pattern.compile(pattern);
			String[] result = splitter.split(line);
			int tot = 0;
			if (totals.containsKey(result[3])) {
				tot = totals.get(result[3]);
			}
			totals.put(result[3], tot + 1);
			if (isStackInteresting(result[3])) {
				addLineToStack(line);
			}
		}
	}

	private static void addLineToStack(String line) {
		interesting.add(line);
	}
}
