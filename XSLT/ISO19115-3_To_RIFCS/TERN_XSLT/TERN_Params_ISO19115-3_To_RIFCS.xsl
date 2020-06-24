<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cit="http://standards.iso.org/iso/19115/-3/cit" 
    exclude-result-prefixes="cit">
    
    <xsl:import href="ISO19115-3_Common_MiddleFilter.xsl"/>
    
    <xsl:param name="global_debug" select="true()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    <xsl:param name="global_originatingSource" select="'Terrestrial Ecosystem Research Network (TERN)'"/>
    <xsl:param name="global_acronym" select="'TERN'"/>
    <xsl:param name="global_baseURI" select="'geonetwork.tern.org.au'"/>
    <xsl:param name="global_path" select="'/geonetwork/srv/eng/catalog.search#/metadata/'"/>
    <xsl:param name="global_group" select="'Terrestrial Ecosystem Research Network'"/>
   
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
    
    <!--overriding to filter citation contributors -->
    <xsl:template match="cit:CI_Citation" mode="selectCitationContributors">
        <xsl:choose>
            <!-- use any invidual names that are either author or coAuthor -->
            <xsl:when test="
                ((count(cit:citedResponsibleParty/cit:CI_Responsibility[contains(lower-case(cit:role/cit:CI_RoleCode/@codeListValue), 'author')]/cit:party/cit:CI_Individual/cit:name[string-length(.) > 0]) > 0) or
                (count(cit:citedResponsibleParty/cit:CI_Responsibility[contains(lower-case(cit:role/cit:CI_RoleCode/@codeListValue), 'author')]/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:name[string-length(.) > 0]) > 0))">
                <!-- note that even when no results are found, value-of constructs empty text node, so copy-of is used below instead -->
                <xsl:copy-of select="cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'author']/cit:party/cit:CI_Individual/cit:name[string-length(.) > 0]"/>
                <xsl:copy-of select="cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'author']/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:name[string-length(.) > 0]"/>
            </xsl:when>
            <xsl:when test="
                ((count(cit:citedResponsibleParty/cit:CI_Responsibility[contains(lower-case(cit:role/cit:CI_RoleCode/@codeListValue), 'coAuthor')]/cit:party/cit:CI_Individual/cit:name[string-length(.) > 0]) > 0) or
                (count(cit:citedResponsibleParty/cit:CI_Responsibility[contains(lower-case(cit:role/cit:CI_RoleCode/@codeListValue), 'coAuthor')]/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:name[string-length(.) > 0]) > 0))">
                <!-- note that even when no results are found, value-of constructs empty text node, so copy-of is used below instead -->
                <xsl:copy-of select="cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'coAuthor']/cit:party/cit:CI_Individual/cit:name[string-length(.) > 0]"/>
                <xsl:copy-of select="cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'coAuthor']/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:name[string-length(.) > 0]"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- there are no invidual names that are either author or coAuthor, so use organisation names -->
                <xsl:copy-of select="cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'author']/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0]"/>
                <xsl:copy-of select="cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'coAuthor']/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
  </xsl:stylesheet>
