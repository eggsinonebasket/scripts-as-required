<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:mdb="https://schemas.isotc211.org/19115/-1/mdb/1.3"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:import href="ISO19115-3_Reorder.xsl"/>
    <xsl:import href="ISO19115-3_NamespaceUpdate.xsl"/>
    
    <xsl:template match="/">
        <xsl:variable name="allOutputXML" as="node()*">
            <xsl:copy>
                <xsl:apply-templates select="node()|@*"/>
            </xsl:copy>
        </xsl:variable>
        <xsl:apply-templates select="$allOutputXML//mdb:MD_Metadata" mode="reorder"/>
    </xsl:template>
    
</xsl:stylesheet>