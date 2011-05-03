package com.xmlmachines.xcc;

import java.io.File;
import java.net.URI;
import java.text.MessageFormat;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.marklogic.xcc.Content;
import com.marklogic.xcc.ContentCreateOptions;
import com.marklogic.xcc.ContentFactory;
import com.marklogic.xcc.ContentSource;
import com.marklogic.xcc.ContentSourceFactory;
import com.marklogic.xcc.Session;

public class XccBinaryUpload {

	private static final String XCC_URI = "xcc://admin:admin@localhost:9000";
	private static final String PATHNAME = "/path/to/folder";

	private static Log LOG = LogFactory.getLog(XccStreamedSession.class);

	public static void main(String[] args) {
		Session session = null;
		try {
			URI uri = new URI(XCC_URI);
			ContentSource contentSource = ContentSourceFactory
					.newContentSource(uri);
			session = contentSource.newSession();
			long t = System.currentTimeMillis();

			File dir = new File(PATHNAME);
			File[] files = dir.listFiles();
			for (File f : files) {
				Content c = ContentFactory.newContent(f.getName(), f,
						ContentCreateOptions.newBinaryInstance());
				LOG.info(MessageFormat.format("Inserting {0}", f.getName()));
				session.insertContent(c);
			}
			System.out.println(MessageFormat.format("Upload took(sec) : {0}",
					(System.currentTimeMillis() - t) / 1000));
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			session.close();
		}
	}
}