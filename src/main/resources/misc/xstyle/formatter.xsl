<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:html="http://www.w3.org/1999/xhtml">

	<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="yes"
	indent="no" media-type="text/xml"/>

	<xsl:strip-space elements="*"/>

	<xsl:template match="/">

		<html>
			<head>
				<link href="mystyle.css" rel="stylesheet" type="text/css" media="screen" />
			</head>
			<body>
				<xsl:apply-templates />
			</body>
		</html>
	</xsl:template>

	<xsl:template match="node()">
		<span class="element">
		&lt;<xsl:value-of select="name()" />
		<xsl:apply-templates select="@*" />&gt;<xsl:apply-templates />&lt;/<xsl:value-of select="name()" />&gt;
		</span>
	</xsl:template>

	<xsl:template match="comment()">
	</xsl:template>

	<xsl:template match="processing-instruction()">
	</xsl:template>

	<xsl:template match="text()">
		<span class="text">
			<xsl:value-of select="." />
		</span>
	</xsl:template>

	<xsl:template match="@*">
		<xsl:text> </xsl:text>
		<span class="attribute-name"><xsl:value-of select="name()"/></span>=<span class="attribute-value">"<xsl:value-of select="." />"</span>
	</xsl:template>

</xsl:stylesheet>
