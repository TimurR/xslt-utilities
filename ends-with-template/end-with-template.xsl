<?xml version="1.0" encoding="UTF-8"?>
	<xsl:stylesheet version="1.0"
					xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
					xmlns:str="http://exslt.org/strings"
					xmlns:exsl="http://exslt.org/common"
					extension-element-prefixes="str exsl">

		<xsl:output method="html"/>
		<xsl:strip-space elements="*"/>
		<xsl:template match="/">
			<html>
				<head>
					<title>Page Title</title>
					<style type="text/css">
						.bl_delimited_section{
							background:red;
						}
						.bl_delimiter{
							color:green;
						}
					</style>
				</head>

				<body>
					<xsl:apply-templates select="section"/>
				</body>

			</html>
		</xsl:template>

	<xsl:template match="section">
		<xsl:apply-templates select="p"/>
	</xsl:template>

	<xsl:template match="p">
		<p>
			<xsl:call-template name="end-with">
				<xsl:with-param name="value" select="normalize-space(.)"/>
				<xsl:with-param name="substr" select="'древнейших произведений до современных работ.'"/>
			</xsl:call-template>

		</p>
	</xsl:template>

	<xsl:template name="end-with">
		<xsl:param name="value"/>
		<xsl:param name="substr"/>
		<xsl:choose>
			<xsl:when test="substring($value, (string-length($value) - string-length($substr)) + 1) = $substr">Find string</xsl:when>
			<xsl:otherwise>Can't find string</xsl:otherwise>
		</xsl:choose>
	</xsl:template>



	</xsl:stylesheet>