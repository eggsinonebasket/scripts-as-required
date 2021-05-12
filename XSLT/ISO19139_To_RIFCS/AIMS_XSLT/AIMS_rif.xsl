<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp" 
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:gts="http://www.isotc211.org/2005/gts"
    xmlns:geonet="http://www.fao.org/geonetwork" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:customAIMS="http://customAIMS.nowhere.yet"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:customGMD="http://customGMD.nowhere.yet"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="geonet gmx oai xsi gmd srv gml gco gts customAIMS custom customGMD">
    <xsl:import href="CustomFunctions.xsl"/>
    <xsl:import href="CustomFunctionsGMD.xsl"/>
    <!-- stylesheet to convert iso19139 in OAI-PMH ListRecords response to RIF-CS -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:param name="global_AIMS_group" select="'AIMS:Australian Institute of Marine Science'"/>
    <xsl:param name="global_AIMS_sourceURL" select="'http://data.aims.gov.au'"/>
    <!--xsl:param name="global_AIMS_defaultOriginatingSourceOrganisation" select="'undetermined'"/-->
    
    <xsl:param name="global_AIMS_path" select="'/metadataviewer/faces/view.xhtml?uuid='"/>
    
    <xsl:variable name="anzsrcCodelist" select="document('anzsrc-codelist.xml')"/>
    <xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/>
    <xsl:variable name="gmdCodelists" select="document('codelists.xml')"/>
   
    <xsl:template match="oai:responseDate"/>
    <xsl:template match="oai:request"/>
    <xsl:template match="oai:error"/>
    <xsl:template match="oai:GetRecord/oai:record/oai:header/oai:identifier"/>
    <xsl:template match="oai:GetRecord/oai:record/oai:header/oai:datestamp"/>
    <xsl:template match="oai:GetRecord/oai:record/oai:header/oai:setSpec"/>
    <xsl:template match="oai:ListRecords/oai:record/oai:header/oai:identifier"/>
    <xsl:template match="oai:ListRecords/oai:record/oai:header/oai:datestamp"/>
    <xsl:template match="oai:ListRecords/oai:record/oai:header/oai:setSpec"/>
    
    <!-- =========================================== -->
    <!-- RegistryObjects (root) Template             -->
    <!-- =========================================== -->
    
    <xsl:template match="/">
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            
            <xsl:apply-templates select="//*:MD_Metadata" mode="AIMS"/>
            
        </registryObjects>
    </xsl:template>
  
    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject Template          -->
    <!-- =========================================== -->

    <xsl:template match="*:MD_Metadata" mode="AIMS">
        <xsl:param name="aggregatingGroup"/>
        
        <xsl:message>AIMS XSLT</xsl:message>
       
        <xsl:variable name="groupToUse">
            <xsl:choose>
                <xsl:when test="string-length($aggregatingGroup) > 0">
                    <xsl:value-of select="$aggregatingGroup"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$global_AIMS_group"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="metadataTruthURL" select="(gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage[contains(lower-case(following-sibling::gmd:protocol), 'metadata-url')]/gmd:URL)[1]"/>
        <xsl:message select="concat('metadataTruthURL: ', $metadataTruthURL)"/>
       
        <xsl:variable name="datasetURI" select="gmd:dataSetURI"/>
        <xsl:message select="concat('datasetURI: ', $datasetURI)"/>
        
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
        
        <xsl:message select="concat('originatingSourceURL: ', $originatingSourceURL)"/>
        
        <xsl:variable name="originatingSourceOrganisation" select="customGMD:originatingSourceOrganisation(.)"/>
        <xsl:message select="concat('$originatingSourceOrganisation: ', $originatingSourceOrganisation)"/>
        
        <xsl:variable name="downloaddataURL_sequence" select="customAIMS:getDownloadURL_sequence(*:distributionInfo/*:MD_Distribution/*:transferOptions/*:MD_DigitalTransferOptions)"/>
        <xsl:variable name="title" select="*:identificationInfo/*/*:citation/*:CI_Citation/*:title"/>
        <xsl:variable name="restrictionCode_sequence" select="*:identificationInfo/*/*:resourceConstraints/*/*/*:MD_RestrictionCode/@codeListValue"/>
        <xsl:variable name="otherConstraints_sequence" select="*:identificationInfo/*/*:resourceConstraints/*/*:otherConstraints"/>
        
        <xsl:variable name="fileIdentifier" select="*:fileIdentifier"/>
        
        <xsl:for-each select="distinct-values($restrictionCode_sequence)">
            <xsl:message select="concat('restrictionCode :', .)"/>
        </xsl:for-each>
        
        <xsl:variable name="coordinateReferenceSystem">
            <xsl:variable name="coordinateReferenceSystem_sequence" as="xs:string*">
                <xsl:for-each select="*:referenceSystemInfo/*:MD_ReferenceSystem">
                    <xsl:if test="(string-length(*:referenceSystemIdentifier/*:RS_Identifier/*:codeSpace) > 0)">
                        <xsl:copy-of select="*:referenceSystemIdentifier/*:RS_Identifier/*:codeSpace"/>
                    </xsl:if>
                    <xsl:if test="(string-length(*:referenceSystemIdentifier/*:RS_Identifier/*:codeSpace) > 0) and (string-length(*:referenceSystemIdentifier/*:RS_Identifier/*:code) > 0)">
                        <xsl:copy-of select="':'"/>
                    </xsl:if>
                    <xsl:if test="(string-length(*:referenceSystemIdentifier/*:RS_Identifier/*:code) > 0)">
                        <xsl:copy-of select="*:referenceSystemIdentifier/*:RS_Identifier/*:code"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <xsl:if test="count($coordinateReferenceSystem_sequence) > 0">
                <xsl:copy-of select="$coordinateReferenceSystem_sequence[1]"/>
            </xsl:if>
        </xsl:variable>
           
        <xsl:variable name="locationURL_sequence" as="xs:string*">
            <xsl:choose>
                <xsl:when test="string-length($metadataTruthURL) > 0">
                    <xsl:value-of select="$metadataTruthURL"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($global_AIMS_sourceURL, $global_AIMS_path, $fileIdentifier)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="dataSetURI" select="*:dataSetURI"/>
        
        <xsl:variable name="scopeCode">
            <xsl:choose>
                <xsl:when test="string-length(normalize-space(*:hierarchyLevel/gmx:MX_ScopeCode/@codeListValue)) > 0">
                    <xsl:value-of select="normalize-space(*:hierarchyLevel/gmx:MX_ScopeCode/@codeListValue)"/>
                </xsl:when>
                <xsl:when test="string-length(normalize-space(*:hierarchyLevel/*:MD_ScopeCode/@codeListValue)) > 0">
                    <xsl:value-of select="normalize-space(*:hierarchyLevel/*:MD_ScopeCode/@codeListValue)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>dataset</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <registryObject>
             <xsl:attribute name="group" select="substring-after($groupToUse, ':')"/>
                
                <xsl:apply-templates select="*:fileIdentifier" mode="AIMS_registryObject_key">
                    <xsl:with-param name="groupToUse" select="$groupToUse"/>
                </xsl:apply-templates>

                <originatingSource>
                    <xsl:value-of select="$originatingSourceURL"/>    
                </originatingSource>
                
                <xsl:variable name="metadataCreationDate">
                    <xsl:if test="string-length(normalize-space(*:dateStamp/gco:Date)) > 0">
                        <xsl:value-of select="normalize-space(*:dateStamp/gco:Date)"/>
                    </xsl:if>
                    <xsl:if test="string-length(normalize-space(*:dateStamp/gco:DateTime)) > 0">
                        <xsl:value-of select="normalize-space(*:dateStamp/gco:DateTime)"/>
                    </xsl:if>
                </xsl:variable>
                
                <xsl:variable name="registryObjectTypeSubType_sequence" as="xs:string*" select="customAIMS:getRegistryObjectTypeSubType_AIMS($scopeCode)"/>
                <xsl:if test="(count($registryObjectTypeSubType_sequence) = 2)">
                    <xsl:element name="{$registryObjectTypeSubType_sequence[1]}">
    
                        <xsl:attribute name="type">
                            <xsl:value-of select="$registryObjectTypeSubType_sequence[2]"/>
                        </xsl:attribute>
                        
                        <xsl:if test="$registryObjectTypeSubType_sequence[1] = 'collection'">
                             <xsl:attribute name="dateAccessioned">
                                 <xsl:value-of select="$metadataCreationDate"/>
                             </xsl:attribute>
                        </xsl:if>
                       
                        <xsl:apply-templates select="*:fileIdentifier" 
                            mode="AIMS_registryObject_identifier"/>
                        
                        <xsl:apply-templates select="
                            *:identificationInfo/*/*:citation/*:CI_Citation/*:identifier" 
                            mode="AIMS_registryObject_identifier"/>
    
                        <!--The following is commented out to not
                            use point of truth as identifier as  
                            this caused a problem when a child record
                            had its parent's doi in point of truth. 
                            Anyway, I don't think we need to have this
                            here anyway because linking will be 
                            by uuid (for linking identical metadata
                            from various catalogues) -->
                        <!--xsl:apply-templatess
                            select="*:distributionInfo/*:MD_Distribution"
                            mode="AIMS_registryObject_identifier"/-->
                        
                        <xsl:apply-templates
                            select="*:distributionInfo/*:MD_Distribution"
                            mode="AIMS_registryObject_location_download"/>
    
                        <xsl:apply-templates
                            select="*:identificationInfo/*/*:citation/*:CI_Citation/*:title"
                            mode="AIMS_registryObject_name"/>
    
                        <xsl:apply-templates select="*:parentIdentifier"
                            mode="AIMS_registryObject_related_object">
                            <xsl:with-param name="groupToUse" select="$groupToUse"/>
                        </xsl:apply-templates>
    
                        <xsl:copy-of select="customAIMS:set_registryObject_location_metadata($locationURL_sequence, 'landingPage')"/>
                        <xsl:copy-of select="customAIMS:set_registryObject_location_metadata($downloaddataURL_sequence, 'directDownload')"/>
                        
                        <xsl:copy-of select="customAIMS:set_registryObject_accessRights($downloaddataURL_sequence, $restrictionCode_sequence, $otherConstraints_sequence)"/>
                        
                        <!-- individuals - use the role provided for relation -->
                        <!-- xsl:for-each-group
                            select="*:identificationInfo/*/*:citation/*:CI_Citation/*:citedResponsibleParty/*:CI_ResponsibleParty[string-length(normalize-space(*:individualName)) > 0]"
                            group-by="*:individualName">
                            <xsl:apply-templates select="." mode="AIMS_registryObject_related_object">
                                <xsl:with-param name="groupToUse" select="$groupToUse"/>
                            </xsl:apply-templates>
                        </xsl:for-each-group -->
    
                        <!-- organisations with no individual name - use the role provided for relation -->
                        <xsl:for-each-group
                            select="*:identificationInfo/*/*:citation/*:CI_Citation/*:citedResponsibleParty/*:CI_ResponsibleParty[((string-length(normalize-space(*:organisationName))) > 0)] |
                            *:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributorContact/*:CI_ResponsibleParty[((string-length(normalize-space(*:organisationName))) > 0)] |
                            *:identificationInfo/*/*:pointOfContact/*:CI_ResponsibleParty[((string-length(normalize-space(*:organisationName))) > 0)]"
                            group-by="*:organisationName">
                            <xsl:apply-templates select="." mode="AIMS_registryObject_related_object">
                                <xsl:with-param name="groupToUse" select="$groupToUse"/>
                            </xsl:apply-templates>
                        </xsl:for-each-group>
                        
                        <xsl:apply-templates select="*:children/*:childIdentifier"
                            mode="AIMS_registryObject_related_object">
                            <xsl:with-param name="groupToUse" select="$groupToUse"/>
                        </xsl:apply-templates>
    
                        <xsl:apply-templates
                            select="*:identificationInfo/*/*:topicCategory/*:MD_TopicCategoryCode"
                            mode="AIMS_registryObject_subject"/>
                        
                        <xsl:apply-templates
                            select="*:identificationInfo/*/*:topicCategory/*:MD_TopicCategoryCode"
                            mode="AIMS_registryObject_subject"/>
    
                        <xsl:apply-templates
                            select="*:identificationInfo/*[contains(local-name(), 'ServiceIdentification')]"
                            mode="AIMS_registryObject_subject"/>
                        
                        <xsl:apply-templates
                            select="*:identificationInfo/*/*:abstract"
                            mode="AIMS_registryObject_description_brief"/>
    
                        <xsl:apply-templates
                            select="*:identificationInfo/*/*:purpose"
                            mode="AIMS_registryObject_description_notes"/>
                        
                        <xsl:apply-templates
                            select="*:identificationInfo/*/*:credit"
                            mode="AIMS_registryObject_description_notes"/>
                                                
                        <xsl:call-template name="AIMS_set_registryObject_coverage_spatial">
                            <xsl:with-param name="boundingBox" select="*:identificationInfo/*/*:extent/*:EX_Extent/*:geographicElement/*:EX_GeographicBoundingBox"/>
                            <xsl:with-param name="coordinateReferenceSystem" select="$coordinateReferenceSystem"/>
                        </xsl:call-template>
                        
                        <xsl:apply-templates
                            select="gmd:identificationInfo/*/gmd:extent/gmd:EX_Extent/gmd:temporalElement/*:EX_TemporalExtent/gmd:extent"
                            mode="AIMS_registryObject_coverage_temporal"/>
                        
                        <xsl:if test="($registryObjectTypeSubType_sequence[1] = 'activity') or ($registryObjectTypeSubType_sequence[1] = 'party')">
                            <xsl:apply-templates
                                select="gmd:identificationInfo/*/gmd:extent/gmd:EX_Extent/gmd:temporalElement/*:EX_TemporalExtent/gmd:extent"
                                mode="AIMS_registryObject_existence_dates"/>
                        </xsl:if>
                        
                        <xsl:apply-templates
                            select="*:identificationInfo/srv:SV_ServiceIdentification/srv:operatesOn"
                            mode="AIMS_registryObject_relatedInfo"/>
                        
                        <xsl:apply-templates
                            select="*:distributionInfo/*:MD_Distribution"
                            mode="AIMS_registryObject_relatedInfo"/>
                        
                        <xsl:apply-templates
                            select="*:dataQualityInfo/*:DQ_DataQuality/*:lineage/*:LI_Lineage/*:source/*:LI_Source[string-length(*:sourceCitation/*:CI_Citation/*:identifier/*:MD_Identifier/*:code) > 0]"
                            mode="AIMS_registryObject_relatedInfo"/>
    
                        <xsl:apply-templates select="*:children/*:childIdentifier"
                            mode="AIMS_registryObject_relatedInfo"/>
    
                        <xsl:apply-templates
                            select="*:identificationInfo/*/*:resourceConstraints/*:MD_CreativeCommons[exists(*:licenseLink)]"
                            mode="AIMS_registryObject_rights_licence_creative"/>
    
                        <xsl:apply-templates
                            select="*:identificationInfo/*/*:resourceConstraints/*:MD_CreativeCommons"
                            mode="AIMS_registryObject_rights_rightsStatement_creative"/>
    
                        <xsl:apply-templates
                            select="*:identificationInfo/*/*:resourceConstraints/*:MD_Commons[exists(*:licenseLink)]"
                            mode="AIMS_registryObject_rights_licence_creative"/>
                        
                        <xsl:apply-templates
                            select="*:identificationInfo/*/*:resourceConstraints/*:MD_Commons"
                            mode="AIMS_registryObject_rights_rightsStatement_creative"/>
                        
                        <xsl:apply-templates
                            select="*:identificationInfo/*/*:resourceConstraints/*:MD_LegalConstraints"
                            mode="AIMS_registryObject_rights_rights"/>
    
                        <xsl:apply-templates
                            select="*:identificationInfo/*/*:resourceConstraints/*:MD_Constraints"
                            mode="AIMS_registryObject_rights_rights"/>
                        
                        <xsl:if test="$registryObjectTypeSubType_sequence[1] = 'collection'">
                          
                            <xsl:apply-templates
                                select="*:identificationInfo/*/*:citation/*:CI_Citation/*:date"
                                 mode="AIMS_registryObject_dates"/>
                          
                             <xsl:for-each
                                 select="*:identificationInfo/*/*:citation/*:CI_Citation">
                                 <xsl:call-template name="AIMS_registryObject_citationMetadata_citationInfo">
                                     <xsl:with-param name="locationURL_sequence" select="$locationURL_sequence"/>
                                     <xsl:with-param name="originatingSourceOrganisation" select="$originatingSourceOrganisation"/>
                                     <xsl:with-param name="citation" select="."/>
                                     <xsl:with-param name="metadataCreationDate" select="$metadataCreationDate"/>
                                 </xsl:call-template>
                             </xsl:for-each>
                        </xsl:if>
                    </xsl:element>
                </xsl:if>
        </registryObject>
        

        <!-- =========================================== -->
        <!-- Party RegistryObject Template          -->
        <!-- =========================================== -->

        <!-- xsl:for-each-group
            select="*:identificationInfo/*/*:citation/*:CI_Citation/*:citedResponsibleParty/*:CI_ResponsibleParty[(string-length(normalize-space(*:individualName))) > 0] "
            group-by="*:individualName">
            <xsl:call-template name="AIMS_party">
                <xsl:with-param name="type">person</xsl:with-param>
                <xsl:with-param name="originatingSourceURL" select="$originatingSourceURL"/>
                <xsl:with-param name="groupToUse" select="$groupToUse"/>
            </xsl:call-template>
        </xsl:for-each-group -->

        <xsl:for-each-group
            select="*:identificationInfo/*/*:citation/*:CI_Citation/*:citedResponsibleParty/*:CI_ResponsibleParty[(string-length(normalize-space(*:organisationName))) > 0] |
            *:distributionInfo/*:MD_Distribution/*:distributor/*:MD_Distributor/*:distributorContact/*:CI_ResponsibleParty[(string-length(normalize-space(*:organisationName))) > 0] |
            *:identificationInfo/*/*:pointOfContact/*:CI_ResponsibleParty[(string-length(normalize-space(*:organisationName))) > 0]"
            group-by="*:organisationName">
            <xsl:call-template name="AIMS_party">
                <xsl:with-param name="type">group</xsl:with-param>
                <xsl:with-param name="originatingSourceURL" select="$originatingSourceURL"/>
                <xsl:with-param name="groupToUse" select="$groupToUse"/>
            </xsl:call-template>
        </xsl:for-each-group>

    </xsl:template>

    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject - Child Templates -->
    <!-- =========================================== -->

    <!-- RegistryObject - Key Element  -->
    <xsl:template match="*:fileIdentifier" mode="AIMS_registryObject_key">
        <xsl:param name="groupToUse"/>
        <key>
            <xsl:value-of select="concat(substring-before($groupToUse, ':'), '/', normalize-space(.))"/>
        </key>
    </xsl:template>

   <!-- RegistryObject - Identifier Element  -->
    <xsl:template match="*:fileIdentifier" mode="AIMS_registryObject_identifier">
        <xsl:variable name="identifier" select="normalize-space(.)"/>
        <xsl:if test="string-length($identifier) > 0">
            <identifier>
                <xsl:attribute name="type">
                    <xsl:text>local</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="$identifier"/>
            </identifier>
            <identifier>
                <xsl:attribute name="type">
                    <xsl:text>global</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="$identifier"/>
            </identifier>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:identifier" mode="AIMS_registryObject_identifier">
        <xsl:variable name="code" select="normalize-space(*:MD_Identifier/*:code)"></xsl:variable>
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
                <xsl:value-of select="$code"/>
            </identifier>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Identifier Element  -->
    <xsl:template match="*:MD_Distribution" mode="AIMS_registryObject_identifier">
        <xsl:variable name="metadataURL_sequence" as="xs:string*">
            <xsl:for-each select="*:transferOptions/*:MD_DigitalTransferOptions/*:onLine/*:CI_OnlineResource">
                <xsl:if test="contains(lower-case(*:protocol), 'metadata-url')">
                    <xsl:if test="string-length(normalize-space(*:linkage/*:URL)) > 0">
                        <xsl:copy-of select="normalize-space(*:linkage/*:URL)"/>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:for-each select="distinct-values($metadataURL_sequence)">
            <identifier>
                <xsl:attribute name="type">
                    <xsl:text>uri</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </identifier>
        </xsl:for-each>
    </xsl:template>


    <!-- RegistryObject - Identifier Element  -->
    <xsl:template match="*:MD_Distribution" mode="AIMS_registryObject_location_download">
        <xsl:for-each select="*:transferOptions/*:MD_DigitalTransferOptions/*:onLine/*:CI_OnlineResource">
            <xsl:if test="contains(lower-case(*:protocol), 'downloaddata')">
                <xsl:if test="string-length(normalize-space(*:linkage/*:URL)) > 0">
                    <xsl:variable name="title" select="*:description"/>
                    <xsl:variable name="notes" select="''"/>
                    <xsl:variable name="mediaType" select="*:name/*:MimeFileType/@type"/>
                    <xsl:variable name="byteSize" select="../../*:transferSize/*:Real"/>
                    <location>
                        <address>
                        <electronic>
                            <xsl:attribute name="type">
                                <xsl:text>url</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="target">
                                <xsl:text>directDownload</xsl:text>
                            </xsl:attribute>
                            <value>
                                <xsl:value-of select="normalize-space(*:linkage/*:URL)"/>
                            </value>
                            <xsl:if test="string-length($title) > 0">
                                <title>
                                    <xsl:value-of select="$title"/>
                                </title>
                            </xsl:if>
                            <xsl:if test="string-length($notes) > 0">
                                <notes>
                                    <xsl:value-of select="$notes"/>
                                </notes>
                            </xsl:if>
                            <xsl:if test="string-length($mediaType) > 0">
                                <mediaType>
                                    <xsl:value-of select="$mediaType"/>
                                </mediaType>
                            </xsl:if>
                            <xsl:if test="string-length($byteSize) > 0">
                                <byteSize>
                                    <xsl:value-of select="$byteSize"/>
                                </byteSize>
                            </xsl:if>
                        </electronic>
                    </address>
                    </location>   
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <!-- RegistryObject - Name Element  -->
    <xsl:template
        match="*:citation/*:CI_Citation/*:title"
        mode="AIMS_registryObject_name">
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
        match="*:citation/*:CI_Citation/*:date"
        mode="AIMS_registryObject_dates">
        <xsl:variable name="dateValue">
            <xsl:if test="string-length(normalize-space(*:CI_Date/*:date/gco:Date)) > 0">
                <xsl:value-of select="normalize-space(*:CI_Date/*:date/gco:Date)"/>
            </xsl:if>
            <xsl:if test="string-length(normalize-space(*:CI_Date/*:date/gco:DateTime)) > 0">
                <xsl:value-of select="normalize-space(*:CI_Date/*:date/gco:DateTime)"/>
            </xsl:if>
        </xsl:variable> 
        <xsl:variable name="dateCode"
            select="normalize-space(*:CI_Date/*:dateType/*:CI_DateTypeCode/@codeListValue)"/>
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
    <xsl:template match="*:parentIdentifier" mode="AIMS_registryObject_related_object">
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
    
    <!-- RegistryObject - Location Element  -->
    <xsl:function name="customAIMS:set_registryObject_location_metadata">
        <xsl:param name="uri_sequence" as="xs:string*"/>
        <xsl:param name="target" as="xs:string"/>
        <xsl:for-each select="distinct-values($uri_sequence)">
            <xsl:if test="string-length(normalize-space(.)) > 0">
                <location>
                    <address>
                        <electronic>
                            <xsl:attribute name="type">
                                <xsl:text>url</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="target">
                                <xsl:value-of select="$target"/>
                            </xsl:attribute>
                            <value>
                                <xsl:value-of select="normalize-space(.)"/>
                            </value>
                        </electronic>
                    </address>
                </location>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <!-- RegistryObject - Location Element  -->
    <xsl:function name="customAIMS:set_registryObject_accessRights">
        <xsl:param name="downloaddataURL_sequence"/>
        <xsl:param name="restrictionCode_sequence"/>
        <xsl:param name="otherConstraints_sequence"/>
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="boolean(customAIMS:sequence_contains($restrictionCode_sequence, 'restricted')) = true()">
                    <xsl:text>restricted</xsl:text>
                </xsl:when>
                <xsl:when test="count($downloaddataURL_sequence) > 0">
                    <xsl:text>open</xsl:text>
                </xsl:when>
                <xsl:when test="boolean(customAIMS:sequence_contains($otherConstraints_sequence, 'exclusive access period')) = true()">
                    <xsl:text>conditional</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$type = 'open'">
            <rights>
                <accessRights>
                    <xsl:attribute name="type" select="$type"/>
                </accessRights>
            </rights>
        </xsl:if>
    </xsl:function>
    
    
    <!-- RegistryObject - Related Object (Organisation or Individual) Element -->
    <xsl:template match="*:CI_ResponsibleParty" mode="AIMS_registryObject_related_object">
        <xsl:param name="groupToUse"/>
         <relatedObject>
            <key>
               <xsl:value-of select="concat(substring-before($groupToUse, ':'), '/', translate(normalize-space(current-grouping-key()),' ',''))"/>
            </key>
            <xsl:for-each-group select="current-group()/*:role"
                group-by="*:CI_RoleCode/@codeListValue">
                <xsl:variable name="code">
                    <xsl:value-of select="normalize-space(current-grouping-key())"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="string-length($code) > 0">
                        <relation>
                            <xsl:attribute name="type">
                                <xsl:value-of select="$code"/>
                            </xsl:attribute>
                        </relation>
                    </xsl:when>
                    <xsl:otherwise>
                        <relation>
                            <xsl:attribute name="type">
                                <xsl:text>unknown</xsl:text>
                            </xsl:attribute>
                        </relation>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:for-each-group>
        </relatedObject>
    </xsl:template>
    
    <!-- RegistryObject - Organisation which has an Individual name - relate indirectly, by association, only -->
    <xsl:template match="*:CI_ResponsibleParty" mode="AIMS_registryObject_related_object_associated">
        <xsl:param name="groupToUse"/>
        <relatedObject>
            <key>
                <xsl:value-of select="concat(substring-before($groupToUse, ':'), '/', translate(normalize-space(current-grouping-key()),' ',''))"/>
            </key>
            <relation>
                <xsl:attribute name="type">
                    <xsl:value-of select="'hasAssociationWith'"/>
                </xsl:attribute>
            </relation>
        </relatedObject>
    </xsl:template>

    <!-- RegistryObject - Related Object Element  -->
    <xsl:template match="*:childIdentifier" mode="AIMS_registryObject_related_object">
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

    <!-- RegistryObject - Subject Element -->
    <xsl:template match="*[contains(local-name(), 'DataIdentification') or contains(local-name(), 'ServiceIdentification')]" mode="AIMS_registryObject_subject">
        <xsl:call-template name="AIMS_registryObject_subject">
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="AIMS_registryObject_subject">
        <xsl:param name="node"/>
            
        <xsl:variable name="subject_sequence">
            <xsl:for-each select="$node/*:descriptiveKeywords/*:MD_Keywords/*:keyword">
                <xsl:value-of select="normalize-space(.)"/>
                <xsl:text>|</xsl:text>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:for-each select="distinct-values(tokenize($subject_sequence, '\|'))">
            <xsl:if test="string-length(normalize-space(.)) > 0">
                <subject type="local">
                    <xsl:value-of select="normalize-space(.)"/>
                </subject>
            </xsl:if>
        </xsl:for-each>
        
        
        <xsl:variable name="anzsrcMappedCode_sequence" as="xs:string*">
            <xsl:for-each select="distinct-values(tokenize($subject_sequence, '\|'))">
                
                <xsl:if test="string-length(normalize-space(.)) > 0">
                     <xsl:variable name="subjectSplit_sequence" as="xs:string*" select="tokenize(normalize-space(.), '&gt;')"/>
                     <xsl:for-each select="distinct-values($subjectSplit_sequence)">
                         
                         <!-- seek an anzsrc-code within the text -->
                         <xsl:variable name="match" as="xs:string*">
                             <xsl:analyze-string select="normalize-space(.)"
                                 regex="[0-9]+">
                                 <xsl:matching-substring>
                                     <xsl:value-of select="regex-group(0)"/>
                                 </xsl:matching-substring>
                             </xsl:analyze-string>
                         </xsl:variable>
                         
                         <xsl:if test="count($match) > 0">
                             <xsl:for-each select="distinct-values($match)">
                                 <xsl:if test="string-length(normalize-space(.)) > 0">
                                     <xsl:value-of select="."/>
                                 </xsl:if>
                             </xsl:for-each>
                         </xsl:if>
                         
                         <!-- determines whether any text has a corresponding mapped code -->
                         <xsl:variable name="keyword" select="normalize-space(.)"/>
                         <xsl:variable name="code"
                         select="(normalize-space($anzsrcCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='ANZSRCCode']/gmx:codeEntry/gmx:CodeDefinition/gml:identifier[lower-case(following-sibling::gml:name) = lower-case($keyword)]))[1]"/>
                         <xsl:if test="string-length($code) > 0">
                             <xsl:value-of select="$code"/>
                         </xsl:if>
                         
                     </xsl:for-each>
                 </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:for-each select="reverse($anzsrcMappedCode_sequence)">
            <subject>
                <xsl:attribute name="type">
                    <xsl:value-of select="'anzsrc-for'"/>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </subject>
        </xsl:for-each>
    </xsl:template>
    
   <xsl:template match="*:MD_TopicCategoryCode" mode="AIMS_registryObject_subject">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <subject type="local">
                <xsl:value-of select="."></xsl:value-of>
            </subject>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Decription Element -->
    <xsl:template match="*:abstract" mode="AIMS_registryObject_description_brief">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="brief">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Decription Element -->
    <xsl:template match="*:purpose" mode="AIMS_registryObject_description_notes">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="note">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Decription Element -->
    <xsl:template match="*:credit" mode="AIMS_registryObject_description_notes">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="note">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Coverage Spatial Element -->
    <xsl:template name="AIMS_set_registryObject_coverage_spatial">
        <xsl:param name="boundingBox" as="node()*"/>
        <xsl:param name="coordinateReferenceSystem"/>
        <xsl:for-each select="$boundingBox">
            <xsl:if test="string-length(normalize-space(*:northBoundLatitude/gco:Decimal)) > 0"/>
            <xsl:if
                 test="
                    (string-length(normalize-space(*:northBoundLatitude/gco:Decimal)) > 0) and
                    (string-length(normalize-space(*:southBoundLatitude/gco:Decimal)) > 0) and
                    (string-length(normalize-space(*:westBoundLongitude/gco:Decimal)) > 0) and
                    (string-length(normalize-space(*:eastBoundLongitude/gco:Decimal)) > 0)">
                     <xsl:variable name="spatialString">
                         <xsl:value-of
                             select="normalize-space(concat('northlimit=',*:northBoundLatitude/gco:Decimal,'; southlimit=',*:southBoundLatitude/gco:Decimal,'; westlimit=',*:westBoundLongitude/gco:Decimal,'; eastLimit=',*:eastBoundLongitude/gco:Decimal))"/>
                         
                         <xsl:if
                             test="
                             (string-length(normalize-space(*:EX_VerticalExtent/*:maximumValue/gco:Real)) > 0) and
                             (string-length(normalize-space(*:EX_VerticalExtent/*:minimumValue/gco:Real)) > 0)">
                             <xsl:value-of
                                 select="normalize-space(concat('; uplimit=',*:EX_VerticalExtent/*:maximumValue/gco:Real,'; downlimit=',*:EX_VerticalExtent/*:minimumValue/gco:Real))"
                             />
                         </xsl:if>
                         <xsl:choose>
                             <xsl:when test="string-length(normalize-space($coordinateReferenceSystem)) > 0">
                                 <xsl:value-of select="concat('; projection=', $coordinateReferenceSystem)"/>
                              </xsl:when>
                             <xsl:otherwise>
                                 <!-- try to obtain from srsName -->
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
           </xsl:for-each>
    </xsl:template>


    <!-- RegistryObject - Coverage Spatial Element -->
    <xsl:template match="*:EX_BoundingPolygon" mode="AIMS_registryObject_coverage_spatial">
        <xsl:if
            test="string-length(normalize-space(*:polygon/gml:Polygon/gml:exterior/gml:LinearRing/gml:coordinates)) > 0">
            <coverage>
                <spatial>
                    <xsl:attribute name="type">
                        <xsl:text>gmlKmlPolyCoords</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of
                        select="replace(normalize-space(*:polygon/gml:Polygon/gml:exterior/gml:LinearRing/gml:coordinates), ',0', '')"
                    />
                </spatial>
            </coverage>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Coverage Temporal Element -->
    <xsl:template match="gmd:extent" mode="AIMS_registryObject_coverage_temporal">
        <xsl:if
            test="string-length(normalize-space(gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) > 0 or
            string-length(normalize-space(gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)) > 0">
            <coverage>
                <temporal>
                    <xsl:if
                        test="string-length(normalize-space(gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateFrom</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)"
                            />
                        </date>
                    </xsl:if>
                    <xsl:if
                        test="string-length(normalize-space(gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateTo</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)"
                            />
                        </date>
                    </xsl:if>
                </temporal>
            </coverage>
        </xsl:if>
        
        <xsl:if
            test="string-length(normalize-space(gml:TimePeriod/gml:beginPosition)) > 0 or
            string-length(normalize-space(gml:TimePeriod/gml:endPosition)) > 0">
            <coverage>
                <temporal>
                    <xsl:if
                        test="string-length(normalize-space(gml:TimePeriod/gml:beginPosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateFrom</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gml:TimePeriod/gml:beginPosition)"
                            />
                        </date>
                    </xsl:if>
                    <xsl:if
                        test="string-length(normalize-space(gml:TimePeriod/gml:endPosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateTo</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gml:TimePeriod/gml:endPosition)"
                            />
                        </date>
                    </xsl:if>
                </temporal>
            </coverage>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Coverage Temporal Element -->
    <xsl:template match="gmd:extent" mode="AIMS_registryObject_existence_dates">
        <xsl:if
            test="string-length(normalize-space(gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) > 0 or
            string-length(normalize-space(gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)) > 0">
            <existenceDates>
                <xsl:if
                    test="string-length(normalize-space(gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)) > 0">
                    <startDate>
                        <xsl:attribute name="dateFormat">
                            <xsl:text>W3CDTF</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of
                            select="normalize-space(gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition)"
                        />
                    </startDate>
                </xsl:if>
                <xsl:if
                    test="string-length(normalize-space(gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)) > 0">
                    <endDate>
                        <xsl:attribute name="dateFormat">
                            <xsl:text>W3CDTF</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of
                            select="normalize-space(gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition)"
                        />
                    </endDate>
                </xsl:if>
            </existenceDates>
        </xsl:if>
        
        <xsl:if
            test="string-length(normalize-space(gml:TimePeriod/gml:beginPosition)) > 0 or
            string-length(normalize-space(gml:TimePeriod/gml:endPosition)) > 0">
            <existenceDates>
                <xsl:if
                    test="string-length(normalize-space(gml:TimePeriod/gml:beginPosition)) > 0">
                    <startDate>
                        <xsl:attribute name="dateFormat">
                            <xsl:text>W3CDTF</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of
                            select="normalize-space(gml:TimePeriod/gml:beginPosition)"
                        />
                    </startDate>
                </xsl:if>
                <xsl:if
                    test="string-length(normalize-space(gml:TimePeriod/gml:endPosition)) > 0">
                    <endDate>
                        <xsl:attribute name="dateFormat">
                            <xsl:text>W3CDTF</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of
                            select="normalize-space(gml:TimePeriod/gml:endPosition)"
                        />
                    </endDate>
                </xsl:if>
            </existenceDates>
        </xsl:if>
    </xsl:template>
    

    

    <!-- RegistryObject - RelatedInfo Element  -->
    <xsl:template match="*:MD_Distribution" mode="AIMS_registryObject_relatedInfo">
       
        <xsl:for-each-group select="*:transferOptions/*:MD_DigitalTransferOptions/*:onLine/*:CI_OnlineResource" group-by="*:linkage/*:URL">

            <xsl:variable name="protocol" select="normalize-space(*:protocol)"/>
            <!-- metadata-URL was added as electronic address and possibly citation identifier, too
                 (if there was no alternative identifier - e.g. DOI - specified in CI_Citation)
                 Add all other online resources here as relatedInfo -->
            <xsl:if test="(string-length($protocol) > 0) and not(contains(lower-case($protocol), 'metadata-url'))">

                <xsl:variable name="identifierValue" select="normalize-space(current-grouping-key())"/>
                <xsl:if test="string-length($identifierValue) > 0">
                    <relatedInfo>
                        <xsl:choose>
                            <xsl:when test="contains(lower-case($protocol), 'get-map')">
                                <xsl:attribute name="type">
                                    <xsl:value-of select="'service'"/>
                                </xsl:attribute>

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
                                    <xsl:value-of select="$identifierValue"/>
                                </identifier>

                                <relation>
                                    <xsl:attribute name="type">
                                        <xsl:text>isAvailableThrough</xsl:text>
                                    </xsl:attribute>
                                </relation>

                            </xsl:when>
                            <xsl:when test="contains(lower-case($protocol), 'related')">
                                <xsl:attribute name="type">
                                    <xsl:choose>
                                        <xsl:when test="contains(lower-case($identifierValue), 'extpubs')">
                                            <xsl:text>publication</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>website</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>

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
                                    <xsl:value-of select="$identifierValue"/>
                                </identifier>

                                <relation>
                                    <xsl:attribute name="type">
                                        <xsl:choose>
                                            <xsl:when test="contains(lower-case($identifierValue), 'extpubs')">
                                                <xsl:text>isReferencedBy</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>hasAssociationWith</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                </relation>
                            </xsl:when>
                            <xsl:when test="contains(lower-case($protocol), 'link')">
                                <xsl:attribute name="type">
                                    <xsl:choose>
                                        <xsl:when test="contains(lower-case($identifierValue), 'datatool')">
                                            <xsl:text>service</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(lower-case($identifierValue), 'rss')">
                                            <xsl:text>service</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(lower-case($identifierValue), 'services/kml')">
                                            <xsl:text>service</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(lower-case($identifierValue), '?')">
                                            <xsl:text>service</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>website</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>

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
                                    <xsl:choose>
                                        <xsl:when test="contains($identifierValue, '?')">
                                            <!-- Indicates parameters -->
                                            <xsl:variable name="serviceIdentifier">
                                                <xsl:variable name="baseURL" select="substring-before($identifierValue, '?')"/>
                                                <xsl:choose>
                                                    <xsl:when
                                                        test="substring($baseURL, string-length($baseURL), 1) = '/'">
                                                        <xsl:copy-of
                                                            select="substring($baseURL, 1, string-length($baseURL)-1)"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:copy-of select="$baseURL"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>
                                            <xsl:value-of select="$serviceIdentifier"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$identifierValue"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </identifier>

                                <relation>
                                    <xsl:attribute name="type">
                                        <xsl:choose>
                                            <xsl:when
                                                test="contains(lower-case($identifierValue), 'datatool') or 
                                                        contains(lower-case($identifierValue), 'rss') or 
                                                        contains(lower-case($identifierValue), 'services/kml') or 
                                                        contains(lower-case($identifierValue), '?')">
                                                <xsl:text>supports</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>hasAssociationWith</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:if test="contains(lower-case($identifierValue), '?')">
                                        <description>
                                            <xsl:text>Access via service</xsl:text>
                                        </description>
                                        <url>
                                            <xsl:value-of select="$identifierValue"/>
                                        </url>
                                    </xsl:if> 
                                </relation>
                            </xsl:when>
                        </xsl:choose>
                        
                        <xsl:choose>
                            <!-- Use name as title if we have it... -->
                            <xsl:when test="string-length(normalize-space(*:name)) > 0">
                                <title>
                                    <xsl:value-of select="normalize-space(*:name)"/>
                                </title>
                                <!-- ...and then description as notes -->
                                <xsl:if
                                    test="string-length(normalize-space(*:description)) > 0">
                                    <notes>
                                        <xsl:value-of
                                            select="normalize-space(*:description)"/>
                                    </notes>
                                </xsl:if>
                            </xsl:when>
                            <!-- No name, so use description as title if we have it -->
                            <xsl:otherwise>
                                <xsl:if
                                    test="string-length(normalize-space(*:description)) > 0">
                                    <title>
                                        <xsl:value-of
                                            select="normalize-space(*:description)"/>
                                    </title>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </relatedInfo>
                </xsl:if>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="*:dataQualityInfo/*:DQ_DataQuality/*:lineage/*:LI_Lineage/*:source/*:LI_Source" mode="AIMS_registryObject_relatedInfo">
        <xsl:variable name="relatedType_sequence" as="xs:string*">
            <xsl:call-template name="AIMS_getRelatedInfoTypeRelationship">
                <xsl:with-param name="presentationForm" select="*:sourceCitation/*:CI_Citation/*:presentationForm/*:CI_PresentationFormCode/@codeListValue"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="identifierValue" select="*:sourceCitation/*:CI_Citation/*:identifier/*:MD_Identifier/*:code"/>
        <xsl:variable name="title" select="*:sourceCitation/*:CI_Citation/*:title"/>
        <xsl:if test="count($relatedType_sequence) = 2">
            <relatedInfo type="{$relatedType_sequence[1]}">
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
                    <xsl:value-of select="$identifierValue"/>
                </identifier>
                <relation>
                    <xsl:attribute name="type">
                        <xsl:value-of select="$relatedType_sequence[2]"/>
                    </xsl:attribute>
                </relation>
                <xsl:if test="string-length(normalize-space(@title)) > 0"/>
                <title>
                    <xsl:value-of select="normalize-space(@title)"/>
                </title>
            </relatedInfo>
        </xsl:if>
    </xsl:template>
   
    <!-- RegistryObject - RelatedInfo Element  -->
    <xsl:template match="*:childIdentifier" mode="AIMS_registryObject_relatedInfo">
        <xsl:variable name="identifier" select="normalize-space(.)"/>
        <xsl:if test="string-length($identifier) > 0">
            <relatedInfo type="collection">
                <identifier type="uri">
                    <xsl:value-of
                        select="concat($global_AIMS_sourceURL, $global_AIMS_path, $identifier)"
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
    <xsl:template match="*:MD_CreativeCommons" mode="AIMS_registryObject_rights_licence_creative">
        <xsl:variable name="licenseLink" select="normalize-space(*:licenseLink/*:URL)"/>
        <xsl:for-each
            select="$licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='LicenseCode']/gmx:codeEntry/gmx:CodeDefinition">
            <xsl:if test="string-length(normalize-space(gml:remarks)) > 0">
                <xsl:if test="contains(lower-case($licenseLink), lower-case(gml:remarks))">
                    <rights>
                        <licence>
                            <xsl:attribute name="type" select="gml:identifier"/>
                            <xsl:attribute name="rightsUri" select="$licenseLink"/>
                            <xsl:if test="string-length(normalize-space(gml:name)) > 0">
                                <xsl:value-of select="normalize-space(gml:name)"/>
                            </xsl:if>
                        </licence>
                    </rights>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <!--xsl:for-each select="*:otherConstraints">
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
    <xsl:template match="*:MD_CreativeCommons" mode="AIMS_registryObject_rights_rightsStatement_creative">
        <xsl:for-each select="*:attributionConstraints">
            <!-- If there is text in other constraints, use this; otherwise, do nothing -->
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
    <xsl:template match="*:MD_Commons" mode="AIMS_registryObject_rights_licence_creative">
        <xsl:variable name="licenseLink" select="normalize-space(*:licenseLink/*:URL)"/>
        <xsl:for-each
            select="$licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='LicenseCode']/gmx:codeEntry/gmx:CodeDefinition">
            <xsl:if test="string-length(normalize-space(gml:remarks)) > 0">
                <xsl:if test="contains(lower-case($licenseLink), lower-case(gml:remarks))">
                    <rights>
                        <licence>
                            <xsl:attribute name="type" select="gml:identifier"/>
                            <xsl:attribute name="rightsUri" select="$licenseLink"/>
                            <xsl:if test="string-length(normalize-space(gml:name)) > 0">
                                <xsl:value-of select="normalize-space(gml:name)"/>
                            </xsl:if>
                        </licence>
                    </rights>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
        
        <!--xsl:for-each select="*:otherConstraints">
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
    <xsl:template match="*:MD_Commons" mode="AIMS_registryObject_rights_rightsStatement_creative">
        <xsl:for-each select="*:attributionConstraints">
            <!-- If there is text in other constraints, use this; otherwise, do nothing -->
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
    <xsl:template match="*:MD_Constraints" mode="AIMS_registryObject_rights_rights">
       <xsl:copy-of select="customAIMS:rights(.)"/>
    </xsl:template>
    
    <!-- RegistryObject - RightsStatement -->
    <xsl:template match="*:MD_LegalConstraints" mode="AIMS_registryObject_rights_rights">
       <xsl:copy-of select="customAIMS:rights(.)"/>
    </xsl:template>
    
    
    <xsl:function name="customAIMS:sequence_contains" as="xs:boolean">
        <xsl:param name="sequence" as="xs:string*"/>
        <xsl:param name="substring" as="xs:string"/>
        
        <xsl:variable name="matches_sequence" as="xs:string*">
            <xsl:for-each select="distinct-values($sequence)">
                <xsl:if test="string-length(normalize-space(.)) > 0">
                    <xsl:if test="contains(normalize-space(.), $substring)">
                        <xsl:copy-of select="normalize-space(.)"/>
                     </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
         <xsl:when test="count($matches_sequence) > 0">
             <xsl:copy-of select="true()"/>  
         </xsl:when>
         <xsl:otherwise>
             <xsl:copy-of select="false()"/>
         </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="customAIMS:rights">
        <xsl:param name="currentNode" as="node()"/>
        <xsl:for-each select="$currentNode/*:useLimitation">
            <xsl:variable name="useLimitation" select="normalize-space(.)"/>
            <!-- If there is text in other constraints, use this; otherwise, do nothing -->
            <xsl:if test="string-length($useLimitation) > 0">
                <rights>
                    <rightsStatement>
                        <xsl:value-of select="$useLimitation"/>
                    </rightsStatement>
                </rights>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="$currentNode/*:otherConstraints">
            <xsl:variable name="otherConstraints" select="normalize-space(.)"/>
            <!-- If there is text in other constraints, use this; otherwise, do nothing -->
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
            <!--xsl:if test="contains(lower-case($otherConstraints), 'picccby')">
                <rights>
                    <licence><xsl:text disable-output-escaping="yes">&lt;![CDATA[&lt;a href="http://polarcommons.org/ethics-and-norms-of-data-sharing.php"&gt; &lt;img src="http://polarcommons.org/images/PIC_print_small.png" style="border-width:0; width:40px; height:40px;" alt="Polar Information Commons's PICCCBY license."/&gt;&lt;/a&gt;&lt;a rel="license" href="http://creativecommons.org/licenses/by/3.0/" rel="license"&gt; &lt;img alt="Creative Commons License" style="border-width:0; width: 88px; height: 31px;" src="http://i.creativecommons.org/l/by/3.0/88x31.png" /&gt;&lt;/a&gt;]]&gt;</xsl:text>
                    </licence>
                </rights>
            </xsl:if-->
        </xsl:for-each>
        
    </xsl:function>
    <!-- RegistryObject - CitationInfo Element -->
    <xsl:template name="AIMS_registryObject_citationMetadata_citationInfo">
        <xsl:param name="locationURL_sequence"/>
        <xsl:param name="originatingSourceOrganisation"/>
        <xsl:param name="citation"/>
        <xsl:param name="metadataCreationDate"/>
        
        <xsl:message select="concat('Location url count: ', count($locationURL_sequence))"/>
        
        <xsl:variable name="CI_Citation" select="." as="node()"></xsl:variable>
        <xsl:variable name="citedResponsibleParty_sequence" select="$CI_Citation/*:citedResponsibleParty" as="node()*"></xsl:variable>
        
        <!-- Attempt to obtain contributor names; only construct citation if we have contributor names -->
        
        <xsl:variable name="principalInvestigatorName_sequence" as="xs:string*">
            <xsl:if test="$citedResponsibleParty_sequence and (count($citedResponsibleParty_sequence) > 0)">
                <xsl:for-each select="$citedResponsibleParty_sequence">
                    <xsl:copy-of  select="customAIMS:getOrganisationNameSequence(., 'principalInvestigator')"/>  
                </xsl:for-each>
            </xsl:if>
            
        </xsl:variable>
        
        <xsl:variable name="publisherName_sequence" as="xs:string*">
      
            <xsl:if test="$citedResponsibleParty_sequence and (count($citedResponsibleParty_sequence) > 0)">
                <xsl:for-each select="$citedResponsibleParty_sequence">
                    <xsl:copy-of  select="customAIMS:getOrganisationNameSequence(., 'publisher')"/>  
                </xsl:for-each>
            </xsl:if>
            
       </xsl:variable>
        
        <xsl:variable name="custodianName_sequence" as="xs:string*">
            
            <xsl:if test="$citedResponsibleParty_sequence and (count($citedResponsibleParty_sequence) > 0)">
                <xsl:for-each select="$citedResponsibleParty_sequence">
                    <xsl:copy-of  select="customAIMS:getOrganisationNameSequence(., 'custodian')"/>  
                </xsl:for-each>
            </xsl:if>
            
        </xsl:variable>
        
        <xsl:variable name="resourceProviderName_sequence" as="xs:string*">
            
            <xsl:if test="$citedResponsibleParty_sequence and (count($citedResponsibleParty_sequence) > 0)">
                <xsl:for-each select="$citedResponsibleParty_sequence">
                    <xsl:copy-of  select="customAIMS:getOrganisationNameSequence(., 'resourceProvider')"/> 
                </xsl:for-each>
            </xsl:if>
            
        </xsl:variable>
        
        <xsl:variable name="distributorName_sequence" as="xs:string*">
            
            <xsl:if test="$citedResponsibleParty_sequence and (count($citedResponsibleParty_sequence) > 0)">
                <xsl:for-each select="$citedResponsibleParty_sequence">
                    <xsl:copy-of  select="customAIMS:getOrganisationNameSequence(., 'distributor')"/>  
                </xsl:for-each>
            </xsl:if>
            
        </xsl:variable>
        
        <xsl:variable name="coInvestigatorName_sequence" as="xs:string*">
            <xsl:if test="$citedResponsibleParty_sequence and (count($citedResponsibleParty_sequence) > 0)">
                <xsl:for-each select="$citedResponsibleParty_sequence">
                    <xsl:copy-of  select="customAIMS:getOrganisationNameSequence(., 'coInvestigator')"/>
                </xsl:for-each>
            </xsl:if>
            
        </xsl:variable>
        
       <xsl:variable name="allCitedPartyName_sequence" as="xs:string*">
            <!-- Get organisation names, regardless of role -->
            <xsl:if test="$citedResponsibleParty_sequence and (count($citedResponsibleParty_sequence) > 0)">
                <xsl:for-each select="$citedResponsibleParty_sequence">
                    <xsl:copy-of  select="customAIMS:getOrganisationNameSequence(., null)"/>  
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>
         
        <xsl:variable name="citationContributorName_sequence" as="xs:string*">
            <xsl:for-each select="distinct-values($principalInvestigatorName_sequence)">
                <xsl:if test="string-length(normalize-space(.)) > 0">
                    <xsl:copy-of select="normalize-space(.)"/>
                </xsl:if>
            </xsl:for-each>
            
            <xsl:for-each select="distinct-values($coInvestigatorName_sequence)">
                <xsl:if test="string-length(normalize-space(.)) > 0">
                    <xsl:copy-of select="normalize-space(.)"/>
                </xsl:if>
            </xsl:for-each>
           
            <xsl:for-each select="distinct-values($allCitedPartyName_sequence)">
                <xsl:if test="string-length(normalize-space(.)) > 0">
                    <xsl:copy-of select="normalize-space(.)"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
         <xsl:message select="concat('Count($citationContributorName_sequence): ', count($citationContributorName_sequence))"/>
       
       
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
      
      <xsl:message select="concat('Count($pointOfContactContributorName_sequence): ', count($pointOfContactContributorName_sequence))"/>
       
      
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
        
        <xsl:message select="concat('Count($allContributorName_sequence): ', count($allContributorName_sequence))"/>
      
        <xsl:for-each select="$allContributorName_sequence">
            <xsl:message select="concat('Contributor name: ', .)"/>
        </xsl:for-each>
        
        <!-- We can only accept one DOI; howerver, first we will find all -->
        <xsl:variable name = "doiIdentifier_sequence" as="xs:string*" select="customAIMS:doiFromIdentifiers(*:identifier/*:MD_Identifier/*:code)"/>
        <xsl:variable name="identifierToUse">
            <xsl:choose>
                <xsl:when test="(count($doiIdentifier_sequence) > 0) and (string-length($doiIdentifier_sequence[1]) > 0)">
                    <xsl:value-of select="$doiIdentifier_sequence[1]"/>   
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="count($locationURL_sequence) > 0">
                        <xsl:value-of select="$locationURL_sequence[1]"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="typeToUse">
            <xsl:choose>
                <xsl:when test="(count($doiIdentifier_sequence) > 0) and (string-length($doiIdentifier_sequence[1]) > 0)">
                    <xsl:text>doi</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>uri</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:message select="concat('citation identifier to use: ', $identifierToUse)"/>
        
        
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
                        <xsl:value-of select="*:title"/>
                    </title>
                    
                    <xsl:variable name="current_CI_Citation" select="."/>
                    <xsl:variable name="CI_Date_sequence" as="node()*">
                        <xsl:variable name="type_sequence" as="xs:string*" select="'publication,creation,revision'"/>
                        <xsl:for-each select="tokenize($type_sequence, ',')">
                            <xsl:variable name="type" select="."/>
                            <xsl:for-each select="$current_CI_Citation/*:date/*:CI_Date">
                                <xsl:variable name="code" select="normalize-space(*:dateType/*:CI_DateTypeCode/@codeListValue)"/>
                                    <xsl:if test="contains(lower-case($code), lower-case($type))">
                                    <xsl:copy-of select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:variable>
                    
                    <xsl:message select="concat('CI_Date_sequence count:', count($CI_Date_sequence))"></xsl:message>
                    
                    <xsl:variable name="codelist" select="$gmdCodelists/codelists/codelist[@name = 'gmd:CI_DateTypeCode']"/>
                    <xsl:message select="concat('codelist count:', count($codelist))"></xsl:message>
                    
                    <xsl:variable name="dateType">
                        <xsl:if test="count($CI_Date_sequence) > 0">
                            <xsl:variable name="codevalue" select="$CI_Date_sequence[1]/*:dateType/*:CI_DateTypeCode/@codeListValue"/>
                            <xsl:message select="concat('codevalue', $codevalue)"></xsl:message>
                            <xsl:value-of select="$codelist/entry[code = $codevalue]/description"/>
                            <xsl:message select="concat('$codelist/entry[code = $codevalue]/description', $codelist/entry[code = $codevalue]/description)"></xsl:message>
                        </xsl:if>
                    </xsl:variable>
                    
                    <xsl:message select="concat('dateType', $dateType)"></xsl:message>
                    
                    <xsl:variable name="dateValue">
                        <xsl:if test="count($CI_Date_sequence)">
                            <xsl:if test="string-length($CI_Date_sequence[1]/*:date/gco:Date) > 3">
                                <xsl:value-of select="substring($CI_Date_sequence[1]/*:date/gco:Date, 1, 4)"/>
                            </xsl:if>
                            <xsl:if test="string-length($CI_Date_sequence[1]/*:date/gco:DateTime) > 3">
                                <xsl:value-of select="substring($CI_Date_sequence[1]/*:date/gco:DateTime, 1, 4)"/>
                            </xsl:if>
                        </xsl:if>
                    </xsl:variable>
                    
                    <xsl:message select="concat('dateValue', $dateValue)"></xsl:message>
                    
                    <xsl:choose>
                        <xsl:when test="(string-length($dateType) > 0) and (string-length($dateValue) > 0)">
                            <date>
                                <xsl:attribute name="type">
                                    <xsl:value-of select="$dateType"/>
                                </xsl:attribute>
                                <xsl:value-of select="$dateValue"/>
                            </date>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="string-length($metadataCreationDate) > 3">
                                <date>
                                    <xsl:attribute name="type">
                                        <xsl:text>publicationDate</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="substring($metadataCreationDate, 1, 4)"/>
                                </date>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    <xsl:variable name="publisherToUse">
                        <xsl:choose>
                            <xsl:when test="count($publisherName_sequence) > 0">
                                <xsl:message select="concat('Found party with publish role: ', $publisherName_sequence[1])"/> 
                                <xsl:copy-of select="$publisherName_sequence[1]"/>
                            </xsl:when>
                            <xsl:when test="string-length($originatingSourceOrganisation) > 0">
                                <xsl:message select="concat('No party with publish role found, using originating source organisation: ', $originatingSourceOrganisation)"/> 
                                <xsl:value-of select="$originatingSourceOrganisation"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message select="concat('Resorting to group for publisher: ', substring-after($global_AIMS_group, ':'))"/> 
                                <xsl:value-of select="substring-after($global_AIMS_group, ':')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <!-- If there is more than one contributor, and publisher 
                        name is within contributor list, remove it -->
                    
                    <xsl:for-each select="distinct-values($allContributorName_sequence)">
                        <contributor>
                            <namePart>
                                <xsl:value-of select="."/>
                            </namePart>
                        </contributor>
                    </xsl:for-each>
                    
                    <xsl:if test="string-length($publisherToUse) > 0">
                        <publisher>
                            <xsl:copy-of select="$publisherToUse"/>
                        </publisher>
                    </xsl:if>
                    
               </citationMetadata>
            </citationInfo>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="srv:operatesOn" mode="AIMS_registryObject_relatedInfo">
        
        <xsl:variable name="abstract" select="normalize-space(*:MD_DataIdentification/*:abstract)"/>
        
        <xsl:variable name="uri">
            <xsl:if test="string-length($abstract) > 0">
                <xsl:copy-of select='substring-before(substring-after($abstract, "href="""), "&amp;")'/>
            </xsl:if>
        </xsl:variable>
        
        <xsl:variable name="uuid">
            <xsl:choose>
                <xsl:when test="string-length(normalize-space(@uuidref)) > 0">
                    <xsl:value-of select="normalize-space(@uuidref)"/>
                </xsl:when>
                <xsl:when test="(string-length($abstract) > 0) and contains($abstract, 'uuid')">
                    <xsl:value-of select='substring-before(substring-after($abstract, "uuid="), "&amp;")'/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable> 
        
        <xsl:if test="((string-length($uri) > 0) and contains($uri, 'http')) or (string-length($uuid) > 0)">
            <relatedInfo type="activity">
                <xsl:if test="((string-length($uri) > 0) and contains($uri, 'http'))">
                    <identifier type="uri">
                        <xsl:value-of select="$uri"/>
                    </identifier>
                </xsl:if>
                
                <xsl:if test="(string-length($uuid) > 0)">
                    <!--identifier type="global">
                        <xsl:value-of select="concat($global_AIMS_groupAcronym,'/', $uuid)"/>
                        </identifier-->
                    
                    <xsl:variable name="constructedUri" select="concat($global_AIMS_sourceURL, $global_AIMS_path, $uuid)"/>
                    
                    <xsl:if test="$constructedUri != $uri">
                        <identifier type="uri">
                            <xsl:value-of select="$constructedUri"/>
                        </identifier>
                    </xsl:if>
                    
                </xsl:if>
                
                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>supports</xsl:text>
                    </xsl:attribute>
                </relation>
                
                <xsl:variable name="title" select="normalize-space(*:MD_DataIdentification/*:citation/*:title)"/>
                <xsl:if test="string-length($title)"/>
                <title>
                    <xsl:value-of select="$title"/>
                </title>
            </relatedInfo>
        </xsl:if>
    </xsl:template>



    <!-- ====================================== -->
    <!-- Party RegistryObject - Child Templates -->
    <!-- ====================================== -->

    <!-- Party Registry Object (Individuals (person) and Organisations (group)) -->
    <xsl:template name="AIMS_party">
        <xsl:param name="type"/>
        <xsl:param name="originatingSourceURL"/>
        <xsl:param name="groupToUse"/>
        <xsl:choose>
            <xsl:when test="boolean(customAIMS:createObject(translate(normalize-space(current-grouping-key()),' ','')))">
        
                <registryObject>
                    <xsl:attribute name="group" select="substring-after($groupToUse, ':')"/>
     
                 <key>
                     <xsl:value-of select="concat(substring-before($groupToUse, ':'), '/', translate(normalize-space(current-grouping-key()),' ',''))"/>
                 </key>
                 
                    <originatingSource>
                     <xsl:value-of select="$originatingSourceURL"/>
                 </originatingSource>
     
                 <party type="{$type}">
                     
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
     
                     <!-- If we are dealing with an individual...-->
                     <xsl:choose>
                         <xsl:when test="contains(lower-case($type), 'person')">
                             <xsl:choose>
                                 <xsl:when
                                     test="string-length(normalize-space(*:organisationName)) > 0">
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
                                     <xsl:call-template name="AIMS_physicalAddress"/>
                                 </xsl:otherwise>
                             </xsl:choose>
                             
                             <!-- Individual - Phone and email on the individual, regardless of whether there's an organisation name -->
                             <xsl:call-template name="AIMS_onlineResource"/>
                             <xsl:call-template name="AIMS_telephone"/>
                             <xsl:call-template name="AIMS_facsimile"/>
                             <xsl:call-template name="AIMS_email"/>
                             
                         </xsl:when>
                         <xsl:otherwise>
                             <!-- If we are dealing with an Organisation with no individual name, phone and email must pertain to this organisation -->
                             <xsl:variable name="individualName" select="normalize-space(*:individualName)"/>
                             <xsl:if test="string-length($individualName) = 0">
                                 <xsl:call-template name="AIMS_onlineResource"/>
                                 <xsl:call-template name="AIMS_telephone"/>
                                 <xsl:call-template name="AIMS_facsimile"/>
                                 <xsl:call-template name="AIMS_email"/>
                             </xsl:if>
                             
                             <!-- We are dealing with an organisation, so always include the address -->
                             <xsl:call-template name="AIMS_physicalAddress"/>
                             
                         </xsl:otherwise>
                     </xsl:choose>
                 </party>
             </registryObject>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    
    
    <xsl:template name="AIMS_physicalAddress">
        <xsl:for-each select="current-group()">
            <xsl:sort
                select="count(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/child::*)"
                data-type="number" order="descending"/>

            <xsl:if test="position() = 1">
                <xsl:if
                    test="count(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/child::*)">

                    <location>
                        <address>
                            <physical type="streetAddress">
                                <addressPart type="addressLine">
                                         <xsl:value-of select="normalize-space(current-grouping-key())"/>
                                </addressPart>
                                
                                <xsl:for-each select="*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:deliveryPoint[string-length(gco:CharacterString) > 0]">
                                     <addressPart type="addressLine">
                                         <xsl:value-of select="normalize-space(.)"/>
                                     </addressPart>
                                </xsl:for-each>
                                
                                 <xsl:if test="string-length(normalize-space(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:city)) > 0">
                                      <addressPart type="suburbOrPlaceLocality">
                                          <xsl:value-of select="normalize-space(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:city)"/>
                                      </addressPart>
                                 </xsl:if>
                                
                                 <xsl:if test="string-length(normalize-space(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:administrativeArea)) > 0">
                                     <addressPart type="stateOrTerritory">
                                         <xsl:value-of select="normalize-space(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:administrativeArea)"/>
                                     </addressPart>
                                 </xsl:if>
                                     
                                 <xsl:if test="string-length(normalize-space(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:postalCode)) > 0">
                                     <addressPart type="postCode">
                                         <xsl:value-of select="normalize-space(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:postalCode)"/>
                                     </addressPart>
                                 </xsl:if>
                                 
                                 <xsl:if test="string-length(normalize-space(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:country)) > 0">
                                     <addressPart type="country">
                                         <xsl:value-of select="normalize-space(*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:country)"/>
                                     </addressPart>
                                 </xsl:if>
                            </physical>
                        </address>
                    </location>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="AIMS_telephone">
        <xsl:variable name="phone_sequence" as="xs:string*">
            <xsl:for-each select="current-group()">
                <xsl:for-each select="*:contactInfo/*:CI_Contact/*:phone/*:CI_Telephone/*:voice">
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
    
    <xsl:template name="AIMS_facsimile">
        <xsl:variable name="facsimile_sequence" as="xs:string*">
            <xsl:for-each select="current-group()">
                <xsl:for-each select="*:contactInfo/*:CI_Contact/*:phone/*:CI_Telephone/*:facsimile">
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
    
    <xsl:template name="AIMS_email">
        <xsl:variable name="email_sequence" as="xs:string*">
            <xsl:for-each select="current-group()">
                <xsl:for-each select="*:contactInfo/*:CI_Contact/*:address/*:CI_Address/*:electronicMailAddress">
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
    
    <xsl:template name="AIMS_onlineResource">
        <xsl:variable name="url_sequence" as="xs:string*">
            <xsl:for-each select="current-group()">
                <xsl:for-each select="*:contactInfo/*:CI_Contact/*:onlineResource/*:CI_OnlineResource/*:linkage/*:URL">
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
    
    <xsl:function name="customAIMS:getRegistryObjectTypeSubType_AIMS" as="xs:string*">
        <xsl:param name="scopeCode"/>
        <xsl:choose>
            <xsl:when test="string-length($scopeCode) = 0">
                <!--xsl:message>Error: empty scope code</xsl:message-->
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'publication')">
                <xsl:text>collection</xsl:text>
                <xsl:text>publication</xsl:text>
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'software')">
                <xsl:text>service</xsl:text>
                <xsl:text>software</xsl:text>
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'model')">
                <xsl:text>service</xsl:text>
                <xsl:text>software</xsl:text>
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'service')">
                <xsl:text>service</xsl:text>
                <xsl:text>software</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>collection</xsl:text>
                <xsl:text>dataset</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--xsl:function name="customAIMS:getRegistryObjectTypeSubType_AIMS" as="xs:string*">
        <xsl:param name="scopeCode"/>
        <xsl:choose>
            <xsl:when test="string-length($scopeCode) = 0">
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'dataset')">
                <xsl:text>activity</xsl:text>
                <xsl:text>project</xsl:text>
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'nonGeographicDataset')">
                <xsl:text>activity</xsl:text>
                <xsl:text>project</xsl:text>
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'collectionHardware')">
                <xsl:text>activity</xsl:text>
                <xsl:text>project</xsl:text>
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'sensor')">
                <xsl:text>collection</xsl:text>
                <xsl:text>dataset</xsl:text>
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'sensorSeries')">
                <xsl:text>collection</xsl:text>
                <xsl:text>collection</xsl:text>
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'software')">
                <xsl:text>service</xsl:text>
                <xsl:text>create</xsl:text>
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'model')">
                <xsl:text>service</xsl:text>
                <xsl:text>generate</xsl:text>
            </xsl:when>
            <xsl:when test="contains($scopeCode, 'service')">
                <xsl:text>service</xsl:text>
                <xsl:text>report</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>collection</xsl:text>
                <xsl:text>dataset</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function-->
    
    <xsl:template name="AIMS_getRelatedInfoTypeRelationship" as="xs:string*">
        <xsl:param name="presentationForm"/>
        <xsl:choose>
           <xsl:when test="contains(lower-case($presentationForm), 'modeldigital')">
                <xsl:text>service</xsl:text>
                <xsl:text>produces</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>reuseInformation</xsl:text>
                <xsl:text>supplements</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    

    <xsl:function name="customAIMS:isRole" as="xs:boolean">
        <xsl:param name="parent"/>
        <xsl:param name="role"/>
        <xsl:variable name="roleFound_sequence" as="xs:string*">
            <xsl:for-each-group select="$parent/*:role"
                    group-by="*:CI_RoleCode/@codeListValue">
                    <xsl:if test="(string-length($role) > 0) and contains(lower-case(current-grouping-key()), lower-case($role))">
                        <xsl:value-of select="current-grouping-key()"/>
                    </xsl:if>
            </xsl:for-each-group>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count($roleFound_sequence) > 0">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- Finds name of organisation with particular role - ignores organisations that have an individual name -->
    <xsl:function name="customAIMS:getOrganisationNameSequence" as="xs:string*">
        <xsl:param name="parent" as="node()"/>
        <xsl:param name="role_sequence" as="xs:string*"/>  <!-- if role_sequence is empty: return every, regardless of role -->
        
        <xsl:choose>
            <xsl:when test="count($role_sequence) > 0">
               <xsl:for-each select="tokenize($role_sequence, ',')">
                    <xsl:variable name="role" select="normalize-space(.)"/>
                   
                    <xsl:for-each-group
                        select="$parent/descendant::*:CI_ResponsibleParty[
                        (string-length(normalize-space(*:organisationName)) > 0)]"
                        group-by="*:organisationName">
                        
                        <xsl:variable name="organisationName" select="normalize-space(current-grouping-key())"/>
                        
                        <xsl:choose>
                            <xsl:when test="string-length($role) > 0">
                                <xsl:if test="boolean(customAIMS:isRole(current-group(), $role))">
                                    <xsl:if test="string-length($organisationName) > 0">
                                        <xsl:value-of select="$organisationName"/>
                                    </xsl:if>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- No role specified, so return the name -->
                                <xsl:if test="string-length($organisationName) > 0">
                                    <xsl:value-of select="$organisationName"/>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </xsl:for-each>     
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each-group
                    select="$parent/*:CI_ResponsibleParty"
                    group-by="*:organisationName">
                    
                    <xsl:if test="string-length(normalize-space(current-grouping-key())) > 0">
                        <xsl:value-of select="normalize-space(current-grouping-key())"/>
                    </xsl:if>
                </xsl:for-each-group>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Finds name of organisation with particular role - ignores organisations that have an individual name -->
    <xsl:function name="customAIMS:getOrganisationNameNoIndividualSequence" as="xs:string*">
        <xsl:param name="parent" as="node()"/>
        <xsl:param name="role_sequence" as="xs:string*"/>  <!-- if role_sequence is empty: return every, regardless of role -->
        
        <xsl:choose>
            <xsl:when test="count($role_sequence) > 0">
                <xsl:for-each select="tokenize($role_sequence, ',')">
                    <xsl:variable name="role" select="normalize-space(.)"/>
                    
                    <xsl:for-each-group
                        select="$parent/descendant::*:CI_ResponsibleParty[
                        (count(*:individualName) = 0)]"
                        group-by="*:organisationName">
                        
                        <xsl:variable name="organisationName" select="normalize-space(current-grouping-key())"/>
                        
                        <xsl:choose>
                            <xsl:when test="string-length($role) > 0">
                                <xsl:if test="boolean(customAIMS:isRole(current-group(), $role))">
                                    <xsl:if test="string-length($organisationName) > 0">
                                        <xsl:value-of select="$organisationName"/>
                                    </xsl:if>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- No role specified, so return the name -->
                                <xsl:if test="string-length($organisationName) > 0">
                                    <xsl:value-of select="$organisationName"/>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </xsl:for-each>     
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each-group
                    select="$parent/descendant::*:CI_ResponsibleParty[
                    (string-length(normalize-space(*:organisationName)) > 0) and
                    (string-length(normalize-space(*:individualName)) = 0)]"
                    group-by="*:organisationName">
                    
                    <xsl:if test="string-length(normalize-space(current-grouping-key())) > 0">
                        <xsl:value-of select="normalize-space(current-grouping-key())"/>
                    </xsl:if>
                </xsl:for-each-group>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <xsl:function name="customAIMS:getIndividualNameSequence" as="xs:string*">
        <xsl:param name="parent" as="node()"/>
        <xsl:param name="role_sequence" as="xs:string*"/>  <!-- if role_sequence is empty: return every, regardless of role -->
       
        <xsl:choose>
            <xsl:when test="count($role_sequence)">
                <xsl:for-each select="tokenize($role_sequence, ',')">
                    <xsl:variable name="role" select="normalize-space(.)"/>
                    
                    <xsl:for-each-group
                        select="$parent/*:CI_ResponsibleParty[
                        (string-length(normalize-space(*:individualName)) &gt; 0)]"
                        group-by="*:individualName">
                        
                        <xsl:variable name="individualName" select="normalize-space(current-grouping-key())"/>
                        
                        <xsl:choose>
                            <xsl:when test="string-length($role) > 0">
                                <xsl:if test="boolean(customAIMS:isRole(current-group(), $role))">
                                    <xsl:if test="string-length($individualName) &gt; 0">
                                        <xsl:value-of select="$individualName"/>
                                    </xsl:if>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                 <xsl:if test="string-length($individualName) &gt; 0">
                                     <xsl:value-of select="$individualName"/>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </xsl:for-each>     
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each-group
                    select="$parent/*:CI_ResponsibleParty[
                    (string-length(normalize-space(*:individualName)) &gt; 0)]"
                    group-by="*:individualName">
                    
                    <xsl:if test="string-length(normalize-space(current-grouping-key())) &gt; 0">
                        <xsl:value-of select="normalize-space(current-grouping-key())"/>
                    </xsl:if>
                </xsl:for-each-group>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
   
    <xsl:function name="customAIMS:getProtocolURL_sequence" as="xs:string*">
       <xsl:param name="protocol"/> 
       <xsl:param name="transferOptions"/>
        <xsl:for-each select="$transferOptions/*:onLine/*:CI_OnlineResource">
            <xsl:if test="contains(lower-case(*:protocol), $protocol)">
                <xsl:variable name="url" select="normalize-space(*:linkage/*:URL)"/>
                <xsl:if test="string-length($url) > 0">
                    <xsl:copy-of select="$url"/>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="customAIMS:getDownloadURL_sequence" as="xs:string*">
        <xsl:param name="transferOptions"/>
        <xsl:for-each select="$transferOptions/*:onLine/*:CI_OnlineResource">
            <xsl:if test="
                contains(lower-case(*:protocol), 'downloaddata') or 
                contains(lower-case(*:linkage/*:URL), 'data-download')">
                <xsl:variable name="url" select="normalize-space(*:linkage/*:URL)"/>
                <xsl:if test="string-length($url) > 0">
                    <xsl:copy-of select="$url"/>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>

    <!-- Get the values of the child element of the point of contact responsible parties whose role contains this substring provided 
         For example, if you provide roleSubsting as 'publish' and childElementName as 'organisationName',
            you will receive all organisation names within point of contact.  They will be separated by 'commas', with an 'and' between
            the last and second last, where applicable -->
    <xsl:function name="customAIMS:getChildValueForRole">
        <xsl:param name="contextNode" as="node()"/>
        <xsl:param name="roleSubstring" as="xs:string"/>
        <xsl:param name="childElementName" as="xs:string"/>
        <xsl:variable name="name_sequence" as="xs:string*">
            <xsl:for-each-group
                select="$contextNode/descendant::*:CI_ResponsibleParty[
                (string-length(normalize-space(descendant::node()[local-name()=$childElementName])) > 0)]"
                group-by="$contextNode/descendant::node()[local-name()=$childElementName]">
                <xsl:choose>
                    <!-- obtain for two locations so far - we don't want for example we don't want
                        responsible parties under citation of thesauruses used -->
                    <xsl:when
                        test="contains(local-name(..), 'pointOfContact') or 
                                    contains(local-name(../../..), 'citation')">
                        <xsl:variable name="code" select="normalize-space(*:role/*:CI_RoleCode/@codeListValue)"/>
                            <xsl:if test="contains(lower-case($code), lower-case($roleSubstring))">
                            <xsl:sequence
                                select="descendant::node()[local-name()=$childElementName]"/>
                            </xsl:if>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:variable name="formattedValues">
            <xsl:for-each select="$name_sequence">
                <xsl:if test="position() > 1">
                    <xsl:choose>
                        <xsl:when test="position() = count($name_sequence)">
                            <xsl:text> and </xsl:text>
                        </xsl:when>
                        <xsl:when test="position() &lt; count($name_sequence)">
                            <xsl:text>, </xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$formattedValues"/>
   </xsl:function>

   <xsl:function name="customAIMS:doiFromIdentifiers">
        <xsl:param name="identifier_sequence" as="xs:string*"/>
        <xsl:for-each select="distinct-values($identifier_sequence)">
            <xsl:if test="contains(lower-case(normalize-space(.)), 'doi')">
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:if>
        </xsl:for-each>
   </xsl:function>
    

    <xsl:function name="customAIMS:createObject" as="xs:boolean">
        <xsl:param name="inputKey" as="xs:string"/>
        <!--xsl:message select="concat('customAIMS:createObject(), inputKey: ', lower-case($inputKey))"/-->
        <xsl:choose>
            <xsl:when test="
                (lower-case($inputKey) = 'nationalcomputationalinfrastructure') or
                (lower-case($inputKey) = 'nationalcomputationalinfrastructure(nci)') or
                (lower-case($inputKey) = 'nci')">
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="true()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
        
</xsl:stylesheet>
