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
			<xsl:call-template name="truncate">
				<!-- Шаблон позволяет обрезать строку и оборачивать оставшуюся часть в тег span -->
				<!--$node - передаем параграф-->
				<!--$limit - ограничение символов-->
				<!--$tolerance - количество символов которые могут войти в диапазон погрешности при условии если в качестве ограничителя задано условие ($tolerance может отсчитываться как в правую так и в левую сторону от $limit) -->
				<!--$delimiters - ограничитель, который является границей строки, если задан $tolerance и индекс разделителя входит в диапазон $tolerance (как в правую так и в левую сторону от $limit), то строка обрезается от разделителя. По умолчанию задан след. список разделителей ' -!?:)(;,.…&#x2013;&#x2014;', они применяются последовательно, если первым обнаружен пробел, то обрезается по пробелу, если пробел не найден, то ищем '-' и т.д.  -->
				<!--$suffix - окончание для обрезанной строки-->
				<!--$force_suffix - принудительно применяем окончание, даже если строка короче лимита-->
				<xsl:with-param name="node" select="."/>
				<xsl:with-param name="limit" select="200"/>
				<xsl:with-param name="tolerance" select="50"/>
				<xsl:with-param name="delimiters" select="str:tokenize('.,','')"/>
				<xsl:with-param name="suffix" select="'Далее'"/>
			</xsl:call-template>
		</p>
	</xsl:template>


	<xsl:template name="truncate">
		<xsl:param name="node"/>
		<xsl:param name="limit"/>

		<!-- Добавляем в конец обрезанной строки слово/символ -->
		<xsl:param name="suffix" select="'&#x2026;'"/>

		<!-- Принудительно применяем окончание, даже если строка короче лимита -->
		<xsl:param name="force_suffix" select="'no'"/>

		<!--Не строгое ограничение. Позволяем словам которые входят в диапазон разделителей оставаться в строке. Пока они соответствуют формуле $length + $tolerance -->
		<xsl:param name="tolerance" select="3"/>

		<!-- Символы которые распознаются как конец строки, место с которого можно обрезать строку, в пределах указанных в $tolerance  -->
		<xsl:param name="delimiters" select="str:tokenize(' -!?:)(;,.…&#x2013;&#x2014;', '')"/>

		<xsl:choose>
			<xsl:when test="$limit &lt; string-length($node) or $force_suffix = 'yes'">
				<xsl:variable name="real-limit">
					<xsl:choose>
						<xsl:when test="string-length($node) &lt;= $limit">
							<xsl:value-of select="string-length($node)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="preceding-delimiter">
								<xsl:call-template name="truncate-find-delimiter">
									<xsl:with-param name="value">
										<xsl:for-each select="str:tokenize(substring($node, 1, $limit + 1), '')">
											<xsl:sort select="position()" data-type="number" order="descending"/>
											<xsl:value-of select="."/>
										</xsl:for-each>
									</xsl:with-param>
									<xsl:with-param name="delimiters" select="$delimiters"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:variable name="following-delimiter">
								<xsl:call-template name="truncate-find-delimiter">
									<xsl:with-param name="value" select="substring($node, $limit + 1)"/>
									<xsl:with-param name="delimiters" select="$delimiters"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="$preceding-delimiter = 0 and $following-delimiter = 0">
									<xsl:value-of select="$limit"/>
								</xsl:when>
								<xsl:when test="$following-delimiter &lt;= $tolerance">
									<xsl:value-of select="$limit + $following-delimiter"/>
								</xsl:when>
								<xsl:when test="$preceding-delimiter &lt;= $tolerance">
									<xsl:value-of select="$limit - $preceding-delimiter"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$limit"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:apply-templates select="($node/* | $node/text())[1]" mode="truncate-search">
					<xsl:with-param name="limit" select="$real-limit"/>
					<xsl:with-param name="suffix" select="exsl:node-set($suffix)"/>
				</xsl:apply-templates>
			</xsl:when>

			<xsl:otherwise>
				<xsl:copy-of select="exsl:node-set($node)/* | exsl:node-set($node)/text()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- Search for the node that runs over the limit. -->
	<xsl:template match="* | text()" mode="truncate-search">
		<xsl:param name="length" select="0"/>
		<xsl:param name="limit" select="0"/>
		<xsl:param name="position" select="1"/>
		<xsl:param name="suffix"/>

		<xsl:variable name="next" select="(../* | ../text())[$position + 1]"/>

		<xsl:choose>
			<!-- Limit found -->
			<xsl:when test="$length + string-length(.) &gt;= $limit">
				<xsl:choose>
					<!-- Keep searching children -->
					<xsl:when test="*">
						<xsl:copy>
							<xsl:for-each select="@*">
								<xsl:copy/>
							</xsl:for-each>

							<xsl:apply-templates select="(* | text())[1]" mode="truncate-search">
								<xsl:with-param name="length" select="$length"/>
								<xsl:with-param name="limit" select="$limit"/>
								<xsl:with-param name="suffix" select="$suffix"/>
							</xsl:apply-templates>
						</xsl:copy>
					</xsl:when>

					<!-- The node to truncate -->
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="truncate-apply">
							<xsl:with-param name="limit" select="$limit - $length"/>
							<xsl:with-param name="suffix" select="$suffix"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<!-- Keep searching at this level -->
			<xsl:otherwise>
				<xsl:copy-of select="."/>

				<xsl:if test="$next">
					<xsl:apply-templates select="$next" mode="truncate-search">
						<xsl:with-param name="length" select="$length + string-length(.)"/>
						<xsl:with-param name="limit" select="$limit"/>
						<xsl:with-param name="position" select="$position + 1"/>
						<xsl:with-param name="suffix" select="$suffix"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Apply truncation to node -->
	<xsl:template match="*" mode="truncate-apply">
		<xsl:param name="limit"/>
		<xsl:param name="suffix"/>

		<xsl:copy>
			<xsl:for-each select="@*">
				<xsl:copy/>
			</xsl:for-each>

			<xsl:apply-templates select="text()" mode="truncate-apply">
				<xsl:with-param name="limit" select="$limit"/>
				<xsl:with-param name="suffix" select="$suffix"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="text()" mode="truncate-apply">
		<xsl:param name="limit"/>
		<xsl:param name="suffix"/>

		<xsl:value-of select="substring(., 1, $limit)"/>
		<span class="bl_delimiter"><xsl:copy-of select="$suffix"/></span>
		<span class="bl_delimited_section"><xsl:value-of select="substring(., $limit+1)"/></span>
	</xsl:template>


	<!-- Search for a delimiter -->
	<xsl:template name="truncate-find-delimiter">
		<xsl:param name="value"/>
		<xsl:param name="delimiters"/>
		<xsl:param name="length" select="0"/>
		<xsl:choose>
			<xsl:when test="$value != ''">
				<xsl:choose>
					<xsl:when test="$delimiters[starts-with(substring($value, 1, 1), .)]">
						<xsl:value-of select="$length"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="truncate-find-delimiter">
							<xsl:with-param name="value" select="substring($value, 2)"/>
							<xsl:with-param name="delimiters" select="$delimiters"/>
							<xsl:with-param name="length" select="$length + 1"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$length"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	</xsl:stylesheet>