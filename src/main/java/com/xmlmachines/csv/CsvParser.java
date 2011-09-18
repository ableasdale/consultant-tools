package com.xmlmachines.csv;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;

public class CsvParser {

	/**
	 * Grabs all London postcodes from csv available here:
	 * http://www.doogal.co.uk/UKPostcodesCSV.php ... and saves a new (smaller)
	 * csv file
	 * 
	 * @param args
	 */

	public static void main(String[] args) {
		createCsv("w", "[W]");
		createCsv("wc", "[W][C]");
		createCsv("e", "[E]");
		createCsv("ec", "[E][C]");
		createCsv("n", "[N]");
		createCsv("s", "[S]");
		createCsv("nw", "[N][W]");
		createCsv("sw", "[S][W]");
		createCsv("se", "[S][E]");
		System.out.println("All done.");
	}

	public static void createCsv(String name, String pattern) {
		// System.out.println(isLondonPostcode("E11 doo doo doo"));// blah blah
		// blah"));

		try {
			int counter = 0;
			// Open the file that is the first
			// command line parameter
			// FileInputStream fstream = new
			FileInputStream fstream = new FileInputStream(
					"src/main/resources/csv/postcodes.csv");
			FileOutputStream fos = new FileOutputStream(
					"src/main/resources/output/london-postcodes-" + name
							+ ".csv");
			OutputStreamWriter osw = new OutputStreamWriter(fos, "UTF8");
			// Get the object of DataInputStream
			DataInputStream in = new DataInputStream(fstream);
			BufferedReader br = new BufferedReader(new InputStreamReader(in));
			String strLine;
			// Read File Line By Line
			while ((strLine = br.readLine()) != null) {
				// get the first line
				if (counter == 0) {
					osw.write(strLine);
					osw.write("\n");
					counter += 1;
				}
				if (isLondonPostcode(strLine, pattern)) {
					osw.write(strLine);
					osw.write("\n");
				}
			}
			// Close the input stream
			osw.flush();
			osw.close();
			fos.close();
			in.close();
		} catch (Exception e) {// Catch exception if any
			System.err.println("Error: " + e.getMessage());
		}
		System.out.println("Processed.");
	}

	public static Boolean isLondonPostcode(String line, String pCode) {
		// return [E|W|N|S]
		// line.matches("([W][C]|[E][C]|[N][W]|[S][W]|[S][E][0-9]{1,2}).*"); //
		// |[E]|[N]|[W]|[S]|EC|NW|SW|SE|E|W|N|S
		return line.matches("(" + pCode + "[0-9]{1,2}).*"); // |[E]|[N]|[W]|[S]|EC|NW|SW|SE|E|W|N|S
		// return true;
	}
}