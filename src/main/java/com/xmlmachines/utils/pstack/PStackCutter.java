package com.xmlmachines.utils.pstack;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.text.MessageFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class PStackCutter {
	public static void main(String[] args) throws IOException {

		SimpleDateFormat sdf = new SimpleDateFormat(
				"EEE MMM d HH:mm:ss zzz yyyy");
		SimpleDateFormat sdf2 = new SimpleDateFormat("HHmmss");
		File dest = null;
		File src = new File("incoming/pstack1.log");
		StringBuilder sb = null;
		boolean filestart = true;
		boolean cutpoint = false;

		BufferedReader br = new BufferedReader(new FileReader(src));
		String line;
		while ((line = br.readLine()) != null) {
			Date d = null;
			try {
				d = sdf.parse(line);
				cutpoint = true;
			} catch (ParseException e) {
				if (sb == null) {
					sb = new StringBuilder();
				}
				if (!cutpoint) {
					sb.append("\n");
				}
				sb.append(line);
				cutpoint = false;
			}

			if (cutpoint) {
				if (filestart == true) {
					String suffix = sdf2.format(d);
					System.out.println(MessageFormat.format(
							"Writing: pstack.{0}", suffix));
					dest = new File("incoming/pstack." + suffix);
					filestart = false;
				}
				if (sb != null) {
					FileOutputStream fos = new FileOutputStream(dest);
					OutputStreamWriter osw = new OutputStreamWriter(fos, "UTF8");
					osw.write(sb.toString());
					osw.flush();
				}
				if (filestart == false) {
					String suffix = sdf2.format(d);
					System.out.println(MessageFormat.format(
							"Writing: pstack.{0}", suffix));
					dest = new File("incoming/pstack." + suffix);
				}
				sb = null;
			}
		}
	}
}
