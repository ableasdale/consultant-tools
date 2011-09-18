package com.xmlmachines.csv;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;

public class LatLongLondonPostcodeBoundaries {

	static double latLow = 60;
	static double latHigh;
	static double longLow;
	static double longHigh = -60;
	static int counter = 0;

	static String folderPath = "src/main/resources/output";

	/**
	 * [LONDON] Lowest Lat: 51.385575 Highest Lat: 51.667934 Lowest Long:
	 * -0.34802 Highest Long: 0.137295
	 * 
	 * Correct to postcode; NOT M25 boundary or London boroughs.
	 * 
	 * @param args
	 */
	public static void main(String[] args) {
		File dir = new File(folderPath);
		String[] children = dir.list();
		for (int i = 0; i < children.length; i++) {
			processFile(folderPath + "/" + children[i]);
			// reset counter
			counter = 0;
		}
		// processFile("src/main/resources/csv/postcodes.csv");
	}

	private static void processFile(String fileName) {
		System.out.println("******************************************");
		System.out.println("Processing " + fileName);
		System.out.println("******************************************");
		try {
			FileInputStream fstream = new FileInputStream(fileName);
			DataInputStream in = new DataInputStream(fstream);
			BufferedReader br = new BufferedReader(new InputStreamReader(in));
			String strLine;
			while ((strLine = br.readLine()) != null) {
				if (counter == 0) {
					// DO nothing - first line
					counter++;
				} else {
					boolean changed = false;
					// System.out.println(strLine);
					String[] items = strLine.split(",");

					double laD = Double.parseDouble(items[1]);
					double loD = Double.parseDouble(items[2]);

					if (laD < latLow) {
						System.out.println("NEW LOWEST LAT");
						latLow = laD;
						changed = true;
					}

					if (laD > latHigh) {
						System.out.println("NEW HIGHEST LAT");
						latHigh = laD;
						changed = true;
					}

					if (loD < longLow) {
						System.out.println("NEW LOWEST LONG");
						longLow = loD;
						changed = true;
					}
					if (loD > longHigh) {
						System.out.println("NEW HIGHEST LONG");
						longHigh = loD;
						changed = true;
					}
					if (changed == true) {
						System.out.println("[LONDON] Lowest Lat: " + latLow
								+ " Highest Lat: " + latHigh + " Lowest Long: "
								+ longLow + " Highest Long: " + longHigh);
						System.out.println("[CSV] Lat: " + items[1]);
						System.out.println("[CSV] Long: " + items[2]);
						System.out.println("Line: " + strLine);
					}
					// System.out.println("Lat: " + items[1]);
					// System.out.println("Long: " + items[2]);
					changed = false;
				}
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
