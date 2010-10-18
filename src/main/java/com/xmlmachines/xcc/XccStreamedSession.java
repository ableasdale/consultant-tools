package com.xmlmachines.xcc;

import java.net.URI;
import java.net.URISyntaxException;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import org.apache.commons.configuration.ConfigurationException;
import org.apache.commons.configuration.XMLConfiguration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.marklogic.xcc.ContentSource;
import com.marklogic.xcc.ContentSourceFactory;
import com.marklogic.xcc.Request;
import com.marklogic.xcc.RequestOptions;
import com.marklogic.xcc.ResultSequence;
import com.marklogic.xcc.Session;
import com.marklogic.xcc.exceptions.RequestException;
import com.marklogic.xcc.exceptions.XccConfigException;

/**
 * A standalone example of how a large result set can be "streamed" to the
 * client
 * 
 * @author ableasdale
 * 
 */
public class XccStreamedSession {

	public static void main(String[] args) {

		Log LOG = LogFactory.getLog(XccStreamedSession.class);
		LOG.info(MessageFormat
				.format("Starting Application on {0}", new Date()));

		List<String> xmlStringList = new ArrayList<String>();

		try {
			XMLConfiguration config = new XMLConfiguration("xml/config/xcc.xml");

			List<String> servers = (Arrays.asList(config
					.getStringArray("uris.uri")));
			URI uri = new URI(servers.get(0));
			ContentSource contentSource = ContentSourceFactory
					.newContentSource(uri);
			Session s = contentSource.newSession();
			// set RequestOptions to put xcc/j into streaming mode
			RequestOptions ro = s.getDefaultRequestOptions();
			ro.setCacheResult(false);
			s.setDefaultRequestOptions(ro);
			Request r = s.newAdhocQuery("doc()");
			ResultSequence rs = s.submitRequest(r);

			while (rs.hasNext()) {
				xmlStringList.add(rs.next().asString());
			}
			s.close();
			LOG.info(MessageFormat.format("Received {0} records",
					xmlStringList.size()));

		} catch (URISyntaxException e) {
			LOG.error(e);
		} catch (RequestException e) {
			LOG.error(e);
		} catch (XccConfigException e) {
			LOG.error(e);
		} catch (ConfigurationException e) {
			LOG.error(e);
		}
	}
}