package com.xmlmachines.marklogic.permissions;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.text.MessageFormat;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.marklogic.xcc.ContentSource;
import com.marklogic.xcc.ContentSourceFactory;
import com.marklogic.xcc.Request;
import com.marklogic.xcc.ResultSequence;
import com.marklogic.xcc.Session;
import com.marklogic.xcc.exceptions.RequestException;
import com.marklogic.xcc.exceptions.XccConfigException;
import com.xmlmachines.utils.Utils;

/**
 * static String values for [re]configuring the Unit tests.
 * 
 * @author ableasdale
 * 
 */
public class TestHelper {

	private static Log LOG = LogFactory.getLog("TestHelper");
	// TODO - refactor - external configuration?
	public static String XCC_FULL_ACCESS_USER_LOCALHOST_8020 = "xcc://full-user:password@localhost:8020";
	public static String XCC_EXECUTE_READ_USER_LOCALHOST_8020 = "xcc://execute-read-user:password@localhost:8020";

	public static String XCC_NOPERMS_USER_NOPERMS_PASS_LOCALHOST_8020 = "xcc://noperms_user:noperms_pass@localhost:8020";
	public static String XCC_ADMIN_ADMIN_LOCALHOST_8020 = "xcc://admin:admin@localhost:8020";

	public static String SIMPLE_EVAL_QUERY = "xdmp:eval(\"1+1\")";

	public static String XDMP_DOC_ESTIMATE_QUERY = "xdmp:estimate(doc())";
	public static String COLLECTION_ESTIMATE_QUERY = "xdmp:estimate(collection(\"latest\"))";

	public static String FIRST_DOC_IN_DB_QUERY = "doc()[1]";
	public static String FIRST_DOC_IN_DB_PERMISSIONS_QUERY = "xdmp:document-get-permissions(xdmp:node-uri(doc()[1]))";
	public static String FIRST_DOC_IN_COLLECTION_QUERY = "collection(\"latest\")[1]";

	public static String DOC_INSERT_QUERY = "xdmp:document-insert(\"test-insert.xml\", <test>ok</test>)";
	public static String INSERTED_DOC_QUERY = "doc(\"test-insert.xml\")";
	public static String INSERTED_DOC_PROPERTIES = "element properties {xdmp:document-get-permissions(\"test-insert.xml\")}";
	public static String INSERTED_DOC_UPDATE_QUERY = "xdmp:node-replace(doc(\"test-insert.xml\")/test, <now>updated</now>)";
	public static String INSERTED_DOC_DELETION_QUERY = "xdmp:document-delete(\"test-insert.xml\")";

	public static String NODE_REPLACE_QUERY = "xdmp:node-replace(doc()[1]/content, <deleted>gone</deleted>)";
	public static String DOC_DELETE_QUERY = "xdmp:document-delete(xdmp:node-uri(doc()[1]))";

	public static String DOC_ADD_TO_NEW_COLLECTION_QUERY = "xdmp:document-add-collections(xdmp:node-uri(doc()[1]), \"thisshouldfail\")";
	public static String CLEAR_DB_QUERY = "for $doc in doc() return xdmp:document-delete(xdmp:node-uri($doc))";

	private static String ADD_RO_PERMISSIONS_TO_FIRST_DOC = "xdmp:document-set-permissions(xdmp:node-uri(doc()[1]), xdmp:permission(\"execute-read-role\", \"read\"))";
	private static String ADD_RO_PERMISSIONS_TO_REMAINING_DOCS = "for $doc in doc() return xdmp:document-set-permissions(xdmp:node-uri($doc), xdmp:permission(\"execute-read-role\", \"read\"))";

	public static String INSERT_TEST_DATA_QUERY_FILE_PATH = "src/test/resources/xqy/insert-test-data.xqy";

	/*
	 * Helper Methods for Unit tests
	 */

	public static void addOneHundredDocsToDbAsAdmin(String testUriName) {
		LOG.debug("Adding One Hundred Docs to the Database as Admin");
		Session s = null;
		try {
			ContentSource cs = ContentSourceFactory.newContentSource(new URI(
					XCC_ADMIN_ADMIN_LOCALHOST_8020));
			s = cs.newSession();
			Request r = s.newAdhocQuery(TestHelper.XDMP_DOC_ESTIMATE_QUERY);
			ResultSequence rs = s.submitRequest(r);
			long start = Integer.parseInt(rs.asString());
			LOG.debug(MessageFormat.format(
					"Got {0} Documents in the DB before adding new items.",
					start));

			// now add 100 docs
			try {
				r = s.newAdhocQuery(Utils
						.readFile(TestHelper.INSERT_TEST_DATA_QUERY_FILE_PATH));
				r.setNewStringVariable("TEST-URI-NAME", testUriName);
				s.submitRequest(r);
			} catch (IOException e) {
				LOG.error(e);
			}

			r = s.newAdhocQuery(TestHelper.XDMP_DOC_ESTIMATE_QUERY);
			rs = s.submitRequest(r);
			long end = Integer.parseInt(rs.asString());
			LOG.debug(MessageFormat.format(
					"Got {0} Documents in the DB after adding new items.", end));

		} catch (XccConfigException e) {
			LOG.error(e);
		} catch (URISyntaxException e) {
			LOG.error(e);
		} catch (RequestException e) {
			LOG.error(e);
		} finally {
			s.close();
		}
	}

	public static void executeAdHocQueryAsAdmin(String adhocQuery) {
		Session s = null;
		ContentSource cs;
		try {
			cs = ContentSourceFactory.newContentSource(new URI(
					XCC_ADMIN_ADMIN_LOCALHOST_8020));
			s = cs.newSession();
			Request r = s.newAdhocQuery(adhocQuery);
			s.submitRequest(r);
		} catch (XccConfigException e) {
			LOG.error(e);
		} catch (URISyntaxException e) {
			LOG.error(e);
		} catch (RequestException e) {
			LOG.error(e);
		} finally {
			s.close();
		}
	}

	public static void addReadPermissionsToFirstDocAsAdmin() {
		executeAdHocQueryAsAdmin(TestHelper.ADD_RO_PERMISSIONS_TO_FIRST_DOC);
	}

	public static void addReadPermissionsToRemainingDocsAsAdmin() {
		executeAdHocQueryAsAdmin(TestHelper.ADD_RO_PERMISSIONS_TO_REMAINING_DOCS);
	}
}
