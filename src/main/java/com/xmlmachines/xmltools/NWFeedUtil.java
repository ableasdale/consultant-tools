package com.xmlmachines.xmltools;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import nu.xom.Builder;
import nu.xom.Document;
import nu.xom.Element;
import nu.xom.Node;
import nu.xom.Nodes;
import nu.xom.ParsingException;
import nu.xom.ValidityException;
import nux.xom.xquery.XQueryUtil;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.UniformInterfaceException;
import com.sun.jersey.api.client.WebResource;

public class NWFeedUtil {

	public static void main(String[] args) {
		Log LOG = LogFactory.getLog(NWFeedUtil.class);
		List<String> pages = new ArrayList<String>();

		Builder b = new Builder();
		try {

			Document doc = b
					.build("http://feeds.newsweek.com/newsweek/TopNews");

			Nodes nodes = XQueryUtil
					.xquery(doc,
							"declare namespace atom = \"http://www.w3.org/2005/Atom\"; /atom:feed/atom:entry/atom:id");

			for (int i = 0; i < nodes.size(); i++) {
				StringBuilder uri = new StringBuilder();
				uri.append("http://www.newsweek.com")
						.append(nodes.get(i).getValue().substring(17))
						.append(".xml");
				LOG.info("[URI]: " + uri.toString());
				/**
				 * Get the page
				 */
				Client client = Client.create();
				WebResource webResource = client.resource(uri.toString());
				pages.add(webResource.get(String.class));
			}
			System.out.println(nodes.size() + " nodes returned");

		} catch (ValidityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (UniformInterfaceException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ParsingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	/**
	 * Not used - but another way to manually traverse a doc using XOM
	 * 
	 * @param element
	 */
	public static void traverseDocument(Element element) {
		// Now loop through child nodes
		for (int i = 0; i < element.getChildCount(); i++) {
			Node node = element.getChild(i);

			if (node instanceof Element
					&& ((Element) node).getLocalName().equals("entry")) {

				for (int j = 0; j < node.getChildCount(); j++) {
					Node node2 = node.getChild(j);

					if (node2 instanceof Element
							&& ((Element) node2).getLocalName().equals("id")) {
						// System.out.println("[E]: " + node2.toString());
						System.out.println(node2.getValue());

						// WebResource webResource = client
						// .resource("http://feeds.newsweek.com/newsweek/TopNews");
						// .resource("http://blog.msbbc.co.uk/feeds/posts/default");
						// System.out.println(webResource.get(String.class));
					}

				}

			}
		}
	}
}
