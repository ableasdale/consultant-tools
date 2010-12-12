package com.xmlmachines.marklogic.permissions;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.math.BigInteger;
import java.net.URI;
import java.text.MessageFormat;

import junit.framework.Assert;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.custommonkey.xmlunit.XMLAssert;
import org.custommonkey.xmlunit.XMLUnit;
import org.custommonkey.xmlunit.exceptions.XpathException;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TestName;
import org.xml.sax.SAXException;

import com.marklogic.xcc.ContentSource;
import com.marklogic.xcc.ContentSourceFactory;
import com.marklogic.xcc.Request;
import com.marklogic.xcc.ResultSequence;
import com.marklogic.xcc.Session;
import com.marklogic.xcc.exceptions.RequestException;

/**
 * All unit tests to ensure the initial Database is configured correctly, if any
 * of the tests fail with Admin access, we know something has gone wrong!
 * 
 * 
 * @author ableasdale
 * 
 */
public class MarkLogicAdminRoleTest {

	private static Log LOG = LogFactory.getLog("MarkLogicAdminRoleTest");
	private static ContentSource cs_adm;

	@Rule
	public TestName name = new TestName();

	@Before
	public void before() {
		LOG.info(MessageFormat.format("***** Running: {0} *****",
				name.getMethodName()));
	}

	@BeforeClass
	public static void setup() throws Exception {
		// Create XCC ContentSource for Admin User
		URI u = new URI(TestHelper.XCC_ADMIN_ADMIN_LOCALHOST_8010);
		cs_adm = ContentSourceFactory.newContentSource(u);

		// Clear DB at outset
		Session s = cs_adm.newSession();
		Request r = s.newAdhocQuery(TestHelper.CLEAR_DB_QUERY);
		s.submitRequest(r);
		s.close();
	}

	@Test
	public void testBasicXccConnection() {
		Session s = cs_adm.newSession();
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
	public void testAdminUserCanSeeAllDocsInDb() throws Exception {
		Session s = cs_adm.newSession();
		assertNotNull(s);
		assertNotNull(s.getCurrentServerPointInTime());

		Request r = s.newAdhocQuery(TestHelper.XDMP_DOC_ESTIMATE_QUERY);
		ResultSequence rs = s.submitRequest(r);
		assertTrue("Testing that we have an estimate for the database size",
				rs.size() > 0);
		assertEquals("Can the admin user see how many docs are in the db?",
				"0", rs.asString());

		TestHelper.addOneHundredDocsToDbAsAdmin("first-test");

		// now get the estimate
		r = s.newAdhocQuery(TestHelper.XDMP_DOC_ESTIMATE_QUERY);
		rs = s.submitRequest(r);
		assertEquals("Can the admin user see how many docs are in the db?",
				"100", rs.asString());
		s.close();
	}

	@Test
	public void testDefaultDocsHaveNoPermissions() throws Exception {
		Session s = cs_adm.newSession();
		Request r = s
				.newAdhocQuery(TestHelper.FIRST_DOC_IN_DB_PERMISSIONS_QUERY);
		ResultSequence rs = s.submitRequest(r);
		assertTrue("Testing that a result did come back from the query",
				rs.size() == 0);
		assertEquals(
				"Confirming an empty sequence (String) gets returned as no docs have permissions",
				"", rs.asString());
	}

	@Test
	public void testRetrieveFirstDocWithAdhocQuery() {
		Session s = cs_adm.newSession();
		Request r = s.newAdhocQuery(TestHelper.FIRST_DOC_IN_DB_QUERY);
		try {
			ResultSequence rs = s.submitRequest(r);
			assertTrue("Testing that a result did come back from the query",
					rs.size() > 0);
			Assert.assertTrue(
					"Checking for string representation of root node", rs
							.asString().contains("<content>"));
			LOG.debug(rs.asString());
			try {

				XMLAssert.assertXpathEvaluatesTo("38", "content/item/text()",
						XMLUnit.buildControlDocument(rs.asString()));
			} catch (SAXException e) {
				LOG.error(e);
			} catch (IOException e) {
				LOG.error(e);
			} catch (XpathException e) {
				LOG.error(e);
			}
		} catch (RequestException e) {
			LOG.error(e);
		} finally {
			LOG.debug("Closing the session");
			s.close();
		}
	}

}
