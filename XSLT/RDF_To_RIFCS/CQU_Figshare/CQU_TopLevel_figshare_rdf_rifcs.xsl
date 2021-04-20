<?xml version="1.0" encoding="UTF-8"?>
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
    
    <xsl:param name="global_originatingSource" select="'Central Queensland University'"/>
    <xsl:param name="global_baseURI" select="'cqu.edu.au'"/>
    <xsl:param name="global_group" select="'Central Queensland University'"/>
    <xsl:param name="global_publisherName" select="'Central Queensland University'"/>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
          
            <xsl:message select="concat('name(oai:OAI-PMH): ', name(oai:OAI-PMH))"/>
            <xsl:apply-templates select="oai:OAI-PMH/*/oai:record"/>
            
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="oai:OAI-PMH/*/oai:record">
        
        <xsl:message select="'Overriding filtering for CQU - including only dataset, fileset and code'"/>
        
        <!-- item_type_1 -->
        <!-- Article type: figure -->
        <!-- item_type_2 -->
        <!-- Article type: media -->
        <!-- item_type_3 -->
        <!-- Article type: dataset -->
        <!-- item_type_4 -->
        <!-- Article type: fileset -->
        <!-- item_type_5 -->
        <!-- Article type: poster -->
        <!-- item_type_6 -->
        <!-- Article type: paper -->
        <!-- item_type_7 -->
        <!-- Article type: presentation -->
        <!-- item_type_8 -->
        <!-- Article type: thesis -->
        <!-- item_type_9 -->
        <!-- Article type: code -->
        <!-- item_type_11 -->
        <!-- Article type: metadata --> 
        
        <!-- include dataset, fileset and code for now -->
  
        
        <xsl:if test="
            (count(oai:header/oai:setSpec[text() = 'item_type_3']) > 0) or
            (count(oai:header/oai:setSpec[text() = 'item_type_4']) > 0) or
            (count(oai:header/oai:setSpec[text() = 'item_type_9']) > 0)">
            
            <xsl:variable name="type">
                <xsl:choose>
                    <!-- dataset -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_3']) > 0">
                        <xsl:text>dataset</xsl:text>
                    </xsl:when>
                    <!-- fileset -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_4']) > 0">
                        <xsl:text>collection</xsl:text>
                    </xsl:when>
                    <!-- code -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_9']) > 0">
                        <xsl:text>software</xsl:text>
                    </xsl:when>
                   </xsl:choose>
            </xsl:variable>
            
            <xsl:variable name="oaiFigshareIdentifier" select="oai:header/oai:identifier"/>
            <xsl:if test="string-length($oaiFigshareIdentifier)">
                <xsl:apply-templates select="oai:metadata/rdf:RDF" mode="collection">
                    <xsl:with-param name="oaiFigshareIdentifier" select="$oaiFigshareIdentifier"/>
                    <xsl:with-param name="type" select="$type"/>
                </xsl:apply-templates>
                <!-- xsl:apply-templates select="oai:metadata/rdf:RDF/dc:funding" mode="funding_party"/ -->
                <!-- xsl:apply-templates select="oai:metadata/rdf:RDF" mode="party"/-->
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
