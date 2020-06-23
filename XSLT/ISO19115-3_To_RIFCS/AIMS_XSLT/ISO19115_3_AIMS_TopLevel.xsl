<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0"
    xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="mdb mcc">
    
    
    <xsl:import href="ISO19115-3_Common_MiddleFilter.xsl"/>
    
    <xsl:param name="global_debug" select="true()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    <xsl:param name="global_originatingSource" select="'Australian Institute of Marine Science'"/>
    <xsl:param name="global_acronym" select="'AIMS'"/>
    <xsl:param name="global_baseURI" select="'geo.aims.gov.au/geonetwork'"/>
    <xsl:param name="global_baseURI_PID" select="''"/>
    <xsl:param name="global_path_PID" select="''"/>
    <xsl:param name="global_path" select="'/geonetwork/srv/eng/search?uuid='"/>
    <xsl:param name="global_group" select="'Australian Institute of Marine Science'"/>
    <xsl:param name="global_publisherName" select="'Australian Institute of Marine Science'"/>
    <xsl:param name="global_publisherPlace" select="''"/>
    
    
    <!--xsl:template match="/">
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            
            <xsl:for-each select="//mdb:MD_Metadata[count(mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode[contains(lower-case(@codeListValue), 'document') or contains(lower-case(@codeListValue), 'nongeographicdataset')]) = 0]">
                <xsl:apply-templates select="." mode="registryObjects"/>
            </xsl:for-each>
        </registryObjects>
    </xsl:template-->
    
    <!--Copy this file and rename it as for example ISO19115-3_IMOS_TopLevel.xsl for whichever contributor (IMOS in this case)
        as this file contains processing specific to the contributor of ISO19115-3 (overriding templates of imported xsl files)
       
       Calls ISO19115-3_Common_MiddleFilter.xsl that removes version after namespace so that files with slightly 
       different versions, yet not much difference, can be handled in ISO19115-3_Common_Base.xsl - e.g. whether they have
       http://standards.iso.org/iso/19115/-3/mdb/1.0 or http://standards.iso.org/iso/19115/-3/mdb/2.0 they will
       be transformed by the ISO19115-3_Common_MiddleFilter.xsl to have http://standards.iso.org/iso/19115/-3/mdb and then 
       passed to ISO19115-3_Common_Base.xsl for shared processing.
       
       If you need to handle anything specific to the version, put them in higher levels to handle those
        -   either in this very ISO19115-3_Custom_TopLevel.xsl if specific to contributor, or in the 
            ISO19115-3_Common_MiddleFilter.xsl if it's a 2.0 thing for example, that
            multiple providers may have but that is not handled in ISO19115-3_Common_Base.xsl
    -->
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="." mode="middleFilter"/>
    </xsl:template>
      
</xsl:stylesheet>
