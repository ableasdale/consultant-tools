package com.xmlmachines.marklogic.permissions;

import static org.junit.Assert.assertNotNull;

import java.net.URI;
import java.text.MessageFormat;

import junit.framework.Assert;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TestName;

import com.marklogic.xcc.ContentSource;
import com.marklogic.xcc.ContentSourceFactory;
import com.marklogic.xcc.Request;
import com.marklogic.xcc.Session;
import com.marklogic.xcc.exceptions.RequestException;
import com.marklogic.xcc.exceptions.RequestPermissionException;
import com.marklogic.xcc.exceptions.XQueryException;

public class MarkLogicNoPermissionsRoleTest {

	private static Log LOG = LogFactory
			.getLog("MarkLogicNoPermissionsRoleTest");

	private static ContentSource cs_noperms;

	@Rule
	public TestName name = new TestName();

	@Before
	public void before() {
		LOG.info(MessageFormat.format("***** Running: {0} *****",
				name.getMethodName()));
	}

	@BeforeClass
	public static void setup() throws Exception {
		URI u = new URI(TestHelper.XCC_NOPERMS_USER_NOPERMS_PASS_LOCALHOST);
		cs_noperms = ContentSourceFactory.newContentSource(u);
	}

	@Test(expected = RequestPermissionException.class)
	public void testNonExistentUser() throws Exception {
		URI u = new URI("xcc://nouser:noname@localhost:8010");
		ContentSource cs = ContentSourceFactory.newContentSource(u);
		Session s = cs.newSession();
		assertNotNull(s.getCurrentServerPointInTime());
		s.close();
	}

	@Test(expected = XQueryException.class)
	public void testNoPermsAccess() throws Exception {
		Session s = cs_noperms.newSession();
		try {
			assertNotNull(s.getCurrentServerPointInTime());
		} catch (RequestException e) {
			Assert.assertEquals("Ensuring we get a Need Privilege message.",
					"Need privilege", e.getLocalizedMessage());
		}
		assertNotNull(s.getCurrentServerPointInTime());
		s.close();
	}

	@Test(expected = XQueryException.class)
	public void testEvalPrivilege() throws Exception {
		Session s = cs_noperms.newSession();
		Request r = s.newAdhocQuery(TestHelper.SIMPLE_EVAL_QUERY);

		try {
			s.submitRequest(r);
		} catch (RequestException e) {
			Assert.assertEquals("Need privilege", e.getLocalizedMessage());
			Assert.assertTrue(e.toString().contains("SEC-PRIV"));
		}
		// Allow it to fail to complete the test
		s.submitRequest(r);
		s.close();
	}
}
