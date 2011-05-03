package com.xmlmachines.utils;

public class TextUtil {

	private static String CORNER_CHAR = "+";
	private static String HORIZONTAL_DIVIDER = "=";
	private static String VERTICAL_DIVIDER = "|";
	private static String SEPARATOR = " ";
	private static String LINE_BREAK = "\n";

	/**
	 * Takes a String of text (separated with line breaks) and borders the text
	 * to make it easier to see in the Console output. The second argument is
	 * for adding a divider under the heading and the interval for the number of
	 * lines to appear before (above) the divider
	 * 
	 * @param text
	 * @param headDivider
	 * @return
	 */
	public static String boxText(String text, int headDivider) {
		String[] strArr = text.split("\n");
		int maxLnWidth = calculateMaxLineWidth(strArr);
		StringBuilder sb = new StringBuilder();
		sb = generateHorizontalDivider(sb, maxLnWidth);
		sb = formatTextLines(sb, maxLnWidth, strArr, headDivider);
		sb = generateHorizontalDivider(sb, maxLnWidth);
		return sb.toString();
	}

	/**
	 * Formats all lines in a given String of text for console logging
	 * 
	 * @param sb
	 * @param maxLnWidth
	 * @param strArr
	 * @param headDivider
	 * @return
	 */
	private static StringBuilder formatTextLines(StringBuilder sb,
			int maxLnWidth, String[] strArr, int headDivider) {
		for (int i = 0; i < strArr.length; i++) {
			if (i == headDivider) {
				sb = generateHorizontalDivider(sb, maxLnWidth);
			}
			sb.append(VERTICAL_DIVIDER).append(SEPARATOR).append(strArr[i]);
			for (int j = strArr[i].length(); j < maxLnWidth; j++) {
				sb.append(SEPARATOR);
			}
			sb.append(SEPARATOR).append(VERTICAL_DIVIDER).append(LINE_BREAK);
		}
		return sb;
	}

	/**
	 * Creates an horizontal divider for the text box.
	 * 
	 * @param sb
	 * @param maxLnWidth
	 * @return
	 */
	private static StringBuilder generateHorizontalDivider(StringBuilder sb,
			int maxLnWidth) {
		sb.append(CORNER_CHAR);
		for (int i = 1; i <= (maxLnWidth + SEPARATOR.length() * 2); i++) {
			sb.append(HORIZONTAL_DIVIDER);
		}
		sb.append(CORNER_CHAR);
		sb.append(LINE_BREAK);
		return sb;
	}

	/**
	 * Takes a long String containing multiple lines and returns the maximum
	 * width for the longest line.
	 * 
	 * @param strArr
	 * @return
	 */
	private static int calculateMaxLineWidth(String[] strArr) {
		int maxWidth = 0;
		for (String ln : strArr) {
			if (ln.length() > maxWidth) {
				maxWidth = ln.length();
			}
		}
		return maxWidth;
	}
}
