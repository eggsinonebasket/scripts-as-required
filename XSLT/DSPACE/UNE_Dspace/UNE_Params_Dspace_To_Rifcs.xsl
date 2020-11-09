<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://www.lyncode.com/xoai" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <xsl:import href="DSPACE_To_Rifcs.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'University of New England'"/>
    <xsl:param name="global_group" select="'University of New England, Australia'"/>
    <xsl:param name="global_acronym" select="'UNE'"/>
    <xsl:param name="global_publisherName" select="'University of New England'"/>
    <xsl:param name="global_baseURI" select="'https://rune.une.edu.au'"/>
    <xsl:param name="global_path" select="'/web/handle/'"/>
    
    <!-- overrides -->
    <!--xsl:template match="dc:source" mode="collection_citation_info">
       
    </xsl:template-->  
    
</xsl:stylesheet>
    
