package com.xmlmachines.marklogic.permissions;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.net.URI;
import java.net.URISyntaxException;
import java.text.MessageFormat;

import junit.framework.Assert;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.custommonkey.xmlunit.XMLAssert;
import org.custommonkey.xmlunit.XMLUnit;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TestName;
import org.w3c.dom.Document;

import com.marklogic.xcc.ContentSource;
import com.marklogic.xcc.ContentSourceFactory;
import com.marklogic.xcc.Request;
import com.marklogic.xcc.ResultSequence;
import com.marklogic.xcc.Session;
import com.marklogic.xcc.exceptions.RequestException;
import com.marklogic.xcc.exceptions.XQueryException;
import com.marklogic.xcc.exceptions.XccConfigException;
import com.xmlmachines.utils.Utils;

/**
 * Testing granular (READ_ONLY) User and Role access to a specific MarkLogic
 * Database.
 * 
 * @author ableasdale
 * 
 */
public class MarkLogicExecuteReadRoleTest {

	private static Log LOG = LogFactory.getLog("MarkLogicExecuteReadRoleTest");
	private static ContentSource cs_exe_read;

	@Rule
	public TestName name = new TestName();

	@Before
	public void before() {
		LOG.info(MessageFormat.format("***** Running: {0} *****",
				name.getMethodName()));
	}

	@BeforeClass
	public static void setup() {
		try {
			URI u = null;
			// Create Read Only User
			u = new URI(TestHelper.XCC_EXECUTE_READ_USER_LOCALHOST_8020);
			cs_exe_read = ContentSourceFactory.newContentSource(u);
		} catch (XccConfigException e) {
			LOG.error(e);
		} catch (URISyntaxException e) {
			LOG.error(e);
		}
	}

	@Test
	public void testNoReadOnlyAccess() throws Exception {
		Session s = cs_exe_read.newSession();
		assertNotNull(s);
		// Checks for Document permissions (database connection can be 'read')
		assertNotNull(s.getCurrentServerPointInTime());

		// Does the read-only user have enough permissions to enable them to get
		// an estimate of all the docs in the db? There should be 100 at the
		// time of writing (but the ro_user won't see them yet)
		Request r = s.newAdhocQuery(TestHelper.XDMP_DOC_ESTIMATE_QUERY);
		ResultSequence rs = s.submitRequest(r);
		assertTrue(
				"Assert that the initial estimate for the database size did not return an empty sequence",
				rs.size() > 0);
		assertEquals(
				"Assert that the read-only user can currently see NO docs in the db",
				"0", rs.asString());

		// Now try reading the first doc
		r = s.newAdhocQuery(TestHelper.FIRST_DOC_IN_DB_QUERY);
		rs = s.submitRequest(r);
		LOG.debug("size: " + rs.size());
		assertFalse("Assert that no result was returned from the ad-hoc query",
				rs.size() > 0);

		s.close();
	}

	@Test
	public void testReadOnlyAccessWithNewDocs() throws Exception {
		Session s = cs_exe_read.newSession();
		// initial setup
		TestHelper.addOneHundredDocsToDbAsAdmin("second-test");
		Request r = s.newAdhocQuery(TestHelper.XDMP_DOC_ESTIMATE_QUERY);
		ResultSequence rs = s.submitRequest(r);
		// Now there should be 200 docs in the db; this user should not have
		// access to any.
		assertTrue(
				"Assert that the initial estimate for the database size did not return an empty sequence",
				rs.size() > 0);
		assertEquals(
				"Assert that the read-only user can currently see NO docs in the db",
				"0", rs.asString());
		s.close();
	}

	@Test
	public void testReadOnlyAccessWithChangedDocs() throws Exception {

		TestHelper.addReadPermissionsToFirstDocAsAdmin();

		Session s = cs_exe_read.newSession();
		// initial setup
		Request r = s.newAdhocQuery(TestHelper.XDMP_DOC_ESTIMATE_QUERY);
		ResultSequence rs = s.submitRequest(r);
		assertTrue(
				"Assert that the initial estimate for the database size did not return an empty sequence",
				rs.size() > 0);
		assertEquals(
				"Assert that the read-only user can currently see ONE doc in the db",
				"1", rs.asString());

		r = s.newAdhocQuery(TestHelper.FIRST_DOC_IN_DB_PERMISSIONS_QUERY);
		rs = s.submitRequest(r);
		assertTrue(
				"Assert that the initial estimate for the database size did not return an empty sequence",
				rs.size() > 0);
		LOG.debug("Permissions: \n" + rs.asString());

		Document d = XMLUnit.buildControlDocument(rs.asString());
		XMLAssert.assertXpathEvaluatesTo("read",
				"/sec:permission/sec:capability/text()", d);
		XMLAssert.assertXpathEvaluatesTo("1", "count(sec:permission)", d);
		// Now add RO permissions to all remaining docs (200)
		TestHelper.addReadPermissionsToRemainingDocsAsAdmin();
		r = s.newAdhocQuery(TestHelper.XDMP_DOC_ESTIMATE_QUERY);
		rs = s.submitRequest(r);
		assertTrue(
				"Assert that the initial estimate for the database size did not return an empty sequence",
				rs.size() > 0);
		assertEquals(
				"Assert that the read-only user can currently see ALL docs in the db",
				"200", rs.asString());
		s.close();
	}

	@Test
	public void testFirstDocCanBeReadAndProcessed() throws Exception {

		Session s = cs_exe_read.newSession();
		// Now try reading the first doc
		Request r = s.newAdhocQuery(TestHelper.FIRST_DOC_IN_DB_QUERY);
		ResultSequence rs = s.submitRequest(r);
		LOG.debug("size: " + rs.size());
		assertTrue(
				"Assert that a result with size greater than one was returned from the ad-hoc query",
				rs.size() > 0);

		Assert.assertTrue("Checking for string representation of root node", rs
				.asString().contains("<content>"));
		LOG.debug(rs.asString());

		XMLAssert.assertXpathEvaluatesTo("38", "content/item/text()",
				XMLUnit.buildControlDocument(rs.asString()));
		s.close();

	}

	@Test(expected = XQueryException.class)
	public void testAttemptedDocInsertWithReadOnlyAccessOnChangedDocs()
			throws Exception {
		Session s = cs_exe_read.newSession();
		Request r = s.newAdhocQuery(TestHelper.DOC_INSERT_QUERY);
		try {
			s.submitRequest(r);
		} catch (RequestException e) {
			Assert.assertEquals("URI privilege required",
					e.getLocalizedMessage());
			Assert.assertTrue(e.toString().contains("SEC-URIPRIV"));
		}

		// Now let it fail to pass the test
		s.submitRequest(r);
		s.close();
	}

	@Test(expected = XQueryException.class)
	public void testBatchInsertWithReadOnlyAccess() throws Exception {
		Session s = cs_exe_read.newSession();
		Request r = s.newAdhocQuery(Utils
				.readFile(TestHelper.INSERT_TEST_DATA_QUERY_FILE_PATH));
		r.setNewStringVariable("TEST-URI-NAME", "thisshouldfail");
		Assert.assertEquals(1, r.getVariables().length);
		try {
			s.submitRequest(r);
		} catch (RequestException e) {

			Assert.assertEquals("URI privilege required",
					e.getLocalizedMessage());
			Assert.assertTrue(e.toString().contains("SEC-URIPRIV"));
			/*
			 * Assert.assertEquals(
			 * "Expression depends on the context where none is defined",
			 * e.getLocalizedMessage());
			 * Assert.assertTrue(e.toString().contains("XDMP-CONTEXT"));
			 */
		}
		// Now let it fail to pass the test
		s.submitRequest(r);
		s.close();
	}

	@Test(expected = XQueryException.class)
	public void testAttemptedUpdateWithReadOnlyAccessOnChangedDocs()
			throws Exception {
		Session s = cs_exe_read.newSession();
		Request r = s.newAdhocQuery(TestHelper.NODE_REPLACE_QUERY);

		try {
			s.submitRequest(r);
		} catch (RequestException e) {
			Assert.assertEquals("Permission denied", e.getLocalizedMessage());
			Assert.assertTrue(e.toString().contains("SEC-PERMDENIED"));

		}
		// Now let it fail to pass the test
		s.submitRequest(r);
		s.close();
	}

	@Test(expected = XQueryException.class)
	public void testAttemptedDeleteWithReadOnlyAccessOnChangedDocs()
			throws Exception {
		Session s = cs_exe_read.newSession();
		Request r = s.newAdhocQuery(TestHelper.DOC_DELETE_QUERY);

		try {
			s.submitRequest(r);
		} catch (RequestException e) {

			Assert.assertEquals("Permission denied", e.getLocalizedMessage());
			Assert.assertTrue(e.toString().contains("SEC-PERMDENIED"));

		}
		// Now let it fail to pass the test
		s.submitRequest(r);
		s.close();
	}

	@Test
	public void testVisibleDocumentsInCollection() throws Exception {

		Session s = cs_exe_read.newSession();
		Request r = s.newAdhocQuery(TestHelper.COLLECTION_ESTIMATE_QUERY);

		ResultSequence rs = s.submitRequest(r);
		assertTrue(
				"Assert that the initial estimate for the database size did not return an empty sequence",
				rs.size() > 0);
		assertEquals(
				"Assert that the read-only user can currently see ALL docs in the collection",
				"200", rs.asString());
		s.close();

	}

	@Test
	public void testReadFirstDocumentInCollection() throws Exception {
		Session s = cs_exe_read.newSession();
		// Now try reading the first doc
		Request r = s.newAdhocQuery(TestHelper.FIRST_DOC_IN_COLLECTION_QUERY);
		ResultSequence rs = s.submitRequest(r);
		LOG.debug("size: " + rs.size());
		assertTrue(
				"Assert that a result with size greater than one was returned from the ad-hoc query",
				rs.size() > 0);

		Assert.assertTrue("Checking for string representation of root node", rs
				.asString().contains("<content>"));
		LOG.debug(rs.asString());

		XMLAssert.assertXpathEvaluatesTo("38", "content/item/text()",
				XMLUnit.buildControlDocument(rs.asString()));
		s.close();
	}

	@Test(expected = XQueryException.class)
	public void testAttemptedMoveToCollection() throws Exception {
		Session s = cs_exe_read.newSession();
		Request r = s.newAdhocQuery(TestHelper.DOC_ADD_TO_NEW_COLLECTION_QUERY);
		try {
			s.submitRequest(r);
		} catch (RequestException e) {
			Assert.assertEquals("Unprotected collection privilege required",
					e.getLocalizedMessage());
			Assert.assertTrue(e.toString().contains("SEC-UNPROTECTEDCOLPRIV"));
		}
		// let it fail with the XQueryException
		s.submitRequest(r);
		s.close();
	}

	@Test
	public void testEvalPrivilege() throws RequestException {
		Session s = cs_exe_read.newSession();
		Request r = s.newAdhocQuery(TestHelper.SIMPLE_EVAL_QUERY);
		ResultSequence rs = s.submitRequest(r);

		Assert.assertEquals("Eval 1 + 1 correctly evaluated to 2", "2",
				rs.asString());
		s.close();

	}

	/*
	 * // One way of doing namespace aware testing in XMLUnit (pretty verbose //
	 * though) Document d = XMLUnit.buildControlDocument(rs.asString());
	 * Map<String, String> m = new HashMap<String, String>(); m.put("sec",
	 * "http://marklogic.com/xdmp/security");
	 * 
	 * NamespaceContext ctx = new SimpleNamespaceContext(m); XpathEngine engine
	 * = XMLUnit.newXpathEngine(); engine.setNamespaceContext(ctx);
	 * 
	 * NodeList l = engine.getMatchingNodes("//sec:capability", d);
	 * assertEquals(1, l.getLength()); assertEquals("sec:capability",
	 * l.item(0).getNodeName()); assertEquals("read",
	 * l.item(0).getTextContent());
	 */
}
