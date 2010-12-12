package com.xmlmachines.marklogic.permissions;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.math.BigInteger;
import java.net.URI;
import java.net.URISyntaxException;
import java.text.MessageFormat;

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
import com.marklogic.xcc.exceptions.XccConfigException;

public class MarkLogicInsertUpdateRoleTest {

	private static Log LOG = LogFactory.getLog("MarkLogicExecuteReadRoleTest");
	private static ContentSource cs_ins_upd;

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
			u = new URI(TestHelper.XCC_FULL_ACCESS_USER_LOCALHOST_8010);
			cs_ins_upd = ContentSourceFactory.newContentSource(u);
		} catch (XccConfigException e) {
			LOG.error(e);
		} catch (URISyntaxException e) {
			LOG.error(e);
		}
	}

	@Test
	public void testBasicXccConnection() {
		Session s = cs_ins_upd.newSession();
		assertNotNull(s);
		try {
			BigInteger l = s.getCurrentServerPointInTime();
			LOG.debug(MessageFormat.format("Got Server Timestamp: {0}",
					l.toString()));

			assertNotNull(l);
		} catch (RequestException e) {
			LOG.error(e);
		} finally {
			s.close();
		}
	}

	@Test
	public void testInitialDocumentReadAccess() throws Exception {
		Session s = cs_ins_upd.newSession();
		assertNotNull(s);
		assertNotNull(s.getCurrentServerPointInTime());
		Request r = s.newAdhocQuery(TestHelper.XDMP_DOC_ESTIMATE_QUERY);
		ResultSequence rs = s.submitRequest(r);
		assertTrue(
				"Assert that the initial estimate for the database size did not return an empty sequence",
				rs.size() > 0);
		assertEquals(
				"Assert that the read-only user can currently see ALL docs in the db",
				"200", rs.asString());

		// Now try reading the first doc
		r = s.newAdhocQuery(TestHelper.FIRST_DOC_IN_DB_QUERY);
		rs = s.submitRequest(r);
		LOG.debug("size: " + rs.size());
		assertTrue("Assert that a result was returned from the ad-hoc query",
				rs.size() > 0);
		s.close();
	}

	@Test
	public void testInitialCollectionReadAccess() throws Exception {
		Session s = cs_ins_upd.newSession();
		assertNotNull(s);
		assertNotNull(s.getCurrentServerPointInTime());
		Request r = s.newAdhocQuery(TestHelper.COLLECTION_ESTIMATE_QUERY);
		ResultSequence rs = s.submitRequest(r);
		assertTrue(
				"Assert that the initial estimate for the database size did not return an empty sequence",
				rs.size() > 0);
		assertEquals(
				"Assert that the read-only user can currently see ALL docs in the db",
				"200", rs.asString());

		// Now try reading the first doc
		r = s.newAdhocQuery(TestHelper.FIRST_DOC_IN_COLLECTION_QUERY);
		rs = s.submitRequest(r);
		LOG.debug("size: " + rs.size());
		assertTrue("Assert that a result was returned from the ad-hoc query",
				rs.size() > 0);
		s.close();
	}

	@Test
	public void testFirstDocHasOnlyOnePermission() throws Exception {
		// At this stage, we've only applied one permission - check for this to
		// confirm, then add others..
		Session s = cs_ins_upd.newSession();
		assertNotNull(s);
		assertNotNull(s.getCurrentServerPointInTime());
		Request r = s
				.newAdhocQuery(TestHelper.FIRST_DOC_IN_DB_PERMISSIONS_QUERY);
		ResultSequence rs = s.submitRequest(r);

		LOG.debug("size: " + rs.size());
		assertTrue("Assert that a result was returned from the ad-hoc query",
				rs.size() > 0);

		Document d = XMLUnit.buildControlDocument(rs.asString());
		XMLAssert.assertXpathEvaluatesTo("read",
				"/sec:permission/sec:capability/text()", d);
		XMLAssert.assertXpathEvaluatesTo("1", "count(sec:permission)", d);
		s.close();
	}

	@Test
	public void testAttemptedDocInsertUpdateAndDelete() throws Exception {
		Session s = cs_ins_upd.newSession();
		Request r = s.newAdhocQuery(TestHelper.DOC_INSERT_QUERY);
		s.submitRequest(r);
		// read back the doc
		r = s.newAdhocQuery(TestHelper.INSERTED_DOC_QUERY);
		ResultSequence rs = s.submitRequest(r);
		assertTrue("Assert that a result was returned from the ad-hoc query",
				rs.size() > 0);
		Document d = XMLUnit.buildControlDocument(rs.asString());
		XMLAssert.assertXpathEvaluatesTo("ok", "/test/text()", d);
		r = s.newAdhocQuery(TestHelper.XDMP_DOC_ESTIMATE_QUERY);
		rs = s.submitRequest(r);
		assertTrue(
				"Assert that the initial estimate for the database size did not return an empty sequence",
				rs.size() > 0);
		assertEquals(
				"Assert that the full user can currently see ALL docs in the db",
				"201", rs.asString());

		// check for 4 properties (read, insert, update, execute)
		r = s.newAdhocQuery(TestHelper.INSERTED_DOC_PROPERTIES);
		rs = s.submitRequest(r);

		assertTrue("Assert that a result was returned from the ad-hoc query",
				rs.size() > 0);
		d = XMLUnit.buildControlDocument(rs.asString());
		XMLAssert.assertXpathEvaluatesTo("4",
				"count(properties/sec:permission)", d);
		XMLAssert.assertXpathEvaluatesTo("read",
				"properties/sec:permission[1]/sec:capability/text()", d);
		XMLAssert.assertXpathEvaluatesTo("execute",
				"properties/sec:permission[2]/sec:capability/text()", d);
		XMLAssert.assertXpathEvaluatesTo("insert",
				"properties/sec:permission[3]/sec:capability/text()", d);
		XMLAssert.assertXpathEvaluatesTo("update",
				"properties/sec:permission[4]/sec:capability/text()", d);
		// now update the document

		r = s.newAdhocQuery(TestHelper.INSERTED_DOC_UPDATE_QUERY);
		rs = s.submitRequest(r);
		assertTrue(
				"Assert that a result was NOT returned from the ad-hoc query",
				rs.size() == 0);
		// now check the doc
		r = s.newAdhocQuery(TestHelper.INSERTED_DOC_QUERY);
		rs = s.submitRequest(r);
		d = XMLUnit.buildControlDocument(rs.asString());
		XMLAssert.assertXpathEvaluatesTo("updated", "now/text()", d);
		// finally delete the doc
		r = s.newAdhocQuery(TestHelper.INSERTED_DOC_DELETION_QUERY);
		rs = s.submitRequest(r);
		assertTrue(
				"Assert that a result was NOT returned from the ad-hoc query",
				rs.size() == 0);
		// try to get the deleted Doc again
		r = s.newAdhocQuery(TestHelper.INSERTED_DOC_QUERY);
		rs = s.submitRequest(r);
		assertTrue(
				"Assert that a result was NOT returned from the ad-hoc query",
				rs.size() == 0);
		// Confirm that the Document has been removed
		r = s.newAdhocQuery(TestHelper.XDMP_DOC_ESTIMATE_QUERY);
		rs = s.submitRequest(r);
		assertTrue(
				"Assert that the initial estimate for the database size did not return an empty sequence",
				rs.size() > 0);
		assertEquals(
				"Assert that the full user can currently see ALL docs in the db",
				"200", rs.asString());
		s.close();
	}
}
