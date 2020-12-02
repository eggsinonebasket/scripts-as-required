<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <xsl:import href="OPENAIRE_To_Rifcs.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'Australian Catholic University'"/>
    <xsl:param name="global_group" select="'Australian Catholic University'"/>
    <xsl:param name="global_acronym" select="'ACU'"/>
    <xsl:param name="global_publisherName" select="'Australian Catholic University'"/>
    <!--xsl:param name="global_baseURI" select="''"/-->
    <!--xsl:param name="global_path" select="''"/-->
    
    <!-- overrides -->
    <xsl:template match="oaire:source" mode="collection_citation_info">
       
    </xsl:template>  
    
</xsl:stylesheet>
    
