<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- __articles.xsl___
	Stand: 2020-01-10
	Autor: Stefan Krug
-->

<xsl:template match="/">
	<articles>
		<xsl:apply-templates />
	</articles>
</xsl:template>

<xsl:template match='html'>
	<article>
		<xsl:value-of select="."/>
	</article>
</xsl:template>

</xsl:stylesheet>