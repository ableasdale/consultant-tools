package com.xmlmachines.marklogic.permissions;

import java.text.MessageFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.custommonkey.xmlunit.NamespaceContext;
import org.custommonkey.xmlunit.SimpleNamespaceContext;
import org.custommonkey.xmlunit.XMLUnit;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;

@RunWith(Suite.class)
@SuiteClasses({ MarkLogicNoPermissionsRoleTest.class,
		MarkLogicAdminRoleTest.class, MarkLogicExecuteReadRoleTest.class,
		MarkLogicInsertUpdateRoleTest.class })
public class MarkLogicRoleTestSuite {

	private static Log LOG = LogFactory.getLog("MarkLogicRoleTestSuite");

	@BeforeClass
	public static void start() {
		LOG.info(MessageFormat
				.format("Starting Test Suite on: {0}", new Date()));

		// Setting Namespace Contexts required for all tests
		Map<String, String> m = new HashMap<String, String>();
		m.put("sec", "http://marklogic.com/xdmp/security");
		NamespaceContext ctx = new SimpleNamespaceContext(m);
		XMLUnit.setXpathNamespaceContext(ctx);
	}

	@AfterClass
	public static void end() {
		LOG.info(MessageFormat.format("Completed Test Suite on: {0}",
				new Date()));
	}
}
