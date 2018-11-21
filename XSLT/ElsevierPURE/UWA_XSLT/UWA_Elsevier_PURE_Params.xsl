<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
    
    <xsl:import href="Elsevier_PURE_API511_rifcs.xsl"/>
    
    <xsl:param name="global_debug" select="true()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    <xsl:param name="global_originatingSource" select="'University of Western Australia'"/>
    <xsl:param name="global_baseURI" select="'research-repository.uwa.edu.au'"/>
    <xsl:param name="global_path" select="'/en/'"/>
    <xsl:param name="global_acronym" select="'UWA_PURE'"/>
    <xsl:param name="global_group" select="'The University of Western Australia'"/>
    <xsl:param name="global_publisherName" select="'University of Western Australia'"/>
    
</xsl:stylesheet>