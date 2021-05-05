<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:gts="http://www.isotc211.org/2005/gts"
    xmlns:geonet="http://www.fao.org/geonetwork" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:customGMD="http://customGMD.nowhere.yet"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="geonet gmx oai xsi gmd srv gml gco gts custom customGMD">
    <xsl:import href="ISO19139_RIFCS.xsl"/>
    <xsl:import href="CustomFunctions.xsl"/>
    <xsl:import href="CustomFunctionsGMD.xsl"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:param name="global_baseURI" select="'geonetwork.nci.org.au'"/>
    <xsl:param name="global_acronym" select="'NCI'"/>
    <xsl:param name="global_originatingSource" select="'Geoscience Australiay'"/> <!-- Only used as originating source if organisation name cannot be determined from Point Of Contact -->
    <xsl:param name="global_group" select="'Geoscience Australia (Hosted at National Computational Infrastructure)'"/> 
    <xsl:param name="global_path" select="'/geonetwork/srv/eng/catalog.search#/metadata/'"/>
    
    <!-- stylesheet to convert iso19139 in OAI-PMH ListRecords response to RIF-CS -->
    
    <!-- =========================================== -->
    <!-- RegistryObjects (root) Template             -->
    <!-- =========================================== -->
    
    <xsl:template match="/">
        
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            
            <xsl:apply-templates select="//*:MD_Metadata" mode="TOP_LEVEL"/>
        </registryObjects>
        
    </xsl:template>
    
    
    <xsl:template match="*:MD_Metadata" mode="TOP_LEVEL">
        <xsl:message>NCI_GA_toplevel_aggregating</xsl:message>
        
        <xsl:variable name="originatingSourceOrganisation" select="customGMD:originatingSourceOrganisation(.)"/>
        <xsl:message select="concat('$originatingSourceOrganisation: ', $originatingSourceOrganisation)"/>
        
        <xsl:variable name="metadataPointOfTruth_sequence" select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage[contains(lower-case(following-sibling::gmd:protocol/gco:CharacterString), 'metadata-url')]/gmd:URL" as="xs:string*"/>
        
        <xsl:for-each select="distinct-values($metadataPointOfTruth_sequence)">
            <xsl:message select="concat('$metadataPointOfTruth_sequence: ', .)"/>
        </xsl:for-each>
        
        <xsl:apply-templates select="." mode="ISO19139_TO_RIFCS">
            <xsl:with-param name="aggregatingGroup" select="$global_group"/>
        </xsl:apply-templates>
        
               
        <!--xsl:choose>
            <xsl:when test="
                custom:sequenceContains($metadataPointOfTruth_sequence, 'eatlas') or
                contains(lower-case($originatingSourceOrganisation), 'GA') or
                contains(lower-case($originatingSourceOrganisation), 'GA')">
                <xsl:apply-templates select="." mode="GA">
                    <xsl:with-param name="aggregatingGroup" select="$global_group"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="ISO19139_TO_RIFCS">
                    <xsl:with-param name="aggregatingGroup" select="$global_group"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose-->
        
    </xsl:template>
    
</xsl:stylesheet>
