<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- 
## combineImages.xsl
# Die Schemadatei dient dem Zusammenführen von imageData.xml-Dateien.
# Die Quelldateien müssen dem Schema imageData[n].xml entsprechen.
#
#	- count:	Anzahl der imageData[n].xml-Dateien; Standard ist 1.
#	- directory:	Arbeitsverzeichnis.
#
# Autor: 		Alexandra Krug
# Lizenz: 		CC BY 3.0 DE Dieses Werk ist lizenziert unter einer Creative Commons Namensnennung 3.0 Deutschland Lizenz. (http://creativecommons.org/licenses/by/3.0/de/)
# Stand:		2020-01-27
-->

<xsl:param name="count"/>
<xsl:param name="directory"/>
    
<xsl:template match="/">
	<article>
		<xsl:call-template name="recursion">
			<xsl:with-param name="counter" select="1"/>
		</xsl:call-template>
	</article>
</xsl:template>

<xsl:template name="recursion">
	<xsl:param name="counter"/>
	
	<xsl:variable name="document">
		<xsl:value-of select="concat($directory, '/imageData', $counter, '.xml')"/>
	</xsl:variable>
	
	<xsl:for-each select="document($document)/article/version">
		<version>
			<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
			<xsl:for-each select="image">
				<image>
					<xsl:attribute name="id">
						<xsl:value-of select="@id"/>
					</xsl:attribute>
					<alt><xsl:value-of select="alt"/></alt>
					<url><xsl:value-of select="url"/></url>
					<class><xsl:value-of select="class"/></class>
					<width><xsl:value-of select="width"/></width>
					<height><xsl:value-of select="height"/></height>
					<width_file><xsl:value-of select="width_file"/></width_file>
					<height_file><xsl:value-of select="height_file"/></height_file>
					<decoding><xsl:value-of select="decoding"/></decoding>
					<srcset><xsl:value-of select="srcset"/></srcset>
				</image>
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
