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
			<xsl:call-template name="reverse">
				<xsl:with-param name="input" select="normalize-space(.)"/>
			</xsl:call-template>

		</p>
	</xsl:template>

	<xsl:template name="reverse">
		<xsl:param name="input"/>
		<xsl:variable name="len" select="string-length($input)"/>
		<xsl:choose>
			<!-- строки длиной меньше 2 никак не обращаются -->
			<xsl:when test="$len &lt; 2">
				<xsl:value-of select="$input"/>
			</xsl:when>
			<xsl:when test="$len = 2">
				<xsl:value-of select="substring($input,2,1)"/>
				<xsl:value-of select="substring($input,1,1)"/>
			</xsl:when>
			<xsl:otherwise>
				<!--Шаблон рекурсивно применяется сначала ко второй, а потом к первой половине входной строки -->
				<xsl:variable name="mid" select="floor($len div 2)"/>
				<xsl:call-template name="reverse">
					<xsl:with-param name="input" select="substring($input,$mid+1,$mid+1)"/>
				</xsl:call-template>
				<xsl:call-template name="reverse">
					<xsl:with-param name="input" select="substring($input,1,$mid)"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>



	</xsl:stylesheet>