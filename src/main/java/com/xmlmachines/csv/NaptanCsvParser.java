package com.xmlmachines.csv;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;

public class NaptanCsvParser {

	// TODO - this should be in its own class
	static double latLow = 51.385575;
	static double latHigh = 51.667934;
	static double longLow = -0.34802;
	static double longHigh = 0.137295;
	static int counter = 0;

	public static void main(String[] args) throws IOException {

		FileInputStream fstream = new FileInputStream(
				"src/main/resources/csv/naptan/Stops.csv");

		FileOutputStream fos = new FileOutputStream(
				"src/main/resources/output/naptan/london-stops.csv");
		OutputStreamWriter osw = new OutputStreamWriter(fos, "UTF8");

		DataInputStream in = new DataInputStream(fstream);
		BufferedReader br = new BufferedReader(new InputStreamReader(in));
		String strLine;
		while ((strLine = br.readLine()) != null) {

			if (counter == 0) {
				osw.write(strLine.replace("\"", ""));
				osw.write("\n");
				counter++;
			} else {
				// System.out.println(strLine);
				String[] data = strLine.split(",");
				// System.out.println("long: " + data[29] + " Lat: " +
				// data[30]);

				double laD = Double.parseDouble(data[30]);
				double loD = Double.parseDouble(data[29]);

				if (laD > latLow && laD < latHigh && loD > longLow
						&& loD < longHigh) {
					osw.write(strLine.replace("\"", ""));
					osw.write("\n");

				}

			}
		}
		osw.flush();
		osw.close();
		fos.close();
		in.close();
	}
}