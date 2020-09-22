<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:bibo="http://purl.org/ontology/bibo/" 
    xmlns:datacite="http://purl.org/spar/datacite/" 
    xmlns:fabio="http://purl.org/spar/fabio/" 
    xmlns:foaf="http://xmlns.com/foaf/0.1/" 
    xmlns:literal="http://www.essepuntato.it/2010/06/literalreification/" 
    xmlns:obo="http://purl.obolibrary.org/obo/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
    xmlns:vcard="http://www.w3.org/2006/vcard/ns#" 
    xmlns:vivo="http://vivoweb.org/ontology/core#"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:local="http://local.here.org"
    xmlns:exslt="http://exslt.org/common"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    exclude-result-prefixes="oai dc bibo datacite fabio foaf literal obo rdf rdfs vcard vivo xs fn local exslt">
    <xsl:import href="figshare_rdf_rifcs.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'Federation University Figshare'"/>
    <xsl:param name="global_baseURI" select="'https://federation.figshare.com/'"/>
    <xsl:param name="global_group" select="'Federation University Australia'"/>
    <xsl:param name="global_publisherName" select="'Federation University Australia'"/>

     <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
          
            <xsl:message select="concat('name(oai:OAI-PMH): ', name(oai:OAI-PMH))"/>
            
            <xsl:apply-templates select="oai:OAI-PMH/*/oai:record"/>
            
        </registryObjects>
    </xsl:template>
    
</xsl:stylesheet>
