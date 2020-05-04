<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0" 
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
    xmlns:grg="http://www.isotc211.org/2005/grg"
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:gml="http://www.opengis.net/gml"
    xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gts="http://www.isotc211.org/2005/gts"
    xmlns:geonet="http://www.fao.org/geonetwork" xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:customIMOS="http://customIMOS.nowhere.yet"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:customGMD="http://customGMD.nowhere.yet"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="xlink geonet gmx oai xsi gmd srv gml gco gts csw grg mcp customIMOS custom customGMD">
    <xsl:import href="CustomFunctions.xsl"/>
    <xsl:import href="CustomFunctionsGMD.xsl"/>
    <!-- stylesheet to convert iso19139 in OAI-PMH ListRecords response to RIF-CS -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:param name="global_debug" select="false()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    <xsl:param name="global_IMOS_group" select="'IMOS:Integrated Marine Observing System'"/>
    <xsl:param name="global_IMOS_sourceURL" select="'http://catalogue-imos.aodn.org.au'"/>
    <!--xsl:param name="global_IMOS_originatingSourceOrganisation" select="'undetermined'"/-->
    
    <xsl:param name="global_IMOS_path" select="'/geonetwork/srv/en/metadata.show?uuid='"/>
    
    <xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/>
    <xsl:variable name="gmdCodelists" select="document('codelists.xml')"/>
    
    <xsl:template match="oai:responseDate"/>
    <xsl:template match="oai:resumptionToken"/>
    <xsl:template match="oai:request"/>
    <xsl:template match="oai:error"/>
    <xsl:template match="oai:GetRecord/oai:record/oai:header/oai:identifier"/>
    <xsl:template match="oai:GetRecord/oai:record/oai:header/oai:datestamp"/>
    <xsl:template match="oai:GetRecord/oai:record/oai:header/oai:setSpec"/>
    
    <!--xsl:template match="node()"/-->

    <!-- =========================================== -->
    <!-- RegistryObjects (root) Template             -->
    <!-- =========================================== -->

    <xsl:template match="/">
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            
            <xsl:apply-templates select="//*:MD_Metadata" mode="IMOS"/>
            
        </registryObjects>
    </xsl:template>

    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject Template          -->
    <!-- =========================================== -->

    <xsl:template match="*:MD_Metadata" mode="IMOS">
        <xsl:param name="aggregatingGroup"/>
        
        <xsl:if test="not(contains(lower-case(gmd:hierarchyLevel/*[contains(lower-case(name()),'scopecode')]/@codeListValue), 'publication'))">
            
            <xsl:if test="$global_debug">
                <xsl:message>IMOS XSLT</xsl:message>
            </xsl:if>
            
            <xsl:variable name="groupToUse">
                <xsl:choose>
                    <xsl:when test="string-length($aggregatingGroup) > 0">
                        <xsl:value-of select="$aggregatingGroup"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$global_IMOS_group"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:variable name="metadataTruthURL" select="(gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage[contains(lower-case(following-sibling::gmd:protocol), 'metadata-url')]/gmd:URL)[1]"/>
            
            <xsl:variable name="datasetURI" select="gmd:dataSetURI"/>
            <!--xsl:message select="concat('datasetURI: ', $datasetURI)"/-->
            
            <xsl:variable name="originatingSourceURL">
                <xsl:choose>
                    <xsl:when test="string-length($metadataTruthURL) > 0">
                        <xsl:value-of select="custom:getDomainFromURL($metadataTruthURL)"/>
                    </xsl:when>
                    <xsl:when test="string-length($datasetURI) > 0">
                        <xsl:value-of select="custom:getDomainFromURL($datasetURI)"/>
                    </xsl:when>
                    <xsl:when test="count(gmd:contact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL) > 0">
                        <xsl:value-of select="custom:getDomainFromURL(gmd:contact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL[1])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>undetermined</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable> 
            
            <xsl:variable name="originatingSourceOrganisation" select="customGMD:originatingSourceOrganisation(.)"/>
            
            <xsl:if test="$global_debug">
                <xsl:message select="concat('originatingSourceURL: ', $originatingSourceURL)"/>
                <xsl:message select="concat('$originatingSourceOrganisation: ', $originatingSourceOrganisation)"/>
            </xsl:if>
           
           <registryObject>
               <xsl:attribute name="group" select="substring-after($groupToUse, ':')"/>
                
                <xsl:apply-templates select="gmd:fileIdentifier" mode="IMOS_registryObject_key">
                    <xsl:with-param name="groupToUse" select="$groupToUse"/>
                </xsl:apply-templates>
            
                <originatingSource>
                    <xsl:value-of select="$originatingSourceURL"/>
                </originatingSource> 
                    
                    
                <xsl:element name="{customIMOS:registryObjectClass(gmd:hierarchyLevel/*[contains(lower-case(name()),'scopecode')]/@codeListValue)}">
        
                    <xsl:attribute name="type" select="customIMOS:registryObjectType(gmd:hierarchyLevel/*[contains(lower-case(name()),'scopecode')]/@codeListValue)"/>
                            
                    <xsl:if test="customIMOS:registryObjectClass(gmd:hierarchyLevel/*[contains(lower-case(name()),'scopecode')]/@codeListValue) = 'collection'">
                            <xsl:if test="
                                (count(gmd:dateStamp/*[contains(lower-case(name()),'date')]) > 0) and 
                                (string-length(gmd:dateStamp/*[contains(lower-case(name()),'date')][1]) > 0)">
                                <xsl:attribute name="dateAccessioned">
                                    <xsl:value-of select="gmd:dateStamp/*[contains(lower-case(name()),'date')][1]"/>
                                </xsl:attribute>  
                            </xsl:if>
                                
                    </xsl:if>
                    
                    <xsl:apply-templates select="gmd:fileIdentifier" mode="IMOS_registryObject_identifier"/>
                           
                    <xsl:apply-templates select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage[contains(lower-case(following-sibling::gmd:protocol), 'metadata-url')]/gmd:URL" mode="IMOS_registryObject_identifier"/>
                    
                    <xsl:apply-templates select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage[contains(lower-case(following-sibling::gmd:protocol), 'metadata-url')]/gmd:URL" mode="IMOS_registryObject_location_metadata"/>
                    
                    <xsl:apply-templates select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource" mode="IMOS_registryObject_relatedInfo"/>
                
                    <xsl:apply-templates select="gmd:parentIdentifier" mode="IMOS_registryObject_related_object">
                        <xsl:with-param name="groupToUse" select="$groupToUse"/>  
                    </xsl:apply-templates>
                    
                    <xsl:apply-templates select="gmd:children/gmd:childIdentifier" mode="IMOS_registryObject_related_object">
                        <xsl:with-param name="groupToUse" select="$groupToUse"/>  
                    </xsl:apply-templates>
                 
                    <!--xsl:apply-templates select="gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:source/gmd:LI_Source[string-length(gmd:sourceCitation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code) > 0]"
                         mode="IMOS_registryObject_relatedInfo"/-->
                    
                    <xsl:apply-templates
                        select="gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:statement"
                        mode="IMOS_registryObject_description_lineage"/>
                     
                     <xsl:apply-templates select="gmd:identificationInfo/*[contains(lower-case(name()),'identification')]" mode="IMOS_registryObject">
                        <xsl:with-param name="originatingSourceURL" select="$originatingSourceURL"/>
                        <xsl:with-param name="originatingSourceOrganisation" select="$originatingSourceOrganisation"/>
                        <xsl:with-param name="groupToUse" select="$groupToUse"/>
                    </xsl:apply-templates>
                    
                </xsl:element>
            </registryObject>
                
            <xsl:apply-templates select="gmd:identificationInfo/*[contains(lower-case(name()),'identification')]" mode="IMOS_relatedRegistryObjects">
                <xsl:with-param name="originatingSourceURL" select="$originatingSourceURL"/>
                <xsl:with-param name="groupToUse" select="$groupToUse"/>
            </xsl:apply-templates>
                        
        </xsl:if>

    </xsl:template>
    
    <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="IMOS_registryObject">
        <xsl:param name="originatingSourceURL"/>
        <xsl:param name="originatingSourceOrganisation"/>
        <xsl:param name="groupToUse"/>
        
        <xsl:apply-templates
            select="gmd:citation/gmd:CI_Citation/gmd:title"
            mode="IMOS_registryObject_name"/>
        
        <!-- xsl:for-each-group
            select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) > 0]"
            group-by="gmd:individualName">
            <xsl:apply-templates select="." mode="IMOS_registryObject_related_object">
                <xsl:with-param name="groupToUse" select="$groupToUse"/>
            </xsl:apply-templates>
        </xsl:for-each-group-->
        
        <xsl:for-each-group
            select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[((string-length(normalize-space(gmd:organisationName))) > 0)] |
            ancestor::gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[((string-length(normalize-space(gmd:organisationName))) > 0)] |
            gmd:pointOfContact/gmd:CI_ResponsibleParty[((string-length(normalize-space(gmd:organisationName))) > 0)] |
            ancestor::*:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[((string-length(normalize-space(gmd:organisationName))) > 0)]" 
            group-by="gmd:organisationName">
            <xsl:apply-templates select="." mode="IMOS_registryObject_related_object">
                <xsl:with-param name="groupToUse" select="$groupToUse"/>
            </xsl:apply-templates>
        </xsl:for-each-group>
        
        <xsl:apply-templates
            select="gmd:topicCategory/gmd:MD_TopicCategoryCode"
            mode="IMOS_registryObject_subject"/>
        
        <xsl:apply-templates
            select="gmd:topicCategory/gmd:MD_TopicCategoryCode"
            mode="IMOS_registryObject_subject"/>
        
        <xsl:apply-templates
            select="gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword"
            mode="IMOS_registryObject_subject"/>
        
         <xsl:apply-templates
            select="gmd:abstract"
            mode="IMOS_registryObject_description_brief"/>
        
        <xsl:apply-templates
            select="gmd:purpose"
            mode="IMOS_registryObject_description_notes"/>
        
        <xsl:apply-templates
            select="gmd:credit"
            mode="IMOS_registryObject_description_notes"/>
        
       <xsl:apply-templates select="gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox" mode="IMOS_registryObject_coverage_spatial"/>
       <xsl:apply-templates select="gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_BoundingPolygon" mode="IMOS_registryObject_coverage_spatial"/>
       
        <xsl:apply-templates
            select="gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent"
            mode="IMOS_registryObject_coverage_temporal"/>
        
        <xsl:apply-templates
            select="gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent"
            mode="IMOS_registryObject_coverage_temporal_period"/>
        
        
        <xsl:apply-templates
            select="gmd:resourceConstraints/*:MD_CreativeCommons[exists(*:licenseLink)]"
            mode="IMOS_registryObject_rights_licence_creative"/>
        
        <xsl:apply-templates
            select="gmd:resourceConstraints/*:MD_CreativeCommons"
            mode="IMOS_registryObject_rights_rightsStatement_creative"/>
        
        <xsl:apply-templates
            select="gmd:resourceConstraints/*:MD_Commons[exists(*:licenseLink)]"
            mode="IMOS_registryObject_rights_licence_creative"/>
        
        <xsl:apply-templates
            select="gmd:resourceConstraints/*:MD_Commons"
            mode="IMOS_registryObject_rights_rightsStatement_creative"/>
        
        <xsl:apply-templates
            select="."
            mode="IMOS_registryObject_rights_accessRights"/>
        
        <xsl:apply-templates
            select="gmd:resourceConstraints/*[contains(local-name(), 'Constraints')]"
            mode="IMOS_registryObject_rights_constraints"/>
        
        
       <xsl:if test="customIMOS:registryObjectClass(ancestor::*:MD_Metadata/gmd:hierarchyLevel/*[contains(lower-case(name()),'scopecode')]/@codeListValue) = 'collection'">
            
            <xsl:apply-templates
                select="gmd:citation/gmd:CI_Citation/gmd:date"
                mode="IMOS_registryObject_dates"/>
            
            
            <xsl:apply-templates select="gmd:citation/gmd:CI_Citation"
                mode="IMOS_registryObject_citationMetadata_citationInfo">
                <xsl:with-param name="originatingSourceURL" select="$originatingSourceURL"/>
                <xsl:with-param name="originatingSourceOrganisation" select="$originatingSourceOrganisation"/>
            </xsl:apply-templates>
        </xsl:if>
            
   </xsl:template>
    
    
    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject - Related Party Templates -->
    <!-- =========================================== -->
    
    <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="IMOS_relatedRegistryObjects">
        <xsl:param name="originatingSourceURL"/>
        <xsl:param name="groupToUse"/>
        <!-- xsl:for-each-group
            select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) > 0]"
            group-by="gmd:individualName">
            <xsl:call-template name="IMOS_partyPerson">
                <xsl:with-param name="originatingSourceURL" select="$originatingSourceURL"/>
                <xsl:with-param name="groupToUse" select="$groupToUse"/>
            </xsl:call-template>
        </xsl:for-each-group-->
        
        <xsl:for-each-group
            select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName))) > 0] |
            ancestor::gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName))) > 0] |
            gmd:pointOfContact/gmd:CI_ResponsibleParty[string-length(normalize-space(gmd:organisationName)) > 0] |
            ancestor::*:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[string-length(normalize-space(gmd:organisationName)) > 0]"
            group-by="gmd:organisationName">
            <xsl:call-template name="IMOS_partyGroup">
                <xsl:with-param name="originatingSourceURL" select="$originatingSourceURL"/>
                <xsl:with-param name="groupToUse" select="$groupToUse"/>
            </xsl:call-template>
        </xsl:for-each-group>
    </xsl:template>
    
    
    

    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject - Child Templates -->
    <!-- =========================================== -->

    <!-- RegistryObject - Key Element  -->
    <xsl:template match="gmd:fileIdentifier" mode="IMOS_registryObject_key">
        <xsl:param name="groupToUse"/>
        <key>
            <xsl:value-of select="concat(substring-before($groupToUse, ':'), '/', normalize-space(.))"/>
        </key>
    </xsl:template>
    
    <!-- RegistryObject - Identifier Element  -->
    <xsl:template match="gmd:fileIdentifier" mode="IMOS_registryObject_identifier">
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

    <!-- RegistryObject - Identifier Element  -->
    <xsl:template match="gmd:URL" mode="IMOS_registryObject_identifier">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <identifier type="uri">
                <xsl:value-of select="."/>
            </identifier>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Name Element  -->
    <xsl:template
        match="gmd:citation/gmd:CI_Citation/gmd:title"
        mode="IMOS_registryObject_name">
        <xsl:if test="string-length(normalize-space(.)) > 0">
          <name>
              <xsl:attribute name="type">
                  <xsl:text>primary</xsl:text>
              </xsl:attribute>
              <namePart>
                  <xsl:value-of select="normalize-space(.)"/>
              </namePart>
          </name>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Dates Element  -->
    <xsl:template
        match="gmd:citation/gmd:CI_Citation/gmd:date"
        mode="IMOS_registryObject_dates">
        <xsl:variable name="dateValue">
            <xsl:if test="string-length(normalize-space(gmd:CI_Date/gmd:date/gco:Date)) > 0">
                <xsl:value-of select="normalize-space(gmd:CI_Date/gmd:date/gco:Date)"/>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(gmd:CI_Date/gmd:date/gco:DateTime)) > 0">
                <xsl:value-of select="normalize-space(gmd:CI_Date/gmd:date/gco:DateTime)"/>
            </xsl:if>
        </xsl:variable> 
        <xsl:variable name="dateCode"
            select="normalize-space(gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue)"/>
        <xsl:variable name="transformedDateCode">
            <xsl:choose>
                <xsl:when test="contains(lower-case($dateCode), 'creation')">
                    <xsl:text>created</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case($dateCode), 'publication')">
                    <xsl:text>issued</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case($dateCode), 'revision')">
                    <xsl:text>modified</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:if
            test="
            (string-length($dateValue) > 0) and
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
                    <xsl:value-of select="translate($dateValue, '-', '')"/>
                </date>
            </dates>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Related Object Element  -->
    <xsl:template match="gmd:parentIdentifier" mode="IMOS_registryObject_related_object">
        <xsl:param name="groupToUse"/>
        <xsl:variable name="identifier" select="normalize-space(.)"/>
        <xsl:if test="string-length($identifier) > 0">
            <relatedObject>
                <key>
                    <xsl:value-of select="concat(substring-before($groupToUse, ':'), '/', $identifier)"/>
                </key>
                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>isPartOf</xsl:text>
                    </xsl:attribute>
                </relation>
            </relatedObject>
        </xsl:if>
    </xsl:template>
    
   <xsl:template match="gmd:URL" mode="IMOS_registryObject_location_metadata">
        <xsl:if test="string-length(normalize-space(.)) > 0">
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
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Related Object (Organisation or Individual) Element -->
    <xsl:template match="gmd:CI_ResponsibleParty" mode="IMOS_registryObject_related_object">
        <xsl:param name="groupToUse"/>
         <relatedObject>
            <key>
                <xsl:value-of select="concat(substring-before($groupToUse, ':'), '/', translate(normalize-space(current-grouping-key()),' ',''))"/>
            </key>
            <xsl:for-each-group select="current-group()/gmd:role"
                group-by="gmd:CI_RoleCode/@codeListValue">
                <xsl:variable name="code">
                    <xsl:value-of select="current-grouping-key()"/>
                </xsl:variable>
                <relation>
                    <xsl:variable name="codelist"
                        select="$gmdCodelists/codelists/codelist[@name = 'gmd:CI_RoleCode']"/>
                    
                    <xsl:variable name="type">
                        <xsl:value-of select="$codelist/entry[code = $code]/description"/>
                    </xsl:variable>
                    
                    <xsl:attribute name="type">
                        <xsl:choose>
                            <xsl:when test="string-length($type) > 0">
                                <xsl:value-of select="$type"/>
                            </xsl:when>
                            <xsl:when test="string-length($code) > 0">
                                <xsl:value-of select="$code"/>  
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>unknown</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </relation>
                
            </xsl:for-each-group>
        </relatedObject>
    </xsl:template>

    <!-- RegistryObject - Related Object Element  -->
    <xsl:template match="gmd:childIdentifier" mode="IMOS_registryObject_related_object">
        <xsl:param name="groupToUse"/>
        <xsl:variable name="identifier" select="normalize-space(.)"/>
        
        <xsl:if test="string-length($identifier) > 0">
            <relatedObject>
                <key>
                    <xsl:value-of select="concat(substring-before($groupToUse, ':'), '/', $identifier)"/>
                </key>
                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>hasPart</xsl:text>
                    </xsl:attribute>
                </relation>
            </relatedObject>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gmd:keyword" mode="IMOS_registryObject_subject">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <subject type="local">
                <xsl:value-of select="."></xsl:value-of>
            </subject>
        </xsl:if>
    </xsl:template>
    
   <xsl:template match="gmd:MD_TopicCategoryCode" mode="IMOS_registryObject_subject">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <subject type="local">
                <xsl:value-of select="."></xsl:value-of>
            </subject>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Decription Element -->
    <xsl:template match="gmd:abstract" mode="IMOS_registryObject_description_brief">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="brief">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Decription Element -->
    <xsl:template match="gmd:purpose" mode="IMOS_registryObject_description_notes">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="note">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
    
    <!-- RegistryObject - Decription Element -->
    <xsl:template match="gmd:statement" mode="IMOS_registryObject_description_lineage">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="lineage">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Decription Element -->
    <xsl:template match="gmd:credit" mode="IMOS_registryObject_description_notes">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="note">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Coverage Spatial Element -->
    <xsl:template match="gmd:EX_GeographicBoundingBox" mode="IMOS_registryObject_coverage_spatial">
        
        <xsl:variable name="crsCode" select="ancestor::*:MD_Metadata/gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code[contains(lower-case(following-sibling::gmd:codeSpace), 'crs')]"/>
        <xsl:if test="string-length(normalize-space(gmd:northBoundLatitude/gco:Decimal)) > 0"/>
        <xsl:if
             test="
                (string-length(normalize-space(gmd:northBoundLatitude/gco:Decimal)) > 0) and
                (string-length(normalize-space(gmd:southBoundLatitude/gco:Decimal)) > 0) and
                (string-length(normalize-space(gmd:westBoundLongitude/gco:Decimal)) > 0) and
                (string-length(normalize-space(gmd:eastBoundLongitude/gco:Decimal)) > 0)">
                 <xsl:variable name="spatialString">
                     <xsl:value-of
                         select="normalize-space(concat('northlimit=',gmd:northBoundLatitude/gco:Decimal,'; southlimit=',gmd:southBoundLatitude/gco:Decimal,'; westlimit=',gmd:westBoundLongitude/gco:Decimal,'; eastLimit=',gmd:eastBoundLongitude/gco:Decimal))"/>
                     
                     <xsl:if
                         test="
                         (string-length(normalize-space(gmd:EX_VerticalExtent/gmd:maximumValue/gco:Real)) > 0) and
                         (string-length(normalize-space(gmd:EX_VerticalExtent/gmd:minimumValue/gco:Real)) > 0)">
                         <xsl:value-of
                             select="normalize-space(concat('; uplimit=',gmd:EX_VerticalExtent/gmd:maximumValue/gco:Real,'; downlimit=',gmd:EX_VerticalExtent/gmd:minimumValue/gco:Real))"
                         />
                     </xsl:if>
                     <xsl:choose>
                          <xsl:when test="string-length(normalize-space($crsCode)) > 0">
                             <xsl:value-of select="concat('; projection=', $crsCode)"/>
                          </xsl:when>
                         <xsl:otherwise>
                             <xsl:text>; projection=GDA94</xsl:text>
                         </xsl:otherwise>
                     </xsl:choose>
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
        </xsl:if>
    </xsl:template>


    <!-- RegistryObject - Coverage Spatial Element -->
    <xsl:template match="gmd:EX_BoundingPolygon" mode="IMOS_registryObject_coverage_spatial">
        <xsl:if
            test="string-length(normalize-space(gmd:polygon/gml:Polygon/gml:exterior/gml:LinearRing/gml:coordinates)) > 0">
            <coverage>
                <spatial>
                    <xsl:attribute name="type">
                        <xsl:text>gmlKmlPolyCoords</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of
                        select="replace(normalize-space(gmd:polygon/gml:Polygon/gml:exterior/gml:LinearRing/gml:coordinates), ',0', '')"
                    />
                </spatial>
            </coverage>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Coverage Temporal Element -->
    <xsl:template match="gmd:EX_TemporalExtent" mode="IMOS_registryObject_coverage_temporal">
        <xsl:if
            test="(string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) > 0) or
                  (string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)) > 0)">
            <coverage>
                <temporal>
                    <xsl:if
                        test="string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateFrom</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gmd:extent/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)"
                            />
                        </date>
                    </xsl:if>
                    <xsl:if
                        test="string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateTo</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gmd:extent/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)"
                            />
                        </date>
                    </xsl:if>
                </temporal>
            </coverage>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Coverage Temporal Element -->
    <xsl:template match="gmd:EX_TemporalExtent" mode="IMOS_registryObject_coverage_temporal_period">
        <xsl:if
            test="(string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:beginPosition)) > 0) or
                  (string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:endPosition)) > 0)">
            <coverage>
                <temporal>
                    <xsl:if
                        test="string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:beginPosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateFrom</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gmd:extent/gml:TimePeriod/gml:beginPosition)"
                            />
                        </date>
                    </xsl:if>
                    <xsl:if
                        test="string-length(normalize-space(gmd:extent/gml:TimePeriod/gml:endPosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateTo</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gmd:extent/gml:TimePeriod/gml:endPosition)"
                            />
                        </date>
                    </xsl:if>
                </temporal>
            </coverage>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - RelatedInfo Element  -->
    <xsl:template match="gmd:CI_OnlineResource" mode="IMOS_registryObject_relatedInfo">         
        
            <xsl:choose>
                <xsl:when test="contains(gmd:protocol, 'OGC:') or contains(lower-case(gmd:linkage/gmd:URL), 'thredds')">
                    <xsl:apply-templates select="." mode="IMOS_relatedInfo_service"/>
                </xsl:when>
                <xsl:when test="not(contains(lower-case(gmd:description), 'point of truth url of this metadata record'))">
                    <xsl:apply-templates select="." mode="IMOS_relatedInfo_relatedInformation"/>
                </xsl:when>
                
            </xsl:choose>
            
     </xsl:template>
    
    <xsl:template match="gmd:CI_OnlineResource" mode="IMOS_relatedInfo_service">       
      
        <xsl:variable name="identifierValue" select="normalize-space(gmd:linkage/gmd:URL)"/>
        <xsl:variable name="specificOWS_protocol" select="customGMD:extractSpecific_OWS_protocol_maintainCase(gmd:protocol)"/>
        
        
        
        <relatedInfo>
        <xsl:attribute name="type" select="'service'"/>   
         
         <relation>
             <xsl:attribute name="type">
                 <xsl:text>supports</xsl:text>
             </xsl:attribute>
             <xsl:if test="(contains($identifierValue, '?')) or (contains($identifierValue, '.nc'))">
                    <url>
                        <xsl:choose>
                         <xsl:when test="contains(lower-case($identifierValue), 'ows') and (string-length($specificOWS_protocol) > 0)">
                             <xsl:value-of select="customGMD:replaceOWS_specificProtocol($identifierValue, $specificOWS_protocol)"/>
                         </xsl:when>
                         <xsl:otherwise>
                             <xsl:value-of select="$identifierValue"/>
                         </xsl:otherwise>
                        </xsl:choose>
                    </url>
             </xsl:if>
         </relation>
         
            <xsl:apply-templates select="." mode="IMOS_relatedInfo_all"/>
        </relatedInfo>
         
    </xsl:template>
    
    <xsl:template match="gmd:CI_OnlineResource" mode="IMOS_relatedInfo_relatedInformation">       
        
        <relatedInfo>
          <xsl:attribute name="type" select="'relatedInformation'"/>   
          
          <relation>
              <xsl:attribute name="type">
                  <xsl:text>hasAssociationWith</xsl:text>
              </xsl:attribute>
          </relation>
          
            <xsl:apply-templates select="." mode="IMOS_relatedInfo_all"/>
        </relatedInfo>
        
    </xsl:template>
    
        
    <xsl:template match="gmd:CI_OnlineResource" mode="IMOS_relatedInfo_all">     
            
        <xsl:variable name="identifierValue" select="normalize-space(gmd:linkage/gmd:URL)"/>
        <xsl:variable name="protocol" select="normalize-space(gmd:protocol)"/>
        
        <xsl:variable name="specificOWS_protocol" select="customGMD:extractSpecific_OWS_protocol_maintainCase($protocol)"/>
        
            <identifier>
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="contains(lower-case($identifierValue), 'doi')">
                            <xsl:text>doi</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>uri</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:variable name="identifier">
                    <xsl:choose>
                        <xsl:when test="contains($identifierValue, '?')">
                            <xsl:value-of select="substring-before(., '?')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$identifierValue"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="contains(lower-case($identifier), 'ows') and (string-length($specificOWS_protocol) > 0)">
                        <xsl:value-of select="customGMD:replaceOWS_specificProtocol($identifier, $specificOWS_protocol)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$identifier"/>
                    </xsl:otherwise>
                </xsl:choose>
                
            </identifier>
            
                <xsl:choose>
                    <!-- Use description as title if we have it... -->
                    <xsl:when test="string-length(normalize-space(gmd:description)) > 0">
                        <title>
                            <xsl:value-of select="normalize-space(gmd:description)"/>
                        
                            <!-- ...and then name in brackets following -->
                            <xsl:if
                                test="string-length(normalize-space(gmd:name)) > 0">
                                    <xsl:value-of select="concat(' (', gmd:name, ')')"/>
                            </xsl:if>
                        </title>
                     </xsl:when>
                    <!-- No description, so use name as title if we have it -->
                    <xsl:otherwise>
                        <xsl:if
                            test="string-length(normalize-space(gmd:name)) > 0">
                            <title>
                                <xsl:value-of select="concat('(', gmd:name, ')')"/>
                            </title>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
     </xsl:template>
    
    
     <xsl:template match="gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:source/gmd:LI_Source" mode="IMOS_registryObject_relatedInfo">
     <xsl:if test="string-length(gmd:sourceCitation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code) > 0">
        <relatedInfo>
           <xsl:attribute name="type">
               <xsl:choose>
                   <xsl:when test="contains(lower-case(gmd:sourceCitation/gmd:CI_Citation/gmd:presentationForm/gmd:CI_PresentationFormCode/@codeListValue), 'modeldigital')">
                       <xsl:text>service</xsl:text>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:text>reuseInformation</xsl:text>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:attribute>
           <identifier>
               <xsl:attribute name="type">
                   <xsl:choose>
                       <xsl:when test="contains(lower-case(gmd:sourceCitation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code), 'doi')">
                           <xsl:text>doi</xsl:text>
                       </xsl:when>
                       <xsl:otherwise>
                           <xsl:text>uri</xsl:text>
                       </xsl:otherwise>
                   </xsl:choose>
               </xsl:attribute>
               <xsl:value-of select="gmd:sourceCitation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code"/>
           </identifier>
           <relation>
               <xsl:attribute name="type">
                   <xsl:choose>
                       <xsl:when test="contains(lower-case(gmd:sourceCitation/gmd:CI_Citation/gmd:presentationForm/gmd:CI_PresentationFormCode/@codeListValue), 'modeldigital')">
                           <xsl:text>produces</xsl:text>
                       </xsl:when>
                       <xsl:otherwise>
                           <xsl:text>supplements</xsl:text>
                       </xsl:otherwise>
                   </xsl:choose>
               </xsl:attribute>
           </relation>
           <xsl:if test="string-length(normalize-space(gmd:sourceCitation/gmd:CI_Citation/gmd:title)) > 0">
             <title>
                 <xsl:value-of select="normalize-space(gmd:sourceCitation/gmd:CI_Citation/gmd:title)"/>
             </title>
           </xsl:if>
        </relatedInfo>
     </xsl:if>
    </xsl:template>
   
    <!-- RegistryObject - RelatedInfo Element  -->
    <xsl:template match="gmd:childIdentifier" mode="IMOS_registryObject_relatedInfo">
        <xsl:variable name="identifier" select="normalize-space(.)"/>
        <xsl:if test="string-length($identifier) > 0">
            <relatedInfo type="collection">
                <identifier type="uri">
                    <xsl:value-of
                        select="concat($global_IMOS_sourceURL, $global_IMOS_path, $identifier)"
                    />
                </identifier>
                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>hasPart</xsl:text>
                    </xsl:attribute>
                </relation>
                <xsl:if test="string-length(normalize-space(@title)) > 0"/>
                <title>
                    <xsl:value-of select="normalize-space(@title)"/>
                </title>
            </relatedInfo>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Rights Licence - From CreativeCommons -->
    <xsl:template match="*:MD_CreativeCommons" mode="IMOS_registryObject_rights_licence_creative">
        <xsl:variable name="licenseLink" select="normalize-space(*:licenseLink/gmd:URL)"/>
        <xsl:variable name="licenseName" select="normalize-space(*:licenseName)"/>
        <xsl:for-each
            select="$licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='LicenseCodeAustralia' or @gml:id='LicenseCodeInternational']/gmx:codeEntry/gmx:CodeDefinition">
            <xsl:if test="string-length(normalize-space(gml:remarks)) > 0">
                <xsl:if test="(lower-case(replace($licenseLink, '\d.\d|/', '')) = normalize-space(lower-case(replace(gml:remarks, '\{n\}|/', ''))))">
                    <rights>
                        <licence>
                            <xsl:attribute name="type" select="gml:identifier"/>
                            <xsl:attribute name="rightsUri" select="$licenseLink"/>
                            <xsl:if test="string-length(normalize-space($licenseName)) > 0">
                                <xsl:value-of select="normalize-space($licenseName)"/>
                            </xsl:if>
                        </licence>
                    </rights>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <!--xsl:for-each select="gmd:otherConstraints">
            <xsl:if test="string-length(normalize-space(.)) > 0">
                <rights>
                    <licence>
                        <xsl:value-of select='normalize-space(.)'/>
                    </licence>
                </rights>
            </xsl:if>
        </xsl:for-each-->
    </xsl:template>

    <!-- RegistryObject - Rights RightsStatement - From CreativeCommons -->
    <xsl:template match="*:MD_CreativeCommons" mode="IMOS_registryObject_rights_rightsStatement_creative">
        <xsl:for-each select="gmd:attributionConstraints">
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
    
    <!-- RegistryObject - Rights Licence - From CreativeCommons -->
    <xsl:template match="*:MD_Commons" mode="IMOS_registryObject_rights_licence_creative">
        <xsl:variable name="licenseLink" select="normalize-space(*:licenseLink/gmd:URL)"/>
        <xsl:variable name="licenseName" select="normalize-space(*:licenseName)"/>
        <xsl:for-each
            select="$licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='LicenseCodeAustralia' or @gml:id='LicenseCodeInternational']/gmx:codeEntry/gmx:CodeDefinition">
            <xsl:if test="string-length(normalize-space(gml:remarks)) > 0">
                <xsl:if test="(lower-case(replace($licenseLink, '\d.\d|/', '')) = normalize-space(lower-case(replace(gml:remarks, '\{n\}|/', ''))))">
                    <rights>
                        <licence>
                            <xsl:attribute name="type" select="gml:identifier"/>
                            <xsl:attribute name="rightsUri" select="$licenseLink"/>
                            <xsl:if test="string-length(normalize-space($licenseName)) > 0">
                                <xsl:value-of select="normalize-space($licenseName)"/>
                            </xsl:if>
                        </licence>
                    </rights>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
        
        <!--xsl:for-each select="gmd:otherConstraints">
            <xsl:if test="string-length(normalize-space(.)) > 0">
            <rights>
            <licence>
            <xsl:value-of select='normalize-space(.)'/>
            </licence>
            </rights>
            </xsl:if>
            </xsl:for-each-->
    </xsl:template>
    
    <!-- RegistryObject - Rights RightsStatement - From CreativeCommons -->
    <xsl:template match="*:MD_Commons" mode="IMOS_registryObject_rights_rightsStatement_creative">
        <xsl:for-each select="gmd:attributionConstraints">
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

    <!-- RegistryObject - RightsStatement -->
    <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="IMOS_registryObject_rights_accessRights">
         
        <xsl:variable name="restrictionCode_sequence" select="gmd:resourceConstraints/*[contains(local-name(), 'Constraints')]/gmd:accessConstraints/gmd:MD_RestrictionCode/@codeListValue" as="xs:string*"/>
        <xsl:choose>
            <xsl:when test="custom:sequenceContains($restrictionCode_sequence, 'restricted')">
                <rights>
                    <accessRights type="restricted"/>
                </rights>
            </xsl:when>
            <xsl:otherwise>
                <rights>
                    <accessRights type="open"/>
                </rights>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[contains(local-name(), 'Constraints')]" mode="IMOS_registryObject_rights_constraints">
        
        <xsl:for-each select="gmd:useLimitation">
            <xsl:variable name="useLimitation" select="normalize-space(.)"/>
            <!-- If there is text in other contraints, use this; otherwise, do nothing -->
            <xsl:if test="string-length($useLimitation) > 0">
                <rights>
                    <rightsStatement>
                        <xsl:value-of select="$useLimitation"/>
                    </rightsStatement>
                </rights>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="gmd:otherConstraints">
            <xsl:variable name="otherConstraints" select="normalize-space(.)"/>
            <!-- If there is text in other contraints, use this; otherwise, do nothing -->
            <xsl:if test="string-length($otherConstraints) > 0">
                <xsl:choose>
                    <xsl:when test="contains(lower-case($otherConstraints), 'copyright')">
                        <rights>
                            <rightsStatement>
                                <xsl:value-of select="$otherConstraints"/>
                            </rightsStatement>
                        </rights>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($otherConstraints), 'licence') or 
                        contains(lower-case($otherConstraints), 'license')">
                        <rights>
                            <licence>
                                <xsl:value-of select="$otherConstraints"/>
                            </licence>
                        </rights>
                    </xsl:when>
                    <xsl:otherwise>
                        <rights>
                            <rightsStatement>
                                <xsl:value-of select="$otherConstraints"/>
                            </rightsStatement>
                        </rights>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="contains(lower-case($otherConstraints), 'picccby')">
                <rights>
                    <licence><xsl:text disable-output-escaping="yes">&lt;![CDATA[&lt;a href="http://polarcommons.org/ethics-and-norms-of-data-sharing.php"&gt; &lt;img src="http://polarcommons.org/images/PIC_print_small.png" style="border-width:0; width:40px; height:40px;" alt="Polar Information Commons's PICCCBY license."/&gt;&lt;/a&gt;&lt;a rel="license" href="http://creativecommons.org/licenses/by/3.0/" rel="license"&gt; &lt;img alt="Creative Commons License" style="border-width:0; width: 88px; height: 31px;" src="http://i.creativecommons.org/l/by/3.0/88x31.png" /&gt;&lt;/a&gt;]]&gt;</xsl:text>
                        <!--xsl:for-each select="$licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='LicenseCodeAustralia' or @gml:id='LicenseCodeInternational']/gmx:codeEntry/gmx:CodeDefinition">
                            <xsl:if test="string-length(normalize-space(gml:remarks)) > 0">
                            <xsl:if test="contains($otherConstraints, gml:remarks)">
                            <xsl:message>Identifier <xsl:value-of select='gml:identifier'/></xsl:message>
                            <xsl:message>Remarks <xsl:value-of select='gml:remarks'/></xsl:message>
                            <xsl:attribute name="type" select="gml:identifier"/>
                            <xsl:attribute name="rightsUri" select="gml:remarks"/>
                            </xsl:if>
                            </xsl:if>
                            </xsl:for-each>
                            <xsl:value-of select="$otherConstraints"/-->
                    </licence>
                </rights>
            </xsl:if>
        </xsl:for-each>
        
    </xsl:template>
    <!-- RegistryObject - CitationInfo Element -->
    <xsl:template match="gmd:CI_Citation" mode="IMOS_registryObject_citationMetadata_citationInfo">
        <xsl:param name="originatingSourceURL"/>
        <xsl:param name="originatingSourceOrganisation"/>
       
        <!-- Attempt to obtain contributor names; only construct citation if we have contributor names -->
        
        <xsl:variable name="citedResponsibleParty_sequence" select="gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue != 'publisher']" as="node()*"/>
        
        <xsl:variable name="publisher_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher']"/>  
        
        <!--
       <xsl:variable name="principalInvestigator_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'principalInvestigator']"/>
        
        <xsl:variable name="author_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'author']"/>
        
        <xsl:variable name="contentexpert_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'contentexpert']"/>
        
        <xsl:variable name="coInvestigator_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'coInvestigator']"/>
        
        
        <xsl:variable name="owner_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'owner']"/>  
    
        -->
        
        <xsl:variable name="citationContributorName_sequence" as="xs:string*">
        
            <!--        
           <xsl:for-each select="$principalInvestigator_sequence">
               <xsl:choose>
                   <xsl:when test="string-length(gmd:individualName) = 0">
                       <xsl:if test="string-length(gmd:organisationName) > 0">
                           <xsl:value-of select="gmd:organisationName"/>
                       </xsl:if>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:value-of select="gmd:individualName"/>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:for-each>
            
            <xsl:for-each select="$author_sequence">
                <xsl:choose>
                   <xsl:when test="string-length(gmd:individualName) = 0">
                       <xsl:if test="string-length(gmd:organisationName) > 0">
                           <xsl:value-of select="gmd:organisationName"/>
                       </xsl:if>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:value-of select="gmd:individualName"/>
                   </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>
            
            <xsl:for-each select="$contentexpert_sequence">
                <xsl:choose>
                   <xsl:when test="string-length(gmd:individualName) = 0">
                       <xsl:if test="string-length(gmd:organisationName) > 0">
                           <xsl:value-of select="gmd:organisationName"/>
                       </xsl:if>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:value-of select="gmd:individualName"/>
                   </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>
            
            <xsl:for-each select="$coInvestigator_sequence">
              <xsl:choose>
                   <xsl:when test="string-length(gmd:individualName) = 0">
                       <xsl:if test="string-length(gmd:organisationName) > 0">
                           <xsl:value-of select="gmd:organisationName"/>
                       </xsl:if>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:value-of select="gmd:individualName"/>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:for-each>
               -->
        
           <xsl:for-each select="$citedResponsibleParty_sequence">
               <xsl:choose>
                   <xsl:when test="string-length(gmd:individualName) = 0">
                       <xsl:if test="string-length(gmd:organisationName) > 0">
                           <xsl:value-of select="gmd:organisationName"/>
                       </xsl:if>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:value-of select="gmd:individualName"/>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:for-each>
       </xsl:variable>
       
        <xsl:if test="$global_debug">
            <xsl:message select="concat('Count($citationContributorName_sequence): ', count($citationContributorName_sequence))"/>
        </xsl:if>
       
        <xsl:variable name="pointOfContact_principalInvestigator_sequence" as="node()*" select="
            ../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'principalInvestigator']"/>
        
        <xsl:variable name="pointOfContact_author_sequence" as="node()*" select="
            ../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'author']"/>
        
        <xsl:variable name="pointOfContact_pointOfContact_sequence" as="node()*" select="
            ../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'pointOfContact']"/>
        
        
       <xsl:variable name="pointOfContactContributorName_sequence" as="xs:string*">
           
           <xsl:for-each select="$pointOfContact_principalInvestigator_sequence">
               <xsl:if test="string-length(gmd:organisationName) > 0">
                    <xsl:value-of select="gmd:organisationName"/>
               </xsl:if>
           </xsl:for-each>
            
            <xsl:for-each select="$pointOfContact_author_sequence">
                <xsl:if test="string-length(gmd:organisationName) > 0">
                    <xsl:value-of select="gmd:organisationName"/>
               </xsl:if>
            </xsl:for-each>
            
            
            <xsl:for-each select="$pointOfContact_pointOfContact_sequence">
               <xsl:if test="string-length(gmd:organisationName) > 0">
                    <xsl:value-of select="gmd:organisationName"/>
               </xsl:if>
           </xsl:for-each>
           
        
      
      </xsl:variable>
      
        <xsl:if test="$global_debug">
            <xsl:message select="concat('Count($pointOfContactContributorName_sequence): ', count($pointOfContactContributorName_sequence))"/>
        </xsl:if>
      
        <xsl:variable name="allContributorName_sequence" as="xs:string*">
           
            <xsl:for-each select="distinct-values($citationContributorName_sequence)">
                <xsl:if test="string-length(.) > 0">
                    <xsl:value-of select="."/>
               </xsl:if>
            </xsl:for-each>
            
            <xsl:if test="count($citationContributorName_sequence) = 0">
                <xsl:for-each select="distinct-values($pointOfContactContributorName_sequence)">
                    <xsl:if test="string-length(.) > 0">
                        <xsl:value-of select="."/>
                   </xsl:if>
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>
        
        <xsl:if test="$global_debug">
            <xsl:for-each select="$allContributorName_sequence">
                <xsl:message select="concat('Contributor name: ', .)"/>
            </xsl:for-each>
        </xsl:if>
        
        <!-- We can only accept one DOI; however, first we will find all -->
        <xsl:variable name = "doiIdentifier_sequence" as="xs:string*" select="gmd:identifier/gmd:MD_Identifier/gmd:code[contains(lower-case(.), 'doi')]"/>
        <xsl:variable name="identifierToUse">
            <xsl:choose>
                <xsl:when test="count($doiIdentifier_sequence) and (string-length($doiIdentifier_sequence[1]) > 0)">
                    <xsl:value-of select="$doiIdentifier_sequence[1]"/>   
                </xsl:when>
                <xsl:when test="count(ancestor::*:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage[contains(lower-case(following-sibling::gmd:protocol), 'metadata-url')]/gmd:URL) > 0">
                    <xsl:if test="string-length((ancestor::*:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage[contains(lower-case(following-sibling::gmd:protocol), 'metadata-url')]/gmd:URL)[1]) > 0">
                        <xsl:value-of select="(ancestor::*:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage[contains(lower-case(following-sibling::gmd:protocol), 'metadata-url')]/gmd:URL)[1]"/>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($global_IMOS_sourceURL, $global_IMOS_path, ancestor::*:MD_Metadata/gmd:fileIdentifier)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="typeToUse">
            <xsl:choose>
                <xsl:when test="count($doiIdentifier_sequence) and (string-length($doiIdentifier_sequence[1]) > 0)">
                    <xsl:text>doi</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>uri</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:if test="count($allContributorName_sequence) > 0">
           <citationInfo>
                <citationMetadata>
                    <xsl:if test="string-length($identifierToUse) > 0">
                        <identifier>
                            <xsl:if test="string-length($typeToUse) > 0">
                                <xsl:attribute name="type">
                                    <xsl:value-of select='$typeToUse'/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select='$identifierToUse'/>
                        </identifier>
                    </xsl:if>
    
                    <title>
                        <xsl:value-of select="gmd:title"/>
                    </title>
                    
                    <xsl:variable name="current_CI_Citation" select="."/>
                    <xsl:variable name="CI_Date_sequence" as="node()*">
                        <xsl:variable name="type_sequence" as="xs:string*" select="'creation,publication,revision'"/>
                        <xsl:for-each select="tokenize($type_sequence, ',')">
                            <xsl:variable name="type" select="."/>
                            <xsl:for-each select="$current_CI_Citation/gmd:date/gmd:CI_Date">
                                <xsl:variable name="code" select="normalize-space(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue)"/>
                                    <xsl:if test="contains(lower-case($code), lower-case($type))">
                                    <xsl:copy-of select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:variable>
                    
                    <xsl:variable name="codelist" select="$gmdCodelists/codelists/codelist[@name = 'gmd:CI_DateTypeCode']"/>
                    
                    <xsl:variable name="dateType">
                        <xsl:if test="count($CI_Date_sequence)">
                            <xsl:variable name="codevalue" select="$CI_Date_sequence[1]/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue"/>
                            <xsl:value-of select="$codelist/entry[code = $codevalue]/description"/>
                        </xsl:if>
                    </xsl:variable>
                    
                    <xsl:variable name="dateValue">
                        <xsl:if test="count($CI_Date_sequence)">
                            <xsl:if test="string-length($CI_Date_sequence[1]/gmd:date/gco:Date) > 3">
                                <xsl:value-of select="substring($CI_Date_sequence[1]/gmd:date/gco:Date, 1, 4)"/>
                            </xsl:if>
                            <xsl:if test="string-length($CI_Date_sequence[1]/gmd:date/gco:DateTime) > 3">
                                <xsl:value-of select="substring($CI_Date_sequence[1]/gmd:date/gco:DateTime, 1, 4)"/>
                            </xsl:if>
                        </xsl:if>
                    </xsl:variable>
                    
                     <xsl:choose>
                        <xsl:when test="(string-length($dateType) > 0) and (string-length($dateValue) > 0)">
                            <date>
                                <xsl:attribute name="type">
                                    <xsl:value-of select="$dateType"/>
                                </xsl:attribute>
                                <xsl:value-of select="$dateValue"/>
                            </date>
                        </xsl:when>
                        <xsl:when test="
                            (count(ancestor::*:MD_Metadata/gmd:dateStamp/*[contains(lower-case(name()),'date')]) > 0) and
                            (string-length(ancestor::*:MD_Metadata/gmd:dateStamp/*[contains(lower-case(name()),'date')][1]) > 3)">
                            <date>
                                <xsl:attribute name="type">
                                    <xsl:text>publicationDate</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of select="substring(ancestor::*:MD_Metadata/gmd:dateStamp/*[contains(lower-case(name()),'date')][1], 1, 4)"/>
                            </date>
                        </xsl:when>
                       
                    </xsl:choose>
                    
                  <!-- If there is more than one contributor, and publisher 
                  name is within contributor list, remove it -->
                    
                    <xsl:variable name="publisherToUse">
                        <xsl:choose>
                            <xsl:when test="(count($publisher_sequence) > 0) and (string-length($publisher_sequence[1]/gmd:organisationName) > 0)">
                                <xsl:if test="$global_debug">
                                        <xsl:message select="concat('Found party with publish role: ', $publisher_sequence[1]/gmd:organisationName)"/> 
                                </xsl:if>
                                 <xsl:copy-of select="$publisher_sequence[1]/gmd:organisationName"/>
                            </xsl:when>
                            <xsl:when test="string-length($originatingSourceOrganisation) > 0">
                                <xsl:if test="$global_debug">
                                    <xsl:message select="concat('No party with publish role found, using originating source organisation: ', $originatingSourceOrganisation)"/> 
                                </xsl:if>
                                <xsl:value-of select="$originatingSourceOrganisation"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="$global_debug">
                                    <xsl:message select="concat('Resorting to group for publisher: ', substring-after($global_IMOS_group, ':'))"/> 
                                </xsl:if>
                                <xsl:value-of select="substring-after($global_IMOS_group, ':')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:for-each select="distinct-values($allContributorName_sequence)">
                        <contributor seq="{position()}">
                            <namePart>
                                <xsl:value-of select="."/>
                            </namePart>
                        </contributor>
                    </xsl:for-each>
                
                    <publisher>
                        <xsl:value-of select="$publisherToUse"/>
                    </publisher>
               </citationMetadata>
            </citationInfo>
        </xsl:if>
    </xsl:template>



    <!-- ====================================== -->
    <!-- Party RegistryObject - Child Templates -->
    <!-- ====================================== -->

    <!-- Party Registry Object (Individuals (person) and Organisations (group)) -->
    <xsl:template name="IMOS_partyPerson">
        <xsl:param name="originatingSourceURL"/>
        <xsl:param name="groupToUse"/>
          
        <registryObject>
            <xsl:attribute name="group" select="substring-after($groupToUse, ':')"/>

             <!--xsl:message select="concat('Creating key: ', translate(normalize-space(current-grouping-key()),' ',''))"/-->
             <!--xsl:message select="concat('Individual name: ', gmd:individualName)"/-->
             <!--xsl:message select="concat('Organisation name: ', gmd:organisationName)"/-->
             
             <key>
                <xsl:value-of select="concat(substring-before($groupToUse, ':'), '/', translate(normalize-space(current-grouping-key()),' ',''))"/>
             </key>
            
           <originatingSource>
                 <xsl:value-of select="$originatingSourceURL"/>
             </originatingSource> 
              
             <party type="person">
                 
                 <identifier type="global">
                     <xsl:value-of select="translate(normalize-space(current-grouping-key()),' ','')"/>
                 </identifier>
                 
                 <name type="primary">
                      <namePart>
                          <xsl:value-of select="normalize-space(current-grouping-key())"/>
                      </namePart>
                  </name>
     
                  <!-- If we have are dealing with individual who has an organisation name:
                      - leave out the address (so that it is on the organisation only); and 
                      - relate the individual to the organisation -->
     
                   <xsl:choose>
                      <xsl:when
                          test="string-length(normalize-space(gmd:organisationName)) > 0">
                          <!--  Individual has an organisation name, so relate the individual to the organisation, and omit the address 
                                  (the address will be included within the organisation to which this individual is related) -->
                          <relatedObject>
                              <key>
                                <xsl:value-of select="concat(substring-before($groupToUse, ':'), '/', translate(normalize-space(*:organisationName),' ',''))"/>
                              </key>
                              <relation type="isMemberOf"/>
                          </relatedObject>
                      </xsl:when>
     
                      <xsl:otherwise>
                          <!-- Individual does not have an organisation name, so physicalAddress must pertain this individual -->
                          <xsl:call-template name="physicalAddress"/>
                      </xsl:otherwise>
                  </xsl:choose>
                  
                  <!-- Individual - Phone and email on the individual, regardless of whether there's an organisation name -->
                  <xsl:call-template name="onlineResource"/>
                  <xsl:call-template name="telephone"/>
                  <xsl:call-template name="facsimile"/>
                  <xsl:call-template name="email"/>
             </party>
        </registryObject>
    </xsl:template>
        
    <!-- Party Registry Object (Individuals (person) and Organisations (group)) -->
    <xsl:template name="IMOS_partyGroup">
        <xsl:param name="originatingSourceURL"/>
        <xsl:param name="groupToUse"/>
        
        <registryObject>
            <xsl:attribute name="group" select="substring-after($groupToUse, ':')"/>
            
            <!--xsl:message select="concat('Creating key: ', translate(normalize-space(current-grouping-key()),' ',''))"/-->
            <!--xsl:message select="concat('Individual name: ', gmd:individualName)"/-->
            <!--xsl:message select="concat('Organisation name: ', gmd:organisationName)"/-->
            
            <key>
                <xsl:value-of select="concat(substring-before($groupToUse, ':'), '/', translate(normalize-space(current-grouping-key()),' ',''))"/>
            </key>
            
            <originatingSource>
                <xsl:value-of select="$originatingSourceURL"/>
            </originatingSource> 
            
            <party type="group">
                
                <identifier type="global">
                    <xsl:value-of select="translate(normalize-space(current-grouping-key()),' ','')"/>
                </identifier>
                
                <name type="primary">
                    <namePart>
                        <xsl:value-of select="normalize-space(current-grouping-key())"/>
                    </namePart>
                </name>
                
              <!-- If we are dealing with an Organisation with no individual name, phone and email must pertain to this organisation -->
                <xsl:variable name="individualName" select="normalize-space(gmd:individualName)"/>
                <xsl:if test="string-length($individualName) = 0">
                    <xsl:call-template name="onlineResource"/>
                    <xsl:call-template name="telephone"/>
                    <xsl:call-template name="facsimile"/>
                    <xsl:call-template name="email"/>
                </xsl:if>
                
                <!-- We are dealing with an organisation, so always include the address -->
                <xsl:call-template name="physicalAddress"/>
            </party>
        </registryObject>
    </xsl:template>
                     
    <xsl:template name="physicalAddress">
        <xsl:for-each select="current-group()">
            <xsl:sort
                select="count(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/child::*)"
                data-type="number" order="descending"/>

            <xsl:if test="position() = 1">
                <xsl:if
                    test="count(gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/child::*)">

                    <location>
                        <address>
                            <physical type="streetAddress">
                                <addressPart type="addressLine">
                                         <xsl:value-of select="normalize-space(current-grouping-key())"/>
                                </addressPart>
                                
                                <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gco:CharacterString[string-length(.) > 0]">
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


    <xsl:template name="telephone">
        <xsl:variable name="phone_sequence" as="xs:string*">
            <xsl:for-each select="current-group()">
                <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice">
                    <xsl:if test="string-length(normalize-space(.)) > 0">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="distinct-values($phone_sequence)">
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
    </xsl:template>
    
    <xsl:template name="facsimile">
        <xsl:variable name="facsimile_sequence" as="xs:string*">
            <xsl:for-each select="current-group()">
                <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:facsimile">
                    <xsl:if test="string-length(normalize-space(.)) > 0">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="distinct-values($facsimile_sequence)">
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
    </xsl:template>
    
    <xsl:template name="email">
        <xsl:variable name="email_sequence" as="xs:string*">
            <xsl:for-each select="current-group()">
                <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">
                    <xsl:if test="string-length(normalize-space(.)) > 0">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="distinct-values($email_sequence)">
            <location>
                <address>
                    <electronic type="email">
                        <value>
                            <xsl:value-of select="normalize-space(.)"/>
                        </value>
                    </electronic>
                </address>
            </location>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="onlineResource">
        <xsl:variable name="url_sequence" as="xs:string*">
            <xsl:for-each select="current-group()">
                <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL">
                    <xsl:if test="string-length(normalize-space(.)) > 0">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="distinct-values($url_sequence)">
            <xsl:choose>
                <xsl:when test="contains(lower-case(.), 'orcid')">
                    <identifier type="orcid">
                        <xsl:value-of select="."/> 
                    </identifier>
                </xsl:when>
                <xsl:otherwise>
                    <location>
                        <address>
                            <electronic type="url">
                                <value>
                                    <xsl:value-of select="."/>
                                </value>
                            </electronic>
                        </address>
                    </location>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
   <xsl:function name="customIMOS:registryObjectClass" as="xs:string">
        <xsl:param name="scopeCode_sequence" as="xs:string*"/>
       
       <xsl:variable name="class">
             <xsl:choose>
                  <xsl:when test="count($scopeCode_sequence) > 0">
                      <xsl:if test="$global_debug">
                          <xsl:message select="concat('ScopeCode ', $scopeCode_sequence[1])"/>
                      </xsl:if>
                      <xsl:choose>
                          <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'dataset')">
                              <xsl:text>collection</xsl:text>
                          </xsl:when>
                          <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'collectionhardware')">
                              <xsl:text>activity</xsl:text>
                          </xsl:when>
                          <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'series')">
                              <xsl:text>activity</xsl:text>
                          </xsl:when>
                          <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'software')">
                              <xsl:text>collection</xsl:text>
                          </xsl:when>
                          <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'model')">
                              <xsl:text>collection</xsl:text>
                          </xsl:when>
                          <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'service')">
                              <xsl:text>service</xsl:text>
                          </xsl:when>
                          <xsl:otherwise>
                              <xsl:text>collection</xsl:text>
                          </xsl:otherwise>
                      </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:text>collection</xsl:text>
                  </xsl:otherwise>
             </xsl:choose>
        </xsl:variable>
       
       <xsl:if test="$global_debug">
           <xsl:message select="concat('Determined class ', $class)"/>
       </xsl:if>
       
       <xsl:value-of select="$class"/>
       
     </xsl:function>
    
    <xsl:function name="customIMOS:registryObjectType" as="xs:string*">
        <xsl:param name="scopeCode_sequence" as="xs:string*"/>
        <xsl:choose>
            <xsl:when test="count($scopeCode_sequence) > 0">
                <xsl:choose>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'dataset')">
                        <xsl:text>dataset</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'collectionhardware')">
                        <xsl:text>project</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'series')">
                        <xsl:text>program</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'software')">
                        <xsl:text>software</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'model')">
                        <xsl:text>software</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'service')">
                        <xsl:text>report</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>dataset</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>dataset</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
  
</xsl:stylesheet>
