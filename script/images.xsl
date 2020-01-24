<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- __images.xsl___
	Stand: 2020-01-24
	Autor: Stefan Krug
-->

<xsl:param name="count"/>
    
<xsl:template match="/">
	<article>
		<xsl:call-template name="recursion">
			<xsl:with-param name="counter" select="0"/>
		</xsl:call-template>
	</article>
</xsl:template>

<xsl:template name="recursion">
	<xsl:param name="counter"/>
	
	<xsl:variable name="document">
		<xsl:choose>
			<xsl:when test="$counter = 0">
				<xsl:text>articleData.xml</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('articleData', $counter, '.xml')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:for-each select="document($document)/article/version">
		<version>
			<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
			<xsl:for-each select=".//img">
				<xsl:if test="@width>'35' and @height>'35'"> <!-- Ausschluss von Icons und anderen fuer die Untersuchung irrelevanten Grafiken -->
					<image>
						<xsl:attribute name="id">
							<xsl:number value="position()" level="single"/>	<!-- autoincrement als ID fuer die Images. zaehlt jeden Schleifendurchlauf, unabhaengig vom IF-Statement -->
						</xsl:attribute>
						<alt><xsl:value-of select="@alt"/></alt>
						<url><xsl:value-of select="@src"/></url>
						<class><xsl:value-of select="@class"/></class>
						<width><xsl:value-of select="@width"/></width>
						<height><xsl:value-of select="@height"/></height>
						<width_file><xsl:value-of select="@data-file-width"/></width_file>
						<height_file><xsl:value-of select="@data-file-height"/></height_file>
						<decoding><xsl:value-of select="@decoding"/></decoding>
						<srcset><xsl:value-of select="@srcset"/></srcset>
					</image>
				</xsl:if>
			</xsl:for-each>
		</version>
	</xsl:for-each>
	
	<xsl:if test="$counter &lt; $count">			<!-- solange counter < count ist: rekursion mit counter+1 -->
		<xsl:call-template name="recursion">
			<xsl:with-param name="counter" select="$counter + 1"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>