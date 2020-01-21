<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- __images.xsl___
	Stand: 2020-01-21
	Autor: Stefan Krug
-->

<xsl:template match="/">
	<article>
		<xsl:apply-templates />
	</article>
</xsl:template>

<xsl:template match="article/version">
	<version>
		<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
		<xsl:for-each select=".//img">
			<xsl:if test="@width>'35' and @height>'35'"> <!-- Ausschluss von Icons und anderen für die Untersuchung irrelevanten Grafiken -->
				<image>
					<xsl:attribute name="id">
						<xsl:number value="position()" level="single"/>	<!-- autoincrement als ID für die Images. zaehlt jeden Schleifendurchlauf, unabhängig vom IF-Statement -->
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
</xsl:template>

</xsl:stylesheet>