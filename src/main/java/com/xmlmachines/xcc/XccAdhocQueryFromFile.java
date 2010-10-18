package com.xmlmachines.xcc;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.Charset;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.marklogic.xcc.ContentSource;
import com.marklogic.xcc.ContentSourceFactory;
import com.marklogic.xcc.Request;
import com.marklogic.xcc.ResultSequence;
import com.marklogic.xcc.Session;
import com.marklogic.xcc.exceptions.RequestException;
import com.marklogic.xcc.exceptions.XccConfigException;

public class XccAdhocQueryFromFile {

	public static void main(String[] args) {

		Log LOG = LogFactory.getLog(XccAdhocQueryFromFile.class);

		try {
			URI uri = new URI("xcc://admin:admin@localhost:8003/nyt");
			ContentSource contentSource = ContentSourceFactory
					.newContentSource(uri);
			Session session = contentSource.newSession();
			Request request = session
					.newAdhocQuery(readFile("src/main/resources/modules/example/external-xcc-example.xqy"));

			request.setNewIntegerVariable("START", 1);
			request.setNewIntegerVariable("END", 10);

			ResultSequence rs = session.submitRequest(request);

			LOG.info(rs.asString());
			session.close();
		} catch (URISyntaxException e) {
			LOG.error(e);
		} catch (XccConfigException e) {
			LOG.error(e);
		} catch (IOException e) {
			LOG.error(e);
		} catch (RequestException e) {
			LOG.error(e);
		}
	}

	private static String readFile(String path) throws IOException {
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