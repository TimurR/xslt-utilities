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
			<xsl:call-template name="str:substring-before-last">
				<xsl:with-param name="input" select="normalize-space(.)"/>
				<xsl:with-param name="substring" select="'искусств'"/>
			</xsl:call-template>

		</p>
	</xsl:template>

	<!--Выводим часть строки перед последним вхождения подстроки-->
	<xsl:template name="str:substring-before-last">
		<!--Принимаем параметры всей строки и подстроки-->
		<xsl:param name="input"/>
		<xsl:param name="substring"/>
		<!--Если передана подстрока и строка содержит подстроку-->
		<xsl:if test="$substring and contains($input, $substring)">
			<!-- Создаем переменную temp в которую сохраняем остаток после первого найденного вхождения -->
			<xsl:variable name="temp" select="substring-after($input, $substring)"/>
			<!--Выводим текст перед первым вхождением подстроки-->
			<xsl:value-of select="substring-before($input, $substring)"/>
			<!--Если оставшийся текст, сохраненный в переменной temp содержит подстроку -->
			<xsl:if test="contains($temp, $substring)">
				<!--То выводим саму подстроку и...-->
				<xsl:value-of select="$substring"/>
				<!-- рекурсивно вызываем темплейт и передаем ему оставшуюся строку -->
				<xsl:call-template name="str:substring-before-last">
					<xsl:with-param name="input" select="$temp"/>
					<xsl:with-param name="substring" select="$substring"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<!--Выводим часть строки после последнего вхождения подстроки-->
	<xsl:template name="str:substring-after-last">
		<!--Принимаем параметры всей строки и подстроки-->
		<xsl:param name="input"/>
		<xsl:param name="substring"/>
		<!-- Создаем переменную temp в которую сохраняем остаток после первого найденного вхождения -->
		<xsl:variable name="temp" select="substring-after($input,$substring)"/>
		<xsl:choose>
			<!--Если оставшийся текст, сохраненный в переменной temp содержит подстроку -->
			<xsl:when test="$substring and contains($temp, $substring)">
				<!-- рекурсивно вызываем темплейт и передаем ему оставшуюся строку -->
				<xsl:call-template name="str:substring-after-last">
					<xsl:with-param name="input" select="$temp"/>
					<xsl:with-param name="substring" select="$substring"/>
				</xsl:call-template>
			</xsl:when>
			<!--иначе выводим остаток после первого найденного вхождения-->
			<xsl:otherwise>
				<xsl:value-of select="$temp"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>



	</xsl:stylesheet>