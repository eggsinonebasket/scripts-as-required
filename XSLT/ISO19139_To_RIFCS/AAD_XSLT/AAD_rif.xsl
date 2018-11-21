<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:srv="http://www.isotc211.org/2005/srv" 
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gts="http://www.isotc211.org/2005/gts" xmlns:geonet="http://www.fao.org/geonetwork"
    xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:gml="http://www.opengis.net/gml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:customAAD="http://customAAD.nowhere.yet"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="geonet gmx xsi gmd srv gml gco gts customAAD">
    <!-- stylesheet to convert iso19139 in OAI-PMH ListRecords response to RIF-CS -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="global_AAD_acronym" select="'AADC'"/>
    <xsl:param name="global_AAD_originatingSource" select="'Australian Antarctic Data Centre'"/>
    <xsl:param name="global_AAD_group" select="'Australian Antarctic Data Centre'"/>
    <xsl:param name="global_AAD_publisherName" select="'Australian Antarctic Data Centre'"/>
    <xsl:param name="global_AAD_contributorName" select="'Australian Antarctic Division'"/>
    <xsl:param name="global_AAD_publisherPlace" select="'Hobart'"/>
    <xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/>
    <xsl:variable name="gmdCodelists" select="document('codelists.xml')"/>
   
    <!-- =========================================== -->
    <!-- RegistryObjects (root) Template             -->
    <!-- =========================================== -->

    <xsl:template match="/">
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
        <xsl:apply-templates select="//gmd:MD_Metadata" mode="AAD"/>
        </registryObjects>
    </xsl:template>

    
    <xsl:template match="gmd:MD_Metadata" mode="AAD">
        <xsl:param name="aggregatingGroup"/>
        
        <xsl:apply-templates select="." mode="AAD_collection"/>
        <xsl:apply-templates select="." mode="AAD_party"/>
    </xsl:template>
    

    <!-- =========================================== -->
    <!-- Collection RegistryObject Template          -->
    <!-- =========================================== -->

    <xsl:template match="gmd:MD_Metadata" mode="AAD_collection">

        <!-- construct parameters for values that are required in more than one place in the output xml-->
        <xsl:param name="dataSetURI"
            select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[1]/gmd:CI_OnlineResource/gmd:linkage/gmd:URL"/>

        <xsl:variable name="code_sequence" as="xs:string*">
            <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier">
                <xsl:if test="string-length(normalize-space(.)) > 0">
                    <xsl:if test="not(contains(normalize-space(.), 'doi'))">
                        <xsl:copy-of select="normalize-space(.)"/>
                    </xsl:if>    
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
            
        <registryObject>
            <xsl:attribute name="group">
                <xsl:value-of select="$global_AAD_group"/>
            </xsl:attribute>
            
            <key>
                 <xsl:choose>
                     <xsl:when test="string-length(gmd:fileIdentifier) > 0">
                         <xsl:value-of select="concat($global_AAD_acronym, '/', normalize-space(gmd:fileIdentifier))"/>
                     </xsl:when>
                     <xsl:when test="count($code_sequence) > 0">
                         <xsl:value-of select="concat($global_AAD_acronym, '/', normalize-space($code_sequence[1]))"/>
                     </xsl:when>
                 </xsl:choose>
            </key>
            
            <originatingSource>
                <xsl:value-of select="$global_AAD_originatingSource"/>
            </originatingSource>

            <collection>

                <xsl:apply-templates select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue"
                    mode="AAD_collection_type_attribute"/>

                <xsl:apply-templates select="gmd:fileIdentifier" 
                    mode="AAD_collection_identifier"/>
                
                <xsl:apply-templates
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier"
                    mode="AAD_collection_identifier"/>
                
                <xsl:apply-templates
                    select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL"
                    mode="AAD_collection_identifier"/>
                
                <xsl:apply-templates
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title"
                    mode="AAD_collection_name"/>

                <xsl:apply-templates
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date"
                    mode="AAD_collection_dates"/>

                <xsl:apply-templates
                    select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[1]/gmd:CI_OnlineResource/gmd:linkage/gmd:URL"
                    mode="AAD_collection_location"/>
                
                <xsl:apply-templates
                    select="gmd:parentIdentifier"
                    mode="AAD_collection_related_object">
                </xsl:apply-templates>
                
             
                <xsl:for-each-group
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName)) > 0) and 
                    (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)) > 0)]"
                    group-by="gmd:individualName">
                    <xsl:apply-templates select="." mode="AAD_collection_related_object"/>
                </xsl:for-each-group>

                <xsl:for-each-group
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[((string-length(normalize-space(gmd:organisationName)) > 0) and not(string-length(normalize-space(gmd:individualName)) > 0)) and 
                    (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)) > 0)]"
                    group-by="gmd:organisationName">
                    <xsl:apply-templates select="." mode="AAD_collection_related_object"/>
                </xsl:for-each-group>

                <xsl:apply-templates
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory/gmd:MD_TopicCategoryCode"
                    mode="AAD_collection_subject"/>

                <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords"
                    mode="AAD_collection_subject"/>

                <xsl:apply-templates
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract"
                    mode="AAD_collection_description"/>

                <xsl:apply-templates
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox"
                    mode="AAD_collection_coverage_spatial"/>

                <xsl:apply-templates
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent"
                    mode="AAD_collection_coverage_temporal"/>
                
                <xsl:variable name="organisationOwnerName" select="customAAD:childValueForRole(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty, 'owner', 'organisationName')"/>
                <xsl:variable name="individualOwnerName" select="customAAD:childValueForRole(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty, 'owner', 'individualName')"/>
     
                <xsl:variable name="publishDate">
                    <xsl:for-each select="gmd:CI_Citation/gmd:date/gmd:CI_Date">
                        <xsl:if
                            test="contains(lower-case(normalize-space(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue)), 'publication')">
                            <xsl:value-of select="normalize-space(gmd:date/gco:Date)"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>

                <xsl:apply-templates
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints[
                    exists(gmd:otherConstraints)]"
                    mode="AAD_collection_rights_licence"/>

                <xsl:apply-templates
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints[
                    exists(gmd:useConstraints) and exists(gmd:otherConstraints)]"
                    mode="AAD_collection_rights_rightsStatement"/>

                <xsl:apply-templates
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints[
                    exists(gmd:accessConstraints) and exists(gmd:otherConstraints)]"
                    mode="AAD_collection_rights_accessRights"/>

                <xsl:for-each
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation">
                    <xsl:call-template name="AAD_collection_citationMetadata_citationInfo">
                        <xsl:with-param name="dataSetURI" select="$dataSetURI"/>
                        <xsl:with-param name="citation" select="."/>
                    </xsl:call-template>
                </xsl:for-each>

            </collection>
        </registryObject>
    </xsl:template>

    <!-- =========================================== -->
    <!-- Party RegistryObject Template          -->
    <!-- =========================================== -->

    <xsl:template match="gmd:MD_Metadata" mode="AAD_party">

        <xsl:for-each-group
            select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName)) > 0) and 
            (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)) > 0)]"
            group-by="gmd:individualName">
            <xsl:call-template name="AAD_party">
                <xsl:with-param name="type" select="'person'"/>
                <xsl:with-param name="role" select="gmd:role/gmd:CI_RoleCode/@codeListValue"/>
            </xsl:call-template>
        </xsl:for-each-group>

        <xsl:for-each-group
            select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName)) > 0) and 
            (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)) > 0)]"
            group-by="gmd:organisationName">
            <xsl:call-template name="AAD_party">
                <xsl:with-param name="type" select="'group'"/>
                <xsl:with-param name="role" select="gmd:role/gmd:CI_RoleCode/@codeListValue"/>
            </xsl:call-template>
        </xsl:for-each-group>
    </xsl:template>


    <!-- =========================================== -->
    <!-- Collection RegistryObject - Child Templates -->
    <!-- =========================================== -->



    <!-- Collection - Type Attribute -->
    <xsl:template match="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue"
        mode="AAD_collection_type_attribute">
        <xsl:attribute name="type">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    
    <!-- Collection - Identifier Element  -->
    <xsl:template match="gmd:fileIdentifier" mode="AAD_collection_identifier">
        <xsl:variable name="identifier" select="normalize-space(.)"/>
        <xsl:if test="string-length($identifier) > 0">
            <identifier>
                <xsl:attribute name="type">
                    <xsl:text>global</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="$identifier"/>
            </identifier>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gmd:identifier" mode="AAD_collection_identifier">
        <xsl:variable name="code" select="normalize-space(gmd:MD_Identifier/gmd:code)"/>
        <xsl:if test="string-length($code) > 0">
            <identifier>
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="contains(lower-case($code), 'doi')">
                            <xsl:text>doi</xsl:text>
                        </xsl:when>
                        <xsl:when test="contains(lower-case($code), 'http')">
                            <xsl:text>uri</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>local</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="contains(lower-case($code), 'doi:')">
                        <xsl:value-of select="substring-after($code, 'doi:')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$code"/>
                    </xsl:otherwise>
               </xsl:choose>
            </identifier>
        </xsl:if>
    </xsl:template>
    
    <!-- Collection - Address Identifier Element  -->
    <xsl:template match="gmd:URL" mode="AAD_collection_identifier">
        <identifier>
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="contains(lower-case(.), 'doi')">
                        <xsl:text>doi</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case(.), 'http')">
                        <xsl:text>uri</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>local</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="contains(lower-case(.), 'doi:')">
                    <xsl:value-of select="substring-after(., 'doi:')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </identifier>
    </xsl:template>
    
   <!-- Collection - Name Element  -->
    <xsl:template
        match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title"
        mode="AAD_collection_name">
        <name>
            <xsl:attribute name="type">
                <xsl:text>primary</xsl:text>
            </xsl:attribute>
            <namePart>
                <xsl:value-of select="."/>
            </namePart>
        </name>
    </xsl:template>

    <!-- Collection - Address Electronic Element  -->
    <xsl:template match="gmd:URL" mode="AAD_collection_location">
        <location>
            <address>
                <electronic>
                    <xsl:attribute name="type">
                        <xsl:text>url</xsl:text>
                    </xsl:attribute>
                    <value>
                        <xsl:value-of select="."/>
                    </value>
                </electronic>
            </address>
        </location>
    </xsl:template>

    <!-- Collection - Dates Element  -->
    <xsl:template
        match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date"
        mode="AAD_collection_dates">
        <xsl:variable name="dateTime" select="normalize-space(gmd:CI_Date/gmd:date/gco:Date)"/>
        <xsl:variable name="dateCode"
            select="normalize-space(gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue)"/>
        <xsl:variable name="transformedDateCode">
            <xsl:choose>
                <xsl:when test="contains($dateCode, 'creation')">
                    <xsl:text>created</xsl:text>
                </xsl:when>
                <xsl:when test="contains($dateCode, 'publication')">
                    <xsl:text>issued</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:if
            test="
            (string-length($dateTime) > 0) and
            (string-length($transformedDateCode) > 0)">
            <dates>
                <xsl:attribute name="type">
                    <xsl:value-of select="$transformedDateCode"/>
                </xsl:attribute>
                <date>
                    <xsl:attribute name="type">
                        <xsl:text>dateFrom</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="dateFormat">
                        <xsl:text>W3CDTF</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="$dateTime"/>
                </date>
            </dates>
        </xsl:if>
    </xsl:template>
    
    <!-- Collection - Related Object -->
    <xsl:template match="gmd:parentIdentifier" mode="AAD_collection_related_object">
        <relatedObject>
            <key>
                <xsl:value-of select="concat($global_AAD_acronym, '/', normalize-space(.))"/>
            </key>
            <relation type="isPartOf"/>
        </relatedObject>
    </xsl:template>
    
    <xsl:template match="gmd:CI_ResponsibleParty" mode="AAD_collection_related_object">
        
        <xsl:variable name="name" select="current-grouping-key()"/>
        <xsl:for-each-group select="current-group()/gmd:role"
            group-by="gmd:CI_RoleCode/@codeListValue">
            <xsl:variable name="code">
                <xsl:value-of select="current-grouping-key()"/>
            </xsl:variable>
            
            <xsl:variable name="transformedName" select="customAAD:transformPerRole($name, $code)"/>
            <xsl:variable name="identifier_sequence" as="xs:string*" select="customAAD:identifiers($transformedName)"/>
            
            <xsl:choose>
                <xsl:when test="count($identifier_sequence) = 2">
                    <relatedInfo type="party">
                        <identifier type="{$identifier_sequence[1]}">
                            <xsl:value-of select="$identifier_sequence[2]"/>
                        </identifier>
                        <relation>
                            <xsl:attribute name="type">
                                <xsl:value-of select="$code"/>
                            </xsl:attribute>
                        </relation>
                    </relatedInfo>
                </xsl:when>
                <xsl:otherwise>
                    <relatedObject>
                        <key>
                            <xsl:value-of select="concat($global_AAD_acronym,'/', translate(normalize-space($transformedName),' ',''))"/>
                        </key>
                        <relation>
                            <xsl:attribute name="type">
                                <xsl:value-of select="$code"/>
                            </xsl:attribute>
                        </relation>
                    </relatedObject>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
    

    <!-- Collection - Subject Element -->

    <xsl:template match="gmd:MD_Keywords" mode="AAD_collection_subject">
        <xsl:message>gmd:MD_Keywords</xsl:message>

		<xsl:variable name="subjectType">
			<xsl:choose>
				<xsl:when test="gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = 'NASA/GCMD Earth Science Keywords'">
		    		<xsl:text>gcmd</xsl:text>
		       	</xsl:when>
		  		<xsl:otherwise>
	       			<xsl:text>local</xsl:text>
	       		</xsl:otherwise>
	       	</xsl:choose>
		</xsl:variable>

        <xsl:for-each select="gmd:keyword">
        	<subject type="{$subjectType}">
        		<xsl:value-of select="normalize-space(.)"/>
            </subject>
        </xsl:for-each>
    </xsl:template>

     <xsl:template match="gmd:MD_TopicCategoryCode" mode="AAD_collection_subject">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <subject type="local">
                <xsl:value-of select="."/>
            </subject>
        </xsl:if>
    </xsl:template>

    <!-- Collection - Decription Element -->
    <xsl:template match="gmd:abstract" mode="AAD_collection_description">
        <description type="brief">
            <xsl:value-of select="."/>
        </description>
    </xsl:template>
    
   <!-- Collection - Coverage Spatial Element -->
    <xsl:template match="gmd:EX_TemporalExtent" mode="AAD_collection_coverage_temporal">
        <xsl:if
            test="(string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) > 0) or
                  (string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)) > 0)">
            <coverage>
                <temporal>
                    <xsl:if
                        test="string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) > 0">
                        <date>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="type">
                                <xsl:text>dateFrom</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="gmd:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition"
                            />
                        </date>
                    </xsl:if>
                    <xsl:if
                        test="string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)) > 0">
                        <date>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="type">
                                <xsl:text>dateTo</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="gmd:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition"
                            />
                        </date>
                    </xsl:if>
                </temporal>
            </coverage>
        </xsl:if>
    </xsl:template>

    <!-- Collection - Coverage Spatial Element -->
    <xsl:template match="gmd:EX_GeographicBoundingBox" mode="AAD_collection_coverage_spatial">

        <xsl:variable name="spatialString">
            <xsl:variable name="horizontal">
                <xsl:if
                    test="
                    (string-length(normalize-space(gmd:northBoundLatitude/gco:Decimal)) > 0) and
                    (string-length(normalize-space(gmd:southBoundLatitude/gco:Decimal)) > 0) and
                    (string-length(normalize-space(gmd:westBoundLongitude/gco:Decimal)) > 0) and
                    (string-length(normalize-space(gmd:eastBoundLongitude/gco:Decimal)) > 0)">
                    <xsl:value-of
                        select="normalize-space(concat('northlimit=',gmd:northBoundLatitude/gco:Decimal,'; southlimit=',gmd:southBoundLatitude/gco:Decimal,'; westlimit=',gmd:westBoundLongitude/gco:Decimal,'; eastLimit=',gmd:eastBoundLongitude/gco:Decimal))"
                    />
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="vertical">
                <xsl:if
                    test="
                    (string-length(normalize-space(gmd:EX_VerticalExtent/gmd:maximumValue/gco:Real)) > 0) and
                    (string-length(normalize-space(gmd:EX_VerticalExtent/gmd:minimumValue/gco:Real)) > 0)">
                    <xsl:value-of
                        select="normalize-space(concat('; uplimit=',gmd:EX_VerticalExtent/gmd:maximumValue/gco:Real,'; downlimit=',gmd:EX_VerticalExtent/gmd:minimumValue/gco:Real))"
                    />
                </xsl:if>
            </xsl:variable>
            <xsl:value-of select="concat($horizontal, $vertical, '; projection=WGS84')"/>
        </xsl:variable>
        <coverage>
            <spatial>
                <xsl:attribute name="type">
                    <xsl:text>iso19139dcmiBox</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="$spatialString"/>
            </spatial>
            <spatial>
                <xsl:attribute name="type">
                    <xsl:text>text</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="$spatialString"/>
            </spatial>
        </coverage>
    </xsl:template>

   <!-- Collection - Rights Licence Element -->
    <xsl:template match="gmd:MD_LegalConstraints" mode="AAD_collection_rights_licence">
        <xsl:variable name="otherConstraints" select="normalize-space(gmd:otherConstraints)"/>
        <xsl:if test="string-length($otherConstraints) > 0">
            <xsl:if test="contains(lower-case($otherConstraints), 'picccby')">
                <rights>
                    <!--licence><xsl:text disable-output-escaping="yes">&lt;![CDATA[&lt;a href="http://polarcommons.org/ethics-and-norms-of-data-sharing.php"&gt; &lt;img src="http://polarcommons.org/images/PIC_print_small.png" style="border-width:0; width:40px; height:40px;" alt="Polar Information Commons's PICCCBY license."/&gt;&lt;/a&gt;&lt;a rel="license" href="http://creativecommons.org/licenses/by/3.0/"&gt; &lt;img alt="Creative Commons License" style="border-width:0; width: 88px; height: 31px;" src="http://i.creativecommons.org/l/by/3.0/88x31.png" /&gt;&lt;/a&gt;]]&gt;</xsl:text>
                    </licence-->
                    <licence type="CC-BY" rightsUri="http://creativecommons.org/licenses/by/3.0/"/>
                </rights>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <!-- Collection - RightsStatement -->
    <xsl:template match="gmd:MD_LegalConstraints" mode="AAD_collection_rights_rightsStatement">
        <xsl:for-each select="gmd:otherConstraints">
            <!-- If there is text in other contraints, use this; otherwise, do nothing -->
            <xsl:if test="string-length(normalize-space(.)) > 0">
                <rights>
                    <rightsStatement>
                        <xsl:value-of select="normalize-space(.)"/>
                    </rightsStatement>
                </rights>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- Collection - Rights AccessRights Element -->
    <xsl:template match="gmd:MD_LegalConstraints" mode="AAD_collection_rights_accessRights">
        <xsl:for-each select="gmd:otherConstraints">
            <!-- If there is text in other contraints, use this; otherwise, do nothing -->
            <xsl:if test="string-length(normalize-space(.)) > 0">
                <xsl:variable name="accessRightsType" select="customAAD:accessRightsType(normalize-space(.))"/>
                <rights>
                    <accessRights>
                        <xsl:if test="string-length($accessRightsType) > 0">
                            <xsl:attribute name="type">
                                <xsl:value-of select="$accessRightsType"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="normalize-space(.)"/>
                    </accessRights>
                </rights>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <!-- Collection - CitationInfo Element -->
    <xsl:template name="AAD_collection_citationMetadata_citationInfo">
        <xsl:param name="dataSetURI"/>
        <xsl:param name="citation"/>
        <!-- We can only accept one DOI; howerver, first we will find all -->
        <xsl:variable name="doiIdentifier_sequence" select="customAAD:doiFromIdentifiers(gmd:identifier/gmd:MD_Identifier/gmd:code)"/>
        <xsl:variable name="identifierToUse">
            <xsl:choose>
                <xsl:when
                    test="count($doiIdentifier_sequence) and (string-length($doiIdentifier_sequence[1]) > 0)">
                    <xsl:value-of select="$doiIdentifier_sequence[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$dataSetURI"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="typeToUse">
            <xsl:choose>
                <xsl:when
                    test="count($doiIdentifier_sequence) and (string-length($doiIdentifier_sequence[1]) > 0)">
                    <xsl:text>doi</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>uri</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <citationInfo>
            <citationMetadata>
                <xsl:if test="string-length($identifierToUse) > 0">
                    <identifier>
                        <xsl:if test="string-length($typeToUse) > 0">
                            <xsl:attribute name="type">
                                <xsl:value-of select="$typeToUse"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="$identifierToUse"/>
                    </identifier>
                </xsl:if>

                <title>
                    <xsl:value-of select="gmd:title"/>
                </title>
                <xsl:for-each select="gmd:date/gmd:CI_Date">
                    <xsl:if
                        test="contains(lower-case(normalize-space(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue)), 'publication')">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:variable name="codelist"
                                    select="$gmdCodelists/codelists/codelist[@name = 'gmd:CI_DateTypeCode']"/>
                                <xsl:variable name="codevalue"
                                    select="gmd:dateType/gmd:CI_DateTypeCode/@codeListValue"/>
                                <xsl:value-of
                                    select="$codelist/entry[code = $codevalue]/description"/>
                            </xsl:attribute>
                            <xsl:value-of select="gmd:date/gco:Date"/>
                        </date>
                    </xsl:if>
                </xsl:for-each>

                <!-- Contributing individuals - note that we are ignoring those individuals where a role has not been specified -->
                <xsl:variable name="individualContributor_sequence" as="xs:string*">
                     <xsl:for-each-group
                         select="
                         gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName)) > 0) and 
                         (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)) > 0)]"
                         group-by="gmd:individualName">
     
                         <xsl:variable name="individualName"
                             select="normalize-space(current-grouping-key())"/>
                         
                         <xsl:variable name="transformedName" select="customAAD:transformPerRole($individualName, gmd:role/gmd:CI_RoleCode/@codeListValue)"/>
                                                      
                         <xsl:if test="
                             (count(customAAD:isRole(current-group(), 'publish')) = 0) and 
                             (count(customAAD:isRole(current-group(), 'originator')) = 0)">
                            <xsl:value-of select="$transformedName"/>
                         </xsl:if>
                     </xsl:for-each-group>
                </xsl:variable>
                
                <!-- Contributing organisations - included only when there is no individual name (in which case the individual has been included above) 
                        Note again that we are ignoring organisations where a role has not been specified -->
                <xsl:variable name="organisationContributor_sequence" as="xs:string*">
                     <xsl:for-each-group
                         select="gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[
                                 (string-length(normalize-space(gmd:organisationName)) > 0) and
                                 not(string-length(normalize-space(gmd:individualName)) > 0) and
                                 (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)) > 0)]"
                         group-by="gmd:organisationName">
     
                         <xsl:variable name="transformedOrganisationName" select="customAAD:transformPerRole(current-grouping-key(), gmd:role/gmd:CI_RoleCode/@codeListValue)"/>
     
                         <xsl:if test="
                             (count(customAAD:isRole(current-group(), 'publish')) = 0) and 
                             (count(customAAD:isRole(current-group(), 'originator')) = 0)">
                             <xsl:value-of select="$transformedOrganisationName"/>
                         </xsl:if>
                     </xsl:for-each-group>
                </xsl:variable>
                
                <xsl:message select="concat('Count $individualContributor_sequence: ', count($individualContributor_sequence))"/>
                <xsl:message select="concat('Count $organisationContributor_sequence: ', count($organisationContributor_sequence))"/>
                
                <xsl:variable name="allContributor_sequence" as="xs:string*">
                    <xsl:for-each select="distinct-values($individualContributor_sequence)">
                        <xsl:value-of select="."/>
                    </xsl:for-each> 
                    <xsl:for-each select="distinct-values($organisationContributor_sequence)">
                        <xsl:value-of select="."/>
                    </xsl:for-each> 
                </xsl:variable>
                
                <xsl:message select="concat('Count $allContributor_sequence: ', count($allContributor_sequence))"/>
                <xsl:for-each select="distinct-values($allContributor_sequence)">
                    <contributor>
                        <namePart>
                            <xsl:value-of select="."/>
                        </namePart>
                    </contributor>
                </xsl:for-each>
                
                <xsl:variable name="publishName" select="customAAD:publishNameToUse(gmd:citedResponsibleParty)"/>
                
                <!-- If no contributors other than originator, seek originator and use if one exists 
                     If no contributors at all, default to publisher (if publisher is Australian Antarctic Data Centre,
                     make contributor Australian Antarctic Division -->
                
                <xsl:if test="
                    (count($individualContributor_sequence) = 0) and
                    (count($organisationContributor_sequence) = 0)">
                    <xsl:variable name="originator" select="customAAD:originatorNameToUse(.)"/>
                    <xsl:choose>
                        <xsl:when test="string-length($originator) > 0">
                          <contributor>
                              <namePart>
                                  <xsl:value-of select="$originator"/>
                              </namePart>
                          </contributor> 
                        </xsl:when>
                        <xsl:when test="string-length($publishName) > 0">
                            <xsl:if test="contains($publishName, $global_AAD_publisherName)">
                                <contributor>
                                    <namePart>
                                        <xsl:value-of select="$global_AAD_contributorName"/>
                                    </namePart>
                                </contributor> 
                            </xsl:if>
                            <contributor>
                                <namePart>
                                    <xsl:value-of select="$publishName"/>
                                </namePart>
                            </contributor> 
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
          
                <xsl:if test="string-length($publishName) > 0">
                    <publisher>
                        <xsl:value-of select="$publishName"/>
                    </publisher>
                </xsl:if>

                <xsl:variable name="publishPlace" select="customAAD:publishPlaceToUse(., $publishName)"/>

                <xsl:if test="string-length($publishPlace) > 0">
                    <placePublished>
                        <xsl:value-of select="$publishPlace"/>
                    </placePublished>
                </xsl:if>

            </citationMetadata>
        </citationInfo>
    </xsl:template>



    <!-- ====================================== -->
    <!-- Party RegistryObject - Child Templates -->
    <!-- ====================================== -->

    <!-- Party Registry Object (Individuals (person) and Organisations (group)) -->
    <xsl:template name="AAD_party">
        <xsl:param name="type"/>
        <xsl:param name="role"/>
        <registryObject group="{$global_AAD_group}">

            <xsl:variable name="transformedName" select="customAAD:transformPerRole(current-grouping-key(), $role)"/>
            
            <key>
                <xsl:value-of
                    select="concat($global_AAD_acronym, '/', translate(normalize-space($transformedName),' ',''))"
                />
            </key>

            <originatingSource>
                <xsl:value-of select="$global_AAD_originatingSource"/>
            </originatingSource>

            <!-- Use the party type provided, except for exception:
                Because sometimes "Australian Antarctic Data Centre" or AADC, or "Australian Antarctic Division" or AAD, is used for an author, appearing in individualName,
                we want to make sure that we use 'group', not 'person', if this anomoly occurs -->

            <xsl:variable name="typeToUse">
                <xsl:choose>
                    <xsl:when
                        test="contains($transformedName, 'Australian Antarctic Division') or
                              contains($transformedName, 'Australian Antarctic Data Centre') or
                              contains($transformedName, 'University of Tasmania')">
                        <xsl:text>group</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$type"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:variable name="identifier_sequence" as="xs:string*" select="customAAD:identifiers($transformedName)"/>
          
            <party type="{$typeToUse}">
                
                <xsl:if test="count($identifier_sequence) = 2">
                    <identifier type="{$identifier_sequence[1]}">
                        <xsl:value-of select="$identifier_sequence[2]"/>
                    </identifier>
                </xsl:if>
                
                <name type="primary">
                    <namePart>
                        <xsl:value-of select="$transformedName"/>
                    </namePart>
                </name>

                <!-- If we have are dealing with individual who has an organisation name:
                    - leave out the address (so that it is on the organisation only); and 
                    - relate the individual to the organisation -->

                <!-- If we are dealing with an individual...-->
                <xsl:choose>
                    <xsl:when test="contains($type, 'person')">
                        <xsl:variable name="transformedOrganisationName" select="customAAD:transformPerRole(gmd:organisationName, $role)"/>

                        <xsl:choose>
                            <xsl:when
                                test="string-length(normalize-space($transformedOrganisationName)) > 0">
                                <!--  Individual has an organisation name, so related the individual to the organisation, and omit the address 
                                    (the address will be included within the organisation to which this individual is related) -->
                                <relatedObject>
                                    <key>
                                        <xsl:value-of
                                            select="concat($global_AAD_acronym,'/', $transformedOrganisationName)"
                                        />
                                    </key>
                                    <relation type="isMemberOf"/>
                                </relatedObject>
                            </xsl:when>

                            <xsl:otherwise>
                                <!-- Individual does not have an organisation name, so include the address here -->
                                <xsl:call-template name="AAD_physicalAddress"/>
                                <xsl:call-template name="AAD_phone"/>
                                <xsl:call-template name="AAD_electronic"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- We are dealing with an organisation, so always include the address -->
                        <xsl:call-template name="AAD_physicalAddress"/>
                        <xsl:call-template name="AAD_phone"/>
                        <xsl:call-template name="AAD_electronic"/>
                    </xsl:otherwise>
                </xsl:choose>
            </party>
        </registryObject>
    </xsl:template>

    <xsl:template name="AAD_physicalAddress">
        <xsl:for-each select="current-group()">
            <xsl:sort
                select="count(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/child::*)"
                data-type="number" order="descending"/>

            <xsl:if test="position() = 1">
                <xsl:if
                    test="count(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/child::*) > 0">

                    <location>
                        <address>
                            <physical type="streetAddress">
                                <addressPart type="addressLine">
                                         <xsl:value-of select="normalize-space(current-grouping-key())"/>
                                </addressPart>
                                
                                <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gco:CharacterString[string-length(text()) > 0]">
                                     <addressPart type="addressLine">
                                         <xsl:value-of select="normalize-space(.)"/>
                                     </addressPart>
                                </xsl:for-each>
                                
                                 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city)) > 0">
                                      <addressPart type="suburbOrPlaceLocality">
                                          <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city)"/>
                                      </addressPart>
                                 </xsl:if>
                                
                                 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea)) > 0">
                                     <addressPart type="stateOrTerritory">
                                         <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea)"/>
                                     </addressPart>
                                 </xsl:if>
                                     
                                 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode)) > 0">
                                     <addressPart type="postCode">
                                         <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode)"/>
                                     </addressPart>
                                 </xsl:if>
                                 
                                 <xsl:if test="string-length(normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country)) > 0">
                                     <addressPart type="country">
                                         <xsl:value-of select="normalize-space(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country)"/>
                                     </addressPart>
                                 </xsl:if>
                            </physical>
                        </address>
                    </location>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="AAD_phone">

        <xsl:for-each select="current-group()">
            <xsl:sort
                select="count(gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/child::*)"
                data-type="number" order="descending"/>

            <xsl:if test="position() = 1">
                <xsl:if
                    test="count(gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/child::*) > 0">
                    <xsl:for-each
                        select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gco:CharacterString[string-length(text()) > 0]">
                        <location>
                            <address>
                                <physical type="streetAddress">
                                     <addressPart type="telephoneNumber">
                                         <xsl:value-of select="normalize-space(.)"/>
                                     </addressPart>
                                </physical>
                             </address>
                        </location>
                    </xsl:for-each>
                    <xsl:for-each
                        select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:facsimile/gco:CharacterString[string-length(text()) > 0]">
                        <location>
                            <address>
                                <physical type="streetAddress">
                                     <addressPart type="faxNumber">
                                         <xsl:value-of select="normalize-space(.)"/>
                                     </addressPart>
                                </physical>
                             </address>
                        </location>
                    </xsl:for-each>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="AAD_electronic">

        <xsl:for-each select="current-group()">
            <xsl:sort
                select="count(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString[string-length(text()) > 0])"
                data-type="number" order="descending"/>

            <xsl:if test="position() = 1">
                <xsl:if
                    test="count(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString[string-length(text()) > 0])">
                    <location>
                        <address>
                            <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString[string-length(text()) > 0]">
                                <electronic type="email">
                                    <value>
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </value>
                                </electronic>
                            </xsl:for-each>
                        </address>
                    </location>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <!-- Modules -->

    <xsl:function name="customAAD:doiFromIdentifiers">
        <xsl:param name="identifier_sequence" as="xs:string*"/>
        <xsl:for-each select="distinct-values($identifier_sequence)">
            <xsl:variable name="code" select="normalize-space(.)"/>
            <xsl:if test="contains(lower-case($code), 'doi')">
                <xsl:choose>
                    <xsl:when test="contains(lower-case($code), 'doi:')">
                        <xsl:value-of select="substring-after($code, 'doi:')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$code"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="customAAD:publishNameToUse">
        <xsl:param name="current_node_sequence" as="node()*"/>
        <xsl:message>Module: publishNameToUse</xsl:message>
        
        <xsl:variable name="organisationPublisherName_sequence" select="customAAD:childValueForRole($current_node_sequence, 'publish', 'organisationName')"/>
       
        <xsl:for-each select="$organisationPublisherName_sequence">
            <xsl:message select="concat('Organisation publisher name: ', .)"/>
        </xsl:for-each>
        
        <xsl:variable name="transformedOrganisationPublisherName" select="customAAD:transformPerRole($organisationPublisherName_sequence[1], 'publish')"/>

        <xsl:variable name="individualPublisherName_sequence" select="customAAD:childValueForRole($current_node_sequence, 'publish', 'individualName')"/>

        <xsl:for-each select="$individualPublisherName_sequence">
            <xsl:message select="concat('Individual publisher name: ', .)"/>
        </xsl:for-each>
        
      
        <xsl:variable name="transformedIndividualPublisherName" select="customAAD:transformPerRole($individualPublisherName_sequence[1], 'publish')"/>
            
        <xsl:choose>
            <xsl:when test="string-length(normalize-space($transformedOrganisationPublisherName)) > 0">
                <xsl:value-of select="$transformedOrganisationPublisherName"/>
            </xsl:when>
            <xsl:when test="string-length(normalize-space($transformedIndividualPublisherName)) > 0">
                <xsl:value-of select="$transformedIndividualPublisherName"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$global_AAD_publisherName"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="customAAD:originatorNameToUse">
        <xsl:param name="current_node" as="node()"/>
        <xsl:message>Module: originatorNameToUse</xsl:message>
        
        <xsl:variable name="organisationOriginatorName_sequence" select="customAAD:childValueForRole($current_node, 'originator', 'organisationName')"/>
        
        <xsl:for-each select="$organisationOriginatorName_sequence">
            <xsl:message select="concat('Organisation originator name: ', .)"/>
        </xsl:for-each>
        
        <xsl:variable name="transformedOrganisationOriginatorName" select="customAAD:transformPerRole($organisationOriginatorName_sequence[1], 'originator')"/>
        
        <xsl:variable name="individualOriginatorName_sequence" select="customAAD:childValueForRole($current_node, 'originator', 'individualName')"/>
        
        <xsl:for-each select="$individualOriginatorName_sequence">
            <xsl:message select="concat('Individual originator name: ', .)"/>
        </xsl:for-each>
        
        <xsl:variable name="transformedIndividualOriginatorName" select="customAAD:transformPerRole($individualOriginatorName_sequence[1], 'originator')"/>
        
        <xsl:choose>
            <xsl:when test="string-length(normalize-space($transformedOrganisationOriginatorName)) > 0">
                <xsl:value-of select="$transformedOrganisationOriginatorName"/>
            </xsl:when>
            <xsl:when test="string-length(normalize-space($transformedIndividualOriginatorName)) > 0">
                <xsl:value-of select="$transformedIndividualOriginatorName"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="customAAD:publishPlaceToUse">
        <xsl:param name="current_node" as="node()"/>
        <xsl:param name="publishNameToUse"/>
        <xsl:variable name="publishCity" select="customAAD:childValueForRole($current_node, 'publish', 'city')"/>
            
        <xsl:message>Publish City: <xsl:value-of select="$publishCity"/></xsl:message>

        <xsl:variable name="publishCountry" select="customAAD:childValueForRole($current_node, 'publish', 'country')"/>
        
        <xsl:message>Publish Country: <xsl:value-of select="$publishCountry"/></xsl:message>

        <xsl:choose>
            <xsl:when test="string-length($publishCity) > 0">
                <xsl:value-of select="$publishCity"/>
            </xsl:when>
            <xsl:when test="string-length($publishCountry) > 0">
                <xsl:value-of select="$publishCity"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- Only default publisher place if publisher name is equal to the global value (whether it was set or retrieved) -->
                <xsl:if test="$publishNameToUse = $global_AAD_publisherName">
                    <xsl:value-of select="$global_AAD_publisherPlace"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="customAAD:transformPerRole">
        <xsl:param name="inputString"/>
        <xsl:param name="role"/>
        
        <xsl:choose>
            <xsl:when test="contains($role, 'publish')">
                <xsl:choose>
                    <xsl:when test="normalize-space($inputString) = 'AADC'">
                        <xsl:text>Australian Antarctic Data Centre</xsl:text>
                    </xsl:when>
                    <xsl:when test="normalize-space($inputString) = 'AADC, DATA OFFICER'">
                        <xsl:text>Australian Antarctic Data Centre</xsl:text>
                    </xsl:when>
                    <xsl:when test="normalize-space($inputString) = 'MAPPING OFFICER, AADC'">
                        <xsl:text>Australian Antarctic Data Centre</xsl:text>
                    </xsl:when>
                    <xsl:when test="normalize-space($inputString) = 'AAD'">
                        <xsl:text>Australian Antarctic Data Centre</xsl:text>
                    </xsl:when>
                    <xsl:when test="normalize-space($inputString) = 'Australian Antarctic Division'">
                        <xsl:text>Australian Antarctic Data Centre</xsl:text>
                    </xsl:when>
                    <xsl:when test="normalize-space($inputString) = 'University of Tasmania'">
                        <xsl:text>University of Tasmania, Australia</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space($inputString)"/>
                    </xsl:otherwise>
                </xsl:choose>    
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="normalize-space($inputString) = 'AADC'">
                        <xsl:text>Australian Antarctic Division</xsl:text>
                    </xsl:when>
                    <xsl:when test="normalize-space($inputString) = 'AAD'">
                        <xsl:text>Australian Antarctic Division</xsl:text>
                    </xsl:when>
                    <xsl:when test="normalize-space($inputString) = 'AADC, DATA OFFICER'">
                        <xsl:text>Australian Antarctic Division</xsl:text>
                    </xsl:when>
                    <xsl:when test="normalize-space($inputString) = 'MAPPING OFFICER, AADC'">
                        <xsl:text>Australian Antarctic Division</xsl:text>
                    </xsl:when>
                    <xsl:when test="normalize-space($inputString) = 'Australian Antarctic Data Centre'">
                        <xsl:text>Australian Antarctic Division</xsl:text>
                    </xsl:when>
                    <xsl:when test="normalize-space($inputString) = 'University of Tasmania'">
                        <xsl:text>University of Tasmania, Australia</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space($inputString)"/>
                    </xsl:otherwise>
                </xsl:choose> 
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Get the values of the child element of the point of contact responsible parties whose role contains this substring provided 
         For example, if you provide roleSubsting as 'publish' and childElementName as 'organisationName',
            you will receive all organisation names within child responsible parties that have role 'publish'.  
            They will be separated by 'commas', with an 'and' between the last and second last, where applicable -->
    <xsl:function name="customAAD:childValueForRole" as="xs:string*">
        <xsl:param name="contextNode_sequence" as="node()*"/>
        <xsl:param name="roleSubstring"/>
        <xsl:param name="childElementName"/>
        <xsl:message>Child element name: <xsl:value-of select="$childElementName"/></xsl:message>
         <xsl:variable name="nameSequence" as="xs:string*">
             <xsl:for-each select="$contextNode_sequence">
                <xsl:for-each-group
                    select="./gmd:CI_ResponsibleParty[
                    (string-length(normalize-space(descendant::node()[local-name()=$childElementName])) > 0) and 
                    (string-length(normalize-space(gmd:role/gmd:CI_RoleCode/@codeListValue)) > 0)]"
                    group-by="descendant::node()[local-name()=$childElementName]">
                    <xsl:choose>
                        <!-- obtain for two locations so far - we don't want for example we don't want
                            responsible parties under citation of thesauruses used -->
                        <xsl:when
                            test="contains(local-name(..), 'pointOfContact') or 
                                        contains(local-name(../../..), 'citation')">
                            <!--xsl:message>Parent: <xsl:value-of select="ancestor::node()"></xsl:value-of></xsl:message-->
                            <xsl:if
                                test="contains(lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue), lower-case($roleSubstring))">
                                <xsl:sequence
                                    select="descendant::node()[local-name()=$childElementName]"/>
                                <xsl:message>Child value: <xsl:value-of
                                        select="descendant::node()[local-name()=$childElementName]"
                                    /></xsl:message>
                            </xsl:if>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each-group>
             </xsl:for-each>
         </xsl:variable>
        
        <xsl:variable name="formattedValues">
            <xsl:for-each select="$nameSequence">
                <xsl:if test="position() > 1">
                    <xsl:choose>
                        <xsl:when test="position() = count($nameSequence)">
                            <xsl:text> and </xsl:text>
                        </xsl:when>
                        <xsl:when test="position() &lt; count($nameSequence)">
                            <xsl:text>, </xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="string-length($formattedValues) > 0">
            <xsl:message>Formatted values: <xsl:value-of select="$formattedValues"/></xsl:message>
        </xsl:if>
        <xsl:value-of select="$formattedValues"/>
    </xsl:function>

    <xsl:function name="customAAD:identifiers" as="xs:string*">
        <xsl:param name="transformedName" as="xs:string"/>
        <xsl:choose>
            <xsl:when 
                test="contains($transformedName, 'Australian Antarctic Division')">
                <xsl:text>AU-ANL:PEAU</xsl:text>
                <xsl:text>http://nla.gov.au/nla.party-617536</xsl:text>
            </xsl:when>
            <xsl:when 
                test="contains($transformedName, 'University of Tasmania')">
                <xsl:text>AU-ANL:PEAU</xsl:text>
                <xsl:text>http://nla.gov.au/nla.party-460913</xsl:text>
            </xsl:when>
        </xsl:choose>
     </xsl:function>
    
    <xsl:function name="customAAD:accessRightsType" as="xs:string">
        <xsl:param name="text" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="
                contains(lower-case($text), 'conditions apply') or
                contains(lower-case($text), 'can only be accessed at the australian antarctic') or
                contains(lower-case($text), 'are currently available only to') or
                contains(lower-case($text), 'can only be accessed by contacting the australian antarctic') or
                contains(lower-case($text), 'available on request')">
                <xsl:text>conditional</xsl:text>
            </xsl:when>
            <xsl:when test="
                contains(lower-case($text), 'data are not yet publicly available') or 
                contains(lower-case($text), 'data are currently not publicly available') or
                contains(lower-case($text), 'dataset is currently not publicly available') or
                contains(lower-case($text), 'dataset is not yet publicly available') or
                contains(lower-case($text), 'dataset for this project is not yet publicly available') or
                contains(lower-case($text), 'the data for this project is not yet publicly available') or
                contains(lower-case($text), 'dataset not yet publicly available')">
                <xsl:text>restricted</xsl:text>
            </xsl:when>
            <xsl:when test="
                contains(lower-case($text), 'data are publicly available') or 
                contains(lower-case($text), 'dataset is publicly available') or
                contains(lower-case($text), 'dataset for this project is publicly available') or
                contains(lower-case($text), 'data for this project is publicly available') or
                contains(lower-case($text), 'dataset publicly available') or
                contains(lower-case($text), 'available for download as shapefiles') or
                contains(lower-case($text), 'available for downloading as shapefiles') or
                contains(lower-case($text), 'shapefiles are available for download')">
                <xsl:text>open</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text></xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="customAAD:isRole" as="xs:boolean*">
        <xsl:param name="current_group" as="node()*"/>
        <xsl:param name="role" as="xs:string"/>
        <xsl:for-each-group select="$current_group/gmd:role"
            group-by="gmd:CI_RoleCode/@codeListValue">
            <xsl:if test="contains(lower-case(current-grouping-key()), $role)">
                <xsl:value-of select="true()"/>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:function>
</xsl:stylesheet>
