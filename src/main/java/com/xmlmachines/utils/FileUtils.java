package com.xmlmachines.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.Charset;

/**
 * Static helper methods for aiding unit testing
 * 
 * @author ableasdale
 * 
 */

public class FileUtils {

	/**
	 * Takes a file path (as represented by a String) and returns a UTF-8
	 * decoded String containing the content of the file. Useful for pulling
	 * text content into AdHoc queries.
	 * 
	 * @param path
	 * @return
	 * @throws IOException
	 */
	public static String readFile(String path) throws IOException {
		FileInputStream stream = new FileInputStream(new File(path));
		try {
			FileChannel fc = stream.getChannel();
			MappedByteBuffer bb = fc.map(FileChannel.MapMode.READ_ONLY, 0,
					fc.size());
			return Charset.forName("UTF-8").decode(bb).toString();
		} finally {
			stream.close();
		}
	}
}
