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
        <xsl:for-each select="//*[local-name() = 'MD_Metadata']">
            <xsl:variable name="allOutputXML" as="node()*">
                <xsl:apply-templates select="." mode="namespaceUpdate"/>
            </xsl:variable>
            <xsl:apply-templates select="$allOutputXML" mode="reorder"/>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>