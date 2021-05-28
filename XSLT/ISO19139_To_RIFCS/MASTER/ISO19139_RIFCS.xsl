<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:gts="http://www.isotc211.org/2005/gts"
    xmlns:geonet="http://www.fao.org/geonetwork" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:localFunc="http://iso19139.nowhere.yet"
    xmlns:customGMD="http://customGMD.nowhere.yet"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="geonet gmx oai xsi gmd srv gco gts customGMD xs localFunc">
    
    <xsl:import href="CustomFunctionsGMD.xsl"/>
    
    <!-- stylesheet to convert iso19139 in OAI-PMH ListRecords response to RIF-CS -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="global_debug" select="true()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="true()" as="xs:boolean"/>
    <xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/>
    <xsl:variable name="gmdCodelists" select="document('codelists.xml')"/>
    <!--xsl:variable name="anzsrcCodelist" select="document('anzsrc-for-2008.xml')"/-->
    <xsl:param name="global_baseURI" select="'geonetwork.nci.org.au'"/>
    <xsl:param name="global_acronym" select="'NCI'"/>
    <xsl:param name="global_originatingSource" select="'National Computational Infrastructure'"/> <!-- Only used as originating source if organisation name cannot be determined from Point Of Contact -->
    <xsl:param name="global_group" select="'National Computational Infrastructure'"/> 
    <xsl:param name="global_path" select="'/geonetwork/srv/eng/catalog.search#/metadata/'"/>
    
    <xsl:param name="global_regex_URLinstring" select="'(https?:)(//([^#\s]*))?'"/>
    
    <xsl:param name="global_includeDataServiceLinks" select="false()" as="xs:boolean"/>
   
    
    <!-- =========================================== -->
    <!-- RegistryObjects (root) Template             -->
    <!-- =========================================== -->
    
    <xsl:template match="/">
        
        <xsl:message select="'top match'"/>
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="//gmd:MD_Metadata" mode="ISO19139_TO_RIFCS"/>
        </registryObjects>
    </xsl:template>
    
    <xsl:template match="node()"/>

    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject Template          -->
    <!-- =========================================== -->

    <xsl:template match="gmd:MD_Metadata" mode="ISO19139_TO_RIFCS">
        
        <xsl:if test="$global_debug">
            <xsl:message select="concat('licenseCodelist loaded: ', count($licenseCodelist))"/>
            <xsl:message select="concat('Aggregating group: ', $global_group)"/>
        </xsl:if>
        
        <xsl:variable name="originatingSourceOrganisation" select="customGMD:originatingSourceOrganisation(.)"/>
        
        
        
         <xsl:variable name="originatingSourceOrganisation">
            <xsl:choose>
                <xsl:when test="string-length(customGMD:originatingSourceOrganisation(.)) > 0">
                    <xsl:value-of select="customGMD:originatingSourceOrganisation(.)"/>
                    <xsl:if test="$global_debug">
                         <xsl:message select="concat('OriginatingSourceOrganisation: ', customGMD:originatingSourceOrganisation(.))"/>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$global_originatingSource"/>
                </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
        
        <registryObject>
            <xsl:attribute name="group">
                <xsl:value-of select="$global_group"/>    
            </xsl:attribute>
            
            <xsl:apply-templates select="gmd:fileIdentifier" mode="registryObject_key"/>
        
            <originatingSource>
                <xsl:value-of select="$originatingSourceOrganisation"/>
            </originatingSource> 
                
                
            <xsl:element name="{localFunc:registryObjectClass(gmd:hierarchyLevel/*[contains(lower-case(name()),'scopecode')]/@codeListValue)}">
    
                <xsl:attribute name="type" select="localFunc:registryObjectType(gmd:hierarchyLevel/*[contains(lower-case(name()),'scopecode')]/@codeListValue)"/>
                        
                <xsl:if test="localFunc:registryObjectClass(gmd:hierarchyLevel/*[contains(lower-case(name()),'scopecode')]/@codeListValue) = 'collection'">
                        <xsl:if test="
                            (count(gmd:dateStamp/*[contains(lower-case(name()),'date')]) > 0) and 
                            (string-length(gmd:dateStamp/*[contains(lower-case(name()),'date')][1]) > 0)">
                            <xsl:attribute name="dateModified">
                                <xsl:value-of select="gmd:dateStamp/*[contains(lower-case(name()),'date')][1]"/>
                            </xsl:attribute>  
                        </xsl:if>
                            
                </xsl:if>
                       
                <xsl:apply-templates  select="gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:formatDistributor/gmd:MD_Distributor/gmd:distributorTransferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[contains(gmd:name, 'Digital Object Identifier for dataset') and contains(gmd:name, gmd:fileIdentifier)]/gmd:linkage/gmd:URL" mode="registryObject_identifier"/>   
                <xsl:apply-templates select="gmd:dataSetURI[string-length(.) > 0]" mode="registryObject_identifier"/>
                <!--xsl:apply-templates select="gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code"  mode="registryObject_identifier_local"/-->
                <xsl:apply-templates select="gmd:fileIdentifier" mode="registryObject_identifier"/>
                <xsl:apply-templates select="gmd:fileIdentifier" mode="registryObject_location_metadata"/>
                <xsl:apply-templates select="gmd:parentIdentifier" mode="registryObject_related_object"/>
                <xsl:apply-templates select="gmd:children/gmd:childIdentifier" mode="registryObject_related_object"/>
             
                <xsl:apply-templates
                    select="gmd:distributionInfo"/>
                 
                <xsl:apply-templates select="gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:source/gmd:LI_Source[string-length(gmd:sourceCitation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code) > 0]"
                     mode="registryObject_relatedInfo"/>
            
                <xsl:apply-templates select="gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:statement[string-length(.) > 0]"
                    mode="registryObject_description_lineage"/>
                 
                <xsl:apply-templates select="gmd:identificationInfo/*[contains(lower-case(name()),'identification')]" mode="registryObject">
                    <xsl:with-param name="originatingSource" select="$originatingSourceOrganisation"/>
                </xsl:apply-templates>
                
            </xsl:element>
        </registryObject>
                
        <xsl:apply-templates select="gmd:identificationInfo/*[contains(lower-case(name()),'identification')]" mode="relatedRegistryObjects">
            <xsl:with-param name="originatingSource" select="$originatingSourceOrganisation"/>
        </xsl:apply-templates>
                    
            
    </xsl:template>
    
    <xsl:template match="gmd:distributionInfo">
          
        <xsl:apply-templates select="gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[contains(lower-case(gmd:protocol), 'metadata-url')]/gmd:linkage/gmd:URL" mode="registryObject_identifier"/>
        
        <xsl:apply-templates select="gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource" mode="registryObject_relatedInfo"/>
        
     </xsl:template>
    
   <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="registryObject">
        <xsl:param name="originatingSource"/>
        
        <xsl:apply-templates
            select="gmd:citation/gmd:CI_Citation/gmd:title"
            mode="registryObject_name"/>
        
        <xsl:for-each-group
            select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) > 0] |
            ancestor::gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) > 0] |
            gmd:pointOfContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) > 0] |
            ancestor::gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) > 0]"
            group-by="gmd:individualName">
            <xsl:apply-templates select="." mode="registryObject_related_object_individual"/>
        </xsl:for-each-group>
       
       <xsl:for-each-group
           select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:positionName))) > 0] |
           ancestor::gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:positionName))) > 0] |
           gmd:pointOfContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:positionName))) > 0] |
           ancestor::gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:positionName))) > 0]"
           group-by="gmd:positionName">
           <xsl:apply-templates select="." mode="registryObject_related_object_position"/>
       </xsl:for-each-group>
        
        <!-- get a list of all organisation names from responsible parties where there is no corresponding individual name or position name -->
       <xsl:variable name="organisationNamesOnly_sequence" as="xs:string*">
           <xsl:for-each-group
               select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[((string-length(normalize-space(gmd:organisationName))) > 0) and ((string-length(normalize-space(gmd:individualName))) = 0) and ((string-length(normalize-space(gmd:positionName))) = 0)] |
               ancestor::gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[((string-length(normalize-space(gmd:organisationName))) > 0) and ((string-length(normalize-space(gmd:individualName))) = 0) and ((string-length(normalize-space(gmd:positionName))) = 0)] |
               gmd:pointOfContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName)) > 0) and ((string-length(normalize-space(gmd:individualName))) = 0) and ((string-length(normalize-space(gmd:positionName))) = 0)] |
               ancestor::gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName)) > 0) and ((string-length(normalize-space(gmd:individualName))) = 0) and ((string-length(normalize-space(gmd:positionName))) = 0)]"
               group-by="gmd:organisationName">
               <xsl:value-of select="current-grouping-key()"/>
           </xsl:for-each-group>
       </xsl:variable>
       
       <xsl:if test="$global_debug">
        <xsl:message select="concat('count organisationNamesOnly_sequence: ', count($organisationNamesOnly_sequence))"/>
       </xsl:if>
       
       <xsl:for-each-group
           select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[((string-length(normalize-space(gmd:organisationName))) > 0) and (((string-length(normalize-space(gmd:individualName))) > 0) or ((string-length(normalize-space(gmd:positionName))) > 0))] |
           ancestor::gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[((string-length(normalize-space(gmd:organisationName))) > 0) and (((string-length(normalize-space(gmd:individualName))) > 0) or ((string-length(normalize-space(gmd:positionName))) > 0))] |
           gmd:pointOfContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName)) > 0) and (((string-length(normalize-space(gmd:individualName))) > 0) or ((string-length(normalize-space(gmd:positionName))) > 0))] |
           ancestor::gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName)) > 0) and (((string-length(normalize-space(gmd:individualName))) > 0) or ((string-length(normalize-space(gmd:positionName))) > 0))]"
           group-by="gmd:organisationName">
           <xsl:apply-templates select="." mode="registryObject_related_object_organisation_with_individual_or_position_name">
               <xsl:with-param name="organisationNamesOnly_sequence" select="$organisationNamesOnly_sequence"/>
           </xsl:apply-templates>
       </xsl:for-each-group>
       
           
       <xsl:for-each-group
           select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[((string-length(normalize-space(gmd:organisationName))) > 0) and ((string-length(normalize-space(gmd:individualName))) = 0) and ((string-length(normalize-space(gmd:positionName))) = 0)] |
           ancestor::gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[((string-length(normalize-space(gmd:organisationName))) > 0) and ((string-length(normalize-space(gmd:individualName))) = 0) and ((string-length(normalize-space(gmd:positionName))) = 0)] |
           gmd:pointOfContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName)) > 0) and ((string-length(normalize-space(gmd:individualName))) = 0) and ((string-length(normalize-space(gmd:positionName))) = 0)] |
           ancestor::gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName)) > 0) and ((string-length(normalize-space(gmd:individualName))) = 0) and ((string-length(normalize-space(gmd:positionName))) = 0)]"
           group-by="gmd:organisationName">
           <xsl:apply-templates select="." mode="registryObject_related_object_organisation_no_individual_or_position_name"/>
       </xsl:for-each-group>
        
        <xsl:apply-templates
            select="gmd:topicCategory/gmd:MD_TopicCategoryCode"
            mode="registryObject_subject"/>
        
       <xsl:apply-templates
            select="gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword"
            mode="registryObject_subject"/>
       
       <xsl:variable name="landingPage" select="concat('http://', $global_baseURI, $global_path, ancestor::gmd:MD_Metadata/gmd:fileIdentifier)"/>
       
       <xsl:if test="$global_debug">
        <xsl:message select="concat('date: ', ancestor::gmd:MD_Metadata/gmd:dateStamp)"/>
       </xsl:if>
       
       <xsl:apply-templates
           select="."
           mode="registryObject_description_brief">
           <xsl:with-param name="landingPage" select="$landingPage"/>
       </xsl:apply-templates>
        
       <xsl:apply-templates
           select="gmd:abstract[string-length(.) > 0]"
           mode="registryObject_description_full"/>
        
       <xsl:apply-templates select="gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox" mode="registryObject_coverage_spatial"/>
       <xsl:apply-templates select="gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_BoundingPolygon/gmd:polygon" mode="registryObject_coverage_spatial"/>
       
        <xsl:apply-templates
            select="gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent"
            mode="registryObject_coverage_temporal"/>
        
        <xsl:apply-templates
            select="gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent"
            mode="registryObject_coverage_temporal_period"/>
        
      <xsl:apply-templates select="gmd:resourceConstraints/*" mode="registryObject_rights_licence_type_and_uri"/>
       
       <xsl:apply-templates select="." mode="registryObject_rights_access"/>
       
        <xsl:if test="localFunc:registryObjectClass(ancestor::gmd:MD_Metadata/gmd:hierarchyLevel/*[contains(lower-case(name()),'scopecode')]/@codeListValue) = 'collection'">
            
            <xsl:apply-templates
                select="gmd:citation/gmd:CI_Citation/gmd:date"
                mode="registryObject_dates"/>
            
            
            <xsl:apply-templates select="gmd:citation/gmd:CI_Citation"
                mode="registryObject_citationMetadata_citationInfo">
                <xsl:with-param name="originatingSource" select="$originatingSource"></xsl:with-param>
            </xsl:apply-templates>
        </xsl:if>
            
   </xsl:template>
    
    
    
    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject - Related Party Templates -->
    <!-- =========================================== -->
    
    <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="relatedRegistryObjects">
        <xsl:param name="originatingSource"/>
        <xsl:for-each-group
            select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) > 0] |
            ancestor::gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:individualName))) > 0] |
            gmd:pointOfContact/gmd:CI_ResponsibleParty[string-length(normalize-space(gmd:individualName)) > 0] |
            ancestor::gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[string-length(normalize-space(gmd:individualName)) > 0]"
            group-by="gmd:individualName">
            <xsl:call-template name="partyPerson">
                <xsl:with-param name="originatingSource" select="$originatingSource"/>
            </xsl:call-template>
        </xsl:for-each-group>
        
        <xsl:for-each-group
            select="gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName))) > 0] |
            ancestor::gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[(string-length(normalize-space(gmd:organisationName))) > 0] |
            gmd:pointOfContact/gmd:CI_ResponsibleParty[string-length(normalize-space(gmd:organisationName)) > 0] |
            ancestor::gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[string-length(normalize-space(gmd:organisationName)) > 0]"
            group-by="gmd:organisationName">
            <xsl:call-template name="partyGroup">
                <xsl:with-param name="originatingSource" select="$originatingSource"/>
            </xsl:call-template>
        </xsl:for-each-group>
    </xsl:template>
    
    
    

    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject - Child Templates -->
    <!-- =========================================== -->

    <!-- RegistryObject - Key Element  -->
    <xsl:template match="gmd:fileIdentifier" mode="registryObject_key">
        <key>
            <xsl:value-of select="concat($global_acronym, '/', normalize-space(.))"/>
        </key>
    </xsl:template>
    
    <!--xsl:template match="gmd:code" mode="registryObject_identifier_local">
        <identifier type="local">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template-->

    <xsl:template match="gmd:fileIdentifier" mode="registryObject_identifier">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <identifier type="global">
                <xsl:value-of select="."/>
            </identifier>
            <identifier type="uri">
                <xsl:value-of select="concat('http://', $global_baseURI, $global_path, .)"/>
            </identifier>
        </xsl:if>
    </xsl:template>
   
    <!-- RegistryObject - Identifier Element  -->
    
    
    <xsl:template match="gmd:URL" mode="registryObject_identifier">
        <identifier type="{localFunc:getIdentifierType(.)}">
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="gmd:dataSetURI" mode="registryObject_identifier">
        <identifier type="{localFunc:getIdentifierType(.)}">
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>
    </xsl:template>
    

    <!-- RegistryObject - Name Element  -->
    <xsl:template
        match="gmd:citation/gmd:CI_Citation/gmd:title"
        mode="registryObject_name">
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
        mode="registryObject_dates">
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
                <xsl:otherwise>
                    <!-- default to issued because we are drawing from the citation block of the source, and rif-cs won't be accepted without a type-->
                    <xsl:value-of select="'issued'"/>
                </xsl:otherwise>
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
    <xsl:template match="gmd:parentIdentifier" mode="registryObject_related_object">
        <xsl:variable name="identifier" select="normalize-space(.)"/>
        <xsl:if test="string-length($identifier) > 0">
            <relatedObject>
                <key>
                    <xsl:value-of select="concat($global_acronym,'/', $identifier)"/>
                </key>
                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>isPartOf</xsl:text>
                    </xsl:attribute>
                </relation>
            </relatedObject>
        </xsl:if>
    </xsl:template>
    
   <xsl:template match="gmd:fileIdentifier" mode="registryObject_location_metadata">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <location>
                <address>
                    <electronic>
                        <xsl:attribute name="type">
                            <xsl:text>url</xsl:text>
                        </xsl:attribute>
                        <value>
                            <xsl:value-of select="concat('http://', $global_baseURI, $global_path, .)"/>
                        </value>
                    </electronic>
                </address>
            </location>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Related Object (Individual) Element -->
    <xsl:template match="gmd:CI_ResponsibleParty" mode="registryObject_related_object_individual">
          <relatedObject>
            <key>
                <xsl:value-of select="concat($global_acronym,'/', translate(normalize-space(current-grouping-key()),' ',''))"/>
            </key>
            <xsl:choose>
                <xsl:when test="(count(current-group()/gmd:role) > 0)">
                    <xsl:for-each-group select="current-group()/gmd:role"
                        group-by="gmd:CI_RoleCode/@codeListValue">
                        <xsl:variable name="role">
                            <xsl:value-of select="normalize-space(current-grouping-key())"/>
                        </xsl:variable>
                         <xsl:choose>
                            <xsl:when test="(string-length($role) > 0) ">
                                <relation>
                                    <xsl:variable name="codelist"
                                        select="$gmdCodelists/codelists/codelist[contains(@name,'CI_RoleCode')]"/>
                                    
                                    <xsl:variable name="type">
                                        <xsl:value-of select="$codelist/entry[code = $role]/description"/>
                                    </xsl:variable>
                                    
                                    <xsl:attribute name="type">
                                        <xsl:choose>
                                            <xsl:when test="string-length($type) > 0">
                                                <xsl:value-of select="$type"/>
                                            </xsl:when>
                                            <xsl:when test="string-length($role) > 0">
                                                <xsl:value-of select="$role"/>  
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>unknown</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                </relation>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each-group>
                </xsl:when>     
                <xsl:otherwise>
                    <relation>
                        <xsl:attribute name="type">
                            <xsl:text>hasAssociationWith</xsl:text>
                        </xsl:attribute>
                    </relation>
                </xsl:otherwise>
            </xsl:choose>
        </relatedObject>
    </xsl:template>
    
    <!-- RegistryObject - Related Object (Individual) Element -->
    <xsl:template match="gmd:CI_ResponsibleParty" mode="registryObject_related_object_position">
        <relatedObject>
            <key>
                <xsl:value-of select="concat($global_acronym,'/', translate(normalize-space(current-grouping-key()),' ',''))"/>
            </key>
            <xsl:choose>
                <xsl:when test="(count(current-group()/gmd:role) > 0)">
                    <xsl:for-each-group select="current-group()/gmd:role"
                        group-by="gmd:CI_RoleCode/@codeListValue">
                        <xsl:variable name="role">
                            <xsl:value-of select="normalize-space(current-grouping-key())"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="(string-length($role) > 0) ">
                                <relation>
                                    <xsl:variable name="codelist"
                                        select="$gmdCodelists/codelists/codelist[contains(@name,'CI_RoleCode')]"/>
                                    
                                    <xsl:variable name="type">
                                        <xsl:value-of select="$codelist/entry[code = $role]/description"/>
                                    </xsl:variable>
                                    
                                    <xsl:attribute name="type">
                                        <xsl:choose>
                                            <xsl:when test="string-length($type) > 0">
                                                <xsl:value-of select="$type"/>
                                            </xsl:when>
                                            <xsl:when test="string-length($role) > 0">
                                                <xsl:value-of select="$role"/>  
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>unknown</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                </relation>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each-group>
                </xsl:when>     
                <xsl:otherwise>
                    <relation>
                        <xsl:attribute name="type">
                            <xsl:text>hasAssociationWith</xsl:text>
                        </xsl:attribute>
                    </relation>
                </xsl:otherwise>
            </xsl:choose>
        </relatedObject>
    </xsl:template>
    
    
    <!-- RegistryObject - Related Object (Organisation or Individual) Element -->
    <!-- if the name is in the sequence param, that means that the org has already been associated with a source role
        so you don't have to add it as 'associated' because it hasn't missed out and best if just the sourced roles are used in this case -->
    <xsl:template match="gmd:CI_ResponsibleParty" mode="registryObject_related_object_organisation_with_individual_or_position_name">
        <xsl:param name="organisationNamesOnly_sequence" as="xs:string*"/>
        
       <xsl:if test="count($organisationNamesOnly_sequence[. = current-grouping-key()]) = 0">
            <relatedObject>
                <key>
                    <xsl:value-of select="concat($global_acronym,'/', translate(normalize-space(current-grouping-key()),' ',''))"/>
                </key>
                
                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>hasAssociationWith</xsl:text>
                    </xsl:attribute>
                </relation>
                
            </relatedObject>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="gmd:CI_ResponsibleParty" mode="registryObject_related_object_organisation_no_individual_or_position_name">
        <relatedObject>
            <key>
                <xsl:value-of select="concat($global_acronym,'/', translate(normalize-space(current-grouping-key()),' ',''))"/>
            </key>
            
            <xsl:if test="$global_debug">
                <xsl:message select="concat('count current-group() gmd:role: ', count(current-group()/gmd:role))"/>
            </xsl:if>
            
            <xsl:choose>
                <!-- Dealing with an organisation without an individual name, so add role code -->
                <xsl:when test="(count(current-group()/gmd:role) > 0)">
                    <xsl:for-each-group select="current-group()/gmd:role"
                        group-by="gmd:CI_RoleCode/@codeListValue">
                        <xsl:variable name="role">
                            <xsl:value-of select="normalize-space(current-grouping-key())"/>
                        </xsl:variable>
                        <xsl:if test="$global_debug">
                            <xsl:message select="concat('role : ', $role)"/>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="(string-length($role) > 0) ">
                                <relation>
                                    <xsl:variable name="codelist"
                                        select="$gmdCodelists/codelists/codelist[contains(@name,'CI_RoleCode')]"/>
                                    
                                    <xsl:variable name="type">
                                        <xsl:value-of select="$codelist/entry[code = $role]/description"/>
                                    </xsl:variable>
                                    
                                    <xsl:attribute name="type">
                                        <xsl:choose>
                                            <xsl:when test="string-length($type) > 0">
                                                <xsl:value-of select="$type"/>
                                            </xsl:when>
                                            <xsl:when test="string-length($role) > 0">
                                                <xsl:value-of select="$role"/>  
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>unknown</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                </relation>
                            </xsl:when>
                            <xsl:otherwise>
                                <relation>
                                    <xsl:attribute name="type">
                                        <xsl:text>hasAssociationWith</xsl:text>
                                    </xsl:attribute>
                                </relation>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </xsl:when>     
                <xsl:otherwise>
                    <relation>
                        <xsl:attribute name="type">
                            <xsl:text>hasAssociationWith</xsl:text>
                        </xsl:attribute>
                    </relation>
                </xsl:otherwise>
            </xsl:choose>
        </relatedObject>
    </xsl:template>

    <!-- RegistryObject - Related Object Element  -->
    <xsl:template match="gmd:childIdentifier" mode="registryObject_related_object">
        <xsl:variable name="identifier" select="normalize-space(.)"/>
        <xsl:if test="string-length($identifier) > 0">
            <relatedObject>
                <key>
                    <xsl:value-of select="concat($global_acronym,'/', $identifier)"/>
                </key>
                <relation>
                    <xsl:attribute name="type">
                        <xsl:text>hasPart</xsl:text>
                    </xsl:attribute>
                </relation>
            </relatedObject>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gmd:keyword" mode="registryObject_subject">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <subject type="local">
                <xsl:value-of select="."/>
            </subject>
           
           <!--xsl:variable name="keyword" select="normalize-space(.)"/>
            <xsl:variable name="code"
                select="$anzsrcCodelist/rdf:RDF/rdf:Description[lower-case(skos:prefLabel) = lower-case($keyword)]/skos:notation"/>
           <xsl:if test="string-length($code) > 0">
               <subject type="anzsrc-for">
                   <xsl:value-of select="$code"/>
               </subject>
           </xsl:if-->
        </xsl:if>
      </xsl:template>
    
   <xsl:template match="gmd:MD_TopicCategoryCode" mode="registryObject_subject">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <subject type="local">
                <xsl:value-of select="."></xsl:value-of>
            </subject>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Description Element -->
    <xsl:template match="gmd:abstract" mode="registryObject_description_full">
        <description type="full">
            <xsl:value-of select="."/>
            
            <xsl:apply-templates select="ancestor::gmd:MD_Metadata/gmd:metadataConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints[contains(lower-case(.), 'metadata constraints')]"
                mode="registryObject_description_full_add_metadataConstraints"/>
            
            <xsl:apply-templates select="..[count(gmd:purpose) > 0]"
                mode="registryObject_description_full_add_purpose"/>
            
            <xsl:apply-templates select="..[count(gmd:credit) > 0]"
                mode="registryObject_description_full_add_credit"/>
        </description>
    </xsl:template>
    
    <xsl:template match="*" mode="registryObject_description_brief">
        <xsl:param name="landingPage"/>
        <description type="brief">
            <xsl:value-of select="concat('This record was harvested by RDA at ',  current-dateTime(), ' from &lt;a href=''', $landingPage ,'''&gt;', $landingPage, '&lt;/a&gt; in ', $global_acronym, '''s Data Catalogue')"/>
            <xsl:if test="count(ancestor::gmd:MD_Metadata/gmd:dateStamp/*[contains(local-name(), 'Date')][string-length(.)> 0]) > 0">
                <xsl:value-of select="concat(' where it was last modified at ', ancestor::gmd:MD_Metadata/gmd:dateStamp/*[contains(local-name(), 'Date')][string-length(.)> 0][1] , '')"/>
            </xsl:if>
            <xsl:text>.</xsl:text>
        </description>
    </xsl:template>
    
    <!-- RegistryObject - Description Element -->
    <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="registryObject_description_full_add_purpose">
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&lt;h4&gt;Purpose&lt;/h4&gt;</xsl:text>    
        <xsl:for-each select="gmd:purpose[string-length(.) > 0]">
            <xsl:if test="position() > 1">
                <xsl:text>; </xsl:text>
            </xsl:if>    
            <xsl:value-of select="."/>
        </xsl:for-each>
    </xsl:template>
    
    <!-- RegistryObject - Description Element -->
    <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="registryObject_description_full_add_credit">
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&lt;h4&gt;Credit&lt;/h4&gt;</xsl:text>    
        <xsl:for-each select="gmd:credit[string-length(.) > 0]">
            <xsl:if test="position() > 1">
                <xsl:text>; </xsl:text>
            </xsl:if>    
            <xsl:value-of select="."/>
        </xsl:for-each>
    </xsl:template>
    
    <!-- RegistryObject - Description Element -->
    <xsl:template match="gmd:statement" mode="registryObject_description_lineage">
        <description type="lineage">
            <xsl:value-of select="."/>
        </description>
    </xsl:template>
    
    <xsl:template match="gmd:otherConstraints" mode="registryObject_description_full_add_metadataConstraints">
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&lt;h4&gt;Metadata Constraints&lt;/h4&gt;</xsl:text>    
        <xsl:choose>
            <xsl:when test="contains(., 'Metadata constraints:')">
                <xsl:value-of select="normalize-space(substring-after(., 'Metadata constraints:'))"/>
            </xsl:when>
            <xsl:when test="contains(., 'Metadata Constraints:')">
                <xsl:value-of select="normalize-space(substring-after(., 'Metadata Constraints:'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- RegistryObject - Coverage Spatial Element -->
    <xsl:template match="gmd:EX_GeographicBoundingBox" mode="registryObject_coverage_spatial">
        
        <xsl:variable name="crsCode" select="ancestor::gmd:MD_Metadata/gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code[contains(lower-case(following-sibling::gmd:codeSpace), 'crs')]"/>
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
    <xsl:template match="gmd:polygon" mode="registryObject_coverage_spatial">
        <xsl:if
            test="string-length(normalize-space(*:Polygon/*:exterior/*:LinearRing/*:coordinates)) > 0">
            <coverage>
                <spatial>
                    <xsl:attribute name="type">
                        <xsl:text>gmlKmlPolyCoords</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of
                        select="replace(normalize-space(*:Polygon/*:exterior/*:LinearRing/*:coordinates), ',0', '')"
                    />
                </spatial>
            </coverage>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Coverage Temporal Element -->
    <xsl:template match="gmd:EX_TemporalExtent" mode="registryObject_coverage_temporal">
        <xsl:if
            test="(string-length(normalize-space(gmd:extent/*:TimePeriod/*:begin/*:TimeInstant/*:timePosition)) > 0) or
                  (string-length(normalize-space(gmd:extent/*:TimePeriod/*:end/*:TimeInstant/*:timePosition)) > 0)">
            <coverage>
                <temporal>
                    <xsl:if
                        test="string-length(normalize-space(gmd:extent/*:TimePeriod/*:begin/*:TimeInstant/*:timePosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateFrom</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gmd:extent/*:TimePeriod/*:begin/*:TimeInstant/*:timePosition)"
                            />
                        </date>
                    </xsl:if>
                    <xsl:if
                        test="string-length(normalize-space(gmd:extent/*:TimePeriod/*:end/*:TimeInstant/*:timePosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateTo</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gmd:extent/*:TimePeriod/*:end/*:TimeInstant/*:timePosition)"
                            />
                        </date>
                    </xsl:if>
                </temporal>
            </coverage>
        </xsl:if>
    </xsl:template>

    <!-- RegistryObject - Coverage Temporal Element -->
    <xsl:template match="gmd:EX_TemporalExtent" mode="registryObject_coverage_temporal_period">
        <xsl:if
            test="(string-length(normalize-space(gmd:extent/*:TimePeriod/*:beginPosition)) > 0) or
                  (string-length(normalize-space(gmd:extent/*:TimePeriod/*:endPosition)) > 0)">
            <coverage>
                <temporal>
                    <xsl:if
                        test="string-length(normalize-space(gmd:extent/*:TimePeriod/*:beginPosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateFrom</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gmd:extent/*:TimePeriod/*:beginPosition)"
                            />
                        </date>
                    </xsl:if>
                    <xsl:if
                        test="string-length(normalize-space(gmd:extent/*:TimePeriod/*:endPosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateTo</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gmd:extent/*:TimePeriod/*:endPosition)"
                            />
                        </date>
                    </xsl:if>
                </temporal>
            </coverage>
        </xsl:if>
    </xsl:template>


   <!-- RegistryObject - RelatedInfo Element  -->
    
    <!-- RegistryObject - RelatedInfo Element  -->
    <xsl:template match="gmd:CI_OnlineResource" mode="registryObject_relatedInfo">         
        
        <xsl:choose>
            <xsl:when test="($global_includeDataServiceLinks = true()) and (contains(gmd:protocol, 'OGC:') or contains(lower-case(gmd:linkage/gmd:URL), 'thredds') or contains(lower-case(gmd:linkage/gmd:URL), 'ftp'))">
                <xsl:apply-templates select="." mode="relatedInfo_service"/>
            </xsl:when>
            <xsl:when test="not(contains(lower-case(gmd:description), 'point of truth url of this metadata record') and not(contains(gmd:protocol, 'OGC:'))) and not(contains(lower-case(gmd:linkage/gmd:URL), 'thredds')) and not(contains(lower-case(gmd:linkage/gmd:URL), 'ftp'))">
                <xsl:apply-templates select=".[string-length(gmd:linkage/gmd:URL) > 0]" mode="relatedInfo_relatedInformation"/>
            </xsl:when>
            
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="gmd:CI_OnlineResource" mode="relatedInfo_service">       
        
        <xsl:variable name="identifierValue" select="normalize-space(gmd:linkage/gmd:URL)"/>
        
        <relatedInfo>
            <xsl:attribute name="type" select="'service'"/>   
            
            <identifier type="{localFunc:getIdentifierType($identifierValue)}">
                <xsl:choose>
                    <xsl:when test="contains($identifierValue, '?')">
                        <xsl:value-of select="substring-before(., '?')"/>
                    </xsl:when>    
                    <!-- URL contains a forward slash and URL ends with a sort of filename (if it contains a dot)  - but doesn't contain 'catalogue.xml' or 'catalogue.*' as in thredds, which we want to keep-->
                    <xsl:when test="contains($identifierValue, '/')">
                        <xsl:variable name="finalValue" select="tokenize($identifierValue, '/')[count(tokenize($identifierValue, '/'))]"/>
                        <xsl:choose>
                         <xsl:when test="contains($finalValue, '.') and (not(contains($finalValue, 'catalog.')))">
                             <xsl:value-of select="substring-before($identifierValue, concat('/', $finalValue))"/>
                         </xsl:when>
                         <xsl:otherwise>
                             <xsl:value-of select="$identifierValue"/>
                         </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$identifierValue"/>
                    </xsl:otherwise>
                </xsl:choose>
            </identifier>
            
            <xsl:message select="concat('out: ', tokenize($identifierValue, '/')[count(tokenize($identifierValue, '/'))])"/>
            <relation>
                <xsl:attribute name="type">
                    <xsl:text>supports</xsl:text>
                </xsl:attribute>
                <xsl:if test="(contains($identifierValue, '?')) or
                                   ((contains($identifierValue, '/') and 
                                        contains(tokenize($identifierValue, '/')[count(tokenize($identifierValue, '/'))], '.') = true()) and
                                        contains(tokenize($identifierValue, '/')[count(tokenize($identifierValue, '/'))], 'catalog.') = false())">
                    
                    <xsl:message select="concat('url: ', tokenize($identifierValue, '/')[count(tokenize($identifierValue, '/'))])"/>
                    <xsl:message select="concat('result: ', contains(tokenize($identifierValue, '/')[count(tokenize($identifierValue, '/'))], 'catalog.') = false())"/>
                    <url>
                        <xsl:value-of select="$identifierValue"/>
                    </url>
                </xsl:if>
            </relation>
            
            <xsl:apply-templates select="." mode="relatedInfo_all"/>
        </relatedInfo>
        
    </xsl:template>
    
    <xsl:template match="gmd:CI_OnlineResource" mode="relatedInfo_relatedInformation">       
        
        <xsl:variable name="identifierValue" select="normalize-space(gmd:linkage/gmd:URL)"/>
        <relatedInfo>
       
            <xsl:attribute name="type">
                <xsl:text>relatedInformation</xsl:text>
            </xsl:attribute> 
            
            <identifier type="{localFunc:getIdentifierType($identifierValue)}">
                <xsl:value-of select="$identifierValue"/>
            </identifier>
            
            <relation type="hasAssociationWith"/>
            
            <xsl:apply-templates select="." mode="relatedInfo_all"/>
        </relatedInfo>
        
    </xsl:template>
    
    
    <xsl:template match="gmd:CI_OnlineResource" mode="relatedInfo_all">     
        
        <xsl:variable name="identifierValue" select="normalize-space(gmd:linkage/gmd:URL)"/>
        
         <xsl:choose>
            <!-- Use description as title if we have it... -->
            <xsl:when test="string-length(normalize-space(gmd:description)) > 0">
                <title>
                    <xsl:value-of select="normalize-space(gmd:description)"/>
                     <!-- ...and then name in brackets following -->
                 
                        <xsl:if test="string-length(normalize-space(gmd:name)) > 0">
                            <xsl:value-of select="concat(' (', gmd:name, ')')"/>
                         </xsl:if>
                </title>
            </xsl:when>
           
            <!-- No description, so use name as title if  we have it -->
            <xsl:otherwise>
                <xsl:if test="string-length(normalize-space(gmd:name)) > 0">
                    <title>
                        <xsl:value-of select="gmd:name"/>
                    </title>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
   
     <!-- RegistryObject - RelatedInfo Element  -->
    <xsl:template match="gmd:childIdentifier" mode="registryObject_relatedInfo">
        <xsl:variable name="identifier" select="normalize-space(.)"/>
        <xsl:if test="string-length($identifier) > 0">
            <relatedInfo type="collection">
                <identifier type="uri">
                    <xsl:value-of
                        select="concat('http://', $global_baseURI, $global_path, $identifier)"/>
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




   <xsl:template match="*[contains(lower-case(name()),'identification')]"  mode="registryObject_rights_access">
       <!-- if there is one or more MD_ClassificationCode of 'unclassified', and all occurences of MD_ClassificationCode are 'unclassified', set accessRights to 'open' -->
            <rights>
                <accessRights>
                    <xsl:choose>
                        <xsl:when test="count(gmd:resourceConstraints/gmd:MD_SecurityConstraints/gmd:classification/gmd:MD_ClassificationCode[@codeListValue = 'unclassified']) > 0 and
                            count(gmd:resourceConstraints/gmd:MD_SecurityConstraints/gmd:classification/gmd:MD_ClassificationCode/@codeListValue) = 
                            count(gmd:resourceConstraints/gmd:MD_SecurityConstraints/gmd:classification/gmd:MD_ClassificationCode[@codeListValue = 'unclassified'])">
                            <xsl:attribute name="type">
                                <xsl:text>open</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <!-- when MD_ClassificationCode is populated, but not as above -->
                        <xsl:when test="count(gmd:resourceConstraints/gmd:MD_SecurityConstraints/gmd:classification/gmd:MD_ClassificationCode/@codeListValue[string-length(.) > 0]) > 0">
                            <xsl:attribute name="type">
                                <xsl:text>restricted</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <!-- all other cases -->
                        <xsl:otherwise>
                            <xsl:attribute name="type">
                                <xsl:text>other</xsl:text>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </accessRights>
            </rights>
  </xsl:template>
  
   <xsl:template match="*" mode="registryObject_rights_licence_type_and_uri">
        <xsl:variable name="topNode" select="." as="node()"/>
       
        <xsl:if test="$global_debug">
            <xsl:message select="concat('Extracting urls from : ', string-join(.//*[contains(name(), 'CharacterString')],  '&#xA;'))"/>
        </xsl:if>
        
        <xsl:variable name="licenseLink_sequence" as="xs:string*">
           <xsl:analyze-string select="string-join(.//*[contains(name(), 'CharacterString')],  '&#xA;')" regex="(https?:)(//([^#\s]*))?(licens?c?)+(([^#\s]*))?">
                <xsl:matching-substring>
                    <matching0>
                        <xsl:value-of select="regex-group(0)"/>
                    </matching0>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:if test="$global_debug">
            <xsl:message select="concat('Count extracted one license link : ', count($licenseLink_sequence))"/>
        </xsl:if>
        
        <xsl:for-each select="distinct-values($licenseLink_sequence)">
            <xsl:variable name="licenseLink" select="."/>
            <xsl:variable name="licenseLinkTransformed">
                <xsl:variable name="normalized" select="normalize-space(replace(replace(., 'icence', 'icense', 'i'), 'https', 'http', 'i'))"/>
                <xsl:choose>
                    <xsl:when test="contains($normalized, 'creativecommons') and contains($normalized, '/legalcode')">
                        <xsl:value-of select="substring-before($normalized, '/legalcode')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$normalized"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
             <rights>
                <licence>
                    <xsl:if test="count($licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[(@*:id='LicenseCodeAustralia') or (@*:id='LicenseCodeInternational')]/gmx:codeEntry/gmx:CodeDefinition[contains(lower-case($licenseLinkTransformed), lower-case(replace(*:remarks, '\{n\}', '')))]/*:identifier) > 0">
                        <xsl:attribute name="type" select="$licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[(@*:id='LicenseCodeAustralia') or (@*:id='LicenseCodeInternational')]/gmx:codeEntry/gmx:CodeDefinition[contains(lower-case($licenseLinkTransformed), lower-case(replace(*:remarks, '\{n\}', '')))]/*:identifier[1]"/>
                        <xsl:attribute name="rightsUri" select="$licenseLink"/>
                        
                        <!-- Find all character strings that contained this link, and add them to licence text if they contain more text than only the link itself (otherwise we double up with rightsUri) -->
                        <xsl:value-of select="string-join($topNode//*[contains(name(), 'CharacterString') and contains(text(), $licenseLink) and (string-length(text()) > string-length($licenseLink))], '&#xA;')"/>
                    </xsl:if>
                </licence>
            </rights>
        </xsl:for-each>
        
        <!-- Add rightsStatement for each character string that did not contain a known license link and therefore was not handled above -->
        <xsl:for-each select="$topNode//*[contains(name(), 'CharacterString')][string-length(.) > 0]">
            
            <xsl:variable name="currentText" select="." as="xs:string"/>
            
            <xsl:variable name="alreadyWritten_booleanSequence" as="xs:boolean*">
                <xsl:for-each select="distinct-values($licenseLink_sequence)">
                    <xsl:variable name="licenseLink" select="."/>
                    <xsl:variable name="licenseLinkTransformed" select="normalize-space(replace(replace(., 'icence', 'icense', 'i'), 'https', 'http', 'i'))"/>
                    <xsl:if test="count($licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[(@*:id='LicenseCodeAustralia') or (@*:id='LicenseCodeInternational')]/gmx:codeEntry/gmx:CodeDefinition[contains(lower-case($licenseLinkTransformed), lower-case(replace(*:remarks, '\{n\}', '')))]/*:identifier) > 0">
                        <xsl:if test="contains($currentText, $licenseLink)">
                            <xsl:value-of select="true()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            
            <xsl:if test="count($alreadyWritten_booleanSequence) = 0">
                <rights>
                    <rightsStatement>
                        <xsl:value-of select="$currentText"/>
                    </rightsStatement>
                </rights>
            </xsl:if>
            
        </xsl:for-each>
        
       
           
    </xsl:template>
    
    
    <!-- RegistryObject - CitationInfo Element -->
    <xsl:template match="gmd:CI_Citation" mode="registryObject_citationMetadata_citationInfo">
        <xsl:param name="originatingSource"/>
         
        <!-- Attempt to obtain contributor names; only construct citation if we have contributor names -->
        
       <xsl:variable name="citedResponsibleParty_sequence" select="gmd:citedResponsibleParty/gmd:CI_ResponsibleParty" as="node()*"/>
        
       <xsl:variable name="principalInvestigator_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'principalInvestigator'] |
            ../../../../gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'principalInvestigator'] |
            ../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'principalInvestigator']"/>
        
        <xsl:variable name="author_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'author'] |
            ../../../../gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'author'] |
            ../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'author']"/>
        
        
        <xsl:variable name="contentexpert_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'contentexpert'] |
            ../../../../gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'contentexpert'] |
            ../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'contentexpert']"/>
        
        <xsl:variable name="coInvestigator_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'coInvestigator'] |
            ../../../../gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'coInvestigator'] |
            ../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'coInvestigator']"/>
        
        <xsl:variable name="publisher_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher'] |
            ../../../../gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher'] |
            ../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher']"/>  
        
        <xsl:variable name="owner_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'owner'] |
            ../../../../gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'owner'] |
            ../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'owner']"/>  
        
        <xsl:variable name="publisher_sequence" as="node()*" select="
            gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher'] |
            ../../../../gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher'] |
            ../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher']"/>
        
        <xsl:variable name="allContributorName_sequence" as="xs:string*">
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
                           <xsl:copy-of select="gmd:organisationName"/>
                       </xsl:if>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:copy-of select="gmd:individualName"/>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:for-each>
           
           <xsl:for-each select="$citedResponsibleParty_sequence">
               <xsl:choose>
                   <xsl:when test="string-length(gmd:individualName) = 0">
                       <xsl:if test="string-length(gmd:organisationName) > 0">
                           <xsl:copy-of select="gmd:organisationName"/>
                       </xsl:if>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:copy-of select="gmd:individualName"/>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:for-each>
       </xsl:variable>
        
        <!-- We can only accept one DOI; howerver, first we will find all -->
        <xsl:variable name = "doiIdentifier_sequence" as="xs:string*">
            <xsl:value-of select=" ../../../../gmd:dataSetURI"/>
            <xsl:value-of select="gmd:identifier/gmd:MD_Identifier/gmd:code[contains(lower-case(.), 'doi')]"/>
        </xsl:variable> 
        <xsl:variable name="identifierToUse">
            <xsl:choose>
                <xsl:when test="count($doiIdentifier_sequence) and (string-length($doiIdentifier_sequence[1]) > 0)">
                    <xsl:value-of select="$doiIdentifier_sequence[1]"/>   
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('http://', $global_baseURI, $global_path, ancestor::gmd:MD_Metadata/gmd:fileIdentifier)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
             
        <xsl:if test="count($allContributorName_sequence) > 0">
           <citationInfo>
                <citationMetadata>
                    <xsl:if test="string-length($identifierToUse) > 0">
                        <identifier type="{localFunc:getIdentifierType($identifierToUse)}">
                            <xsl:value-of select='$identifierToUse'/>
                        </identifier>
                    </xsl:if>
    
                    <title>
                        <xsl:value-of select="gmd:title"/>
                    </title>
                    
                    <xsl:variable name="dateValueAndType_sequence" as="xs:string*">
                        <xsl:choose>
                            <xsl:when test="count(gmd:date/gmd:CI_Date[contains(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue, 'publication')]/gmd:date/gco:Date[string-length(.) > 0]) > 0">
                                <xsl:value-of select="gmd:date/gmd:CI_Date[contains(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue, 'publication')]/gmd:date/gco:Date[string-length(.) > 0]"/> 
                                <xsl:text>publication</xsl:text>
                            </xsl:when>
                            <xsl:when test="count(gmd:date/gmd:CI_Date[contains(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue, 'revision')]/gmd:date/gco:Date[string-length(.) > 0]) > 0">
                                <xsl:value-of select="gmd:date/gmd:CI_Date[contains(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue, 'revision')]/gmd:date/gco:Date[string-length(.) > 0]"/> 
                                <xsl:text>revision</xsl:text>
                            </xsl:when>
                            <xsl:when test="count(gmd:date/gmd:CI_Date[contains(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue, 'creation')]/gmd:date/gco:Date[string-length(.) > 0]) > 0">
                                <xsl:value-of select="gmd:date/gmd:CI_Date[contains(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue, 'creation')]/gmd:date/gco:Date[string-length(.) > 0]"/> 
                                <xsl:text>creation</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:if test="count($dateValueAndType_sequence) > 0">
                        <xsl:variable name="dateValue" select="$dateValueAndType_sequence[1]"/>
                        <xsl:variable name="dateTypeFromSource" select="$dateValueAndType_sequence[2]"/>
                        
                        <xsl:if test="$global_debug">
                            <xsl:message select="concat('Using ', $dateTypeFromSource, ' date : ', $dateValue)"/>
                        </xsl:if>
                        
                        <xsl:variable name="codelist" select="$gmdCodelists/codelists/codelist[@name = 'gmd:CI_DateTypeCode']"/>
                        
                         <date>
                            <xsl:attribute name="type">
                                <xsl:choose>
                                 <xsl:when test="string-length($codelist/entry[code = $dateTypeFromSource]/description) > 0">
                                     <xsl:value-of select="$codelist/entry[code = $dateTypeFromSource]/description"/>
                                 </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>publicationDate</xsl:text>
                                </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="contains($dateValue, '/')">
                                    <xsl:value-of select="tokenize($dateValue, '/')[count(tokenize($dateValue, '/'))]"/>
                                </xsl:when>
                                <xsl:when test="contains($dateValue, '-')">
                                    <xsl:value-of select="tokenize($dateValue, '-')[1]"/>
                                </xsl:when>
                                <xsl:when test="string-length($dateValue) > 3">
                                    <xsl:value-of select="substring($dateValue, 1, 4)"/>
                                 </xsl:when>
                                <xsl:when test="string-length($dateValue) > 0">
                                    <xsl:value-of select="$dateValue"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text><!-- never getting here with current code--></xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </date>
                    </xsl:if>    
                    
                  <!-- If there is more than one contributor, and publisher 
                  name is within contributor list, remove it -->
                    
                    <xsl:variable name="publisherOrganisationName" as="xs:string">
                        <xsl:variable name="publisherOrganisationName_sequence" as="xs:string*">
                            <xsl:for-each select="$publisher_sequence">
                                <xsl:if test="string-length(gmd:organisationName) > 0">
                                    <xsl:copy-of select="gmd:organisationName"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="count($publisherOrganisationName_sequence) > 0">
                                <xsl:value-of select="$publisherOrganisationName_sequence[1]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$originatingSource"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:choose>
                        <xsl:when test="count($allContributorName_sequence) > 0">
                            <xsl:for-each select="distinct-values($allContributorName_sequence)">
                                <xsl:choose>
                                    <xsl:when test="($publisherOrganisationName != .) or ((count($allContributorName_sequence) = 1))">
                                        <contributor seq="{position()}">
                                            <namePart>
                                                <xsl:value-of select="."/>
                                            </namePart>
                                        </contributor>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>
                    
                    <publisher>
                        <xsl:value-of select="$publisherOrganisationName"/>
                    </publisher>
                    
               </citationMetadata>
            </citationInfo>
        </xsl:if>
    </xsl:template>



    <!-- ====================================== -->
    <!-- Party RegistryObject - Child Templates -->
    <!-- ====================================== -->

    <!-- Party Registry Object (Individuals (person) and Organisations (group)) -->
    <xsl:template name="partyPerson">
        <xsl:param name="originatingSource"/>
          
        <registryObject group="{$global_group}">

        <!--
        <xsl:message select="concat('Creating key: ', translate(normalize-space(current-grouping-key()),' ',''))"/>
        <xsl:message select="concat('Individual name: ', gmd:individualName)"/>
        <xsl:message select="concat('Organisation name: ', gmd:organisationName)"/>
        -->
        
        <key>
            <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(current-grouping-key()),' ',''))"/>
        </key>
       
        <originatingSource>
            <xsl:value-of select="$originatingSource"/>
        </originatingSource> 
         
        <party type="person">
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
                             <xsl:value-of
                                 select="concat($global_acronym,'/', translate(normalize-space(gmd:organisationName),' ',''))"
                             />
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
    <xsl:template name="partyGroup">
        <xsl:param name="originatingSource"/>
        
        <registryObject group="{$global_group}">
            
            <!--
            <xsl:message select="concat('Creating key: ', translate(normalize-space(current-grouping-key()),' ',''))"/>
            <xsl:message select="concat('Individual name: ', gmd:individualName)"/>
            <xsl:message select="concat('Organisation name: ', gmd:organisationName)"/>
            -->
            <key>
                <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(current-grouping-key()),' ',''))"/>
            </key>
            
            <originatingSource>
                <xsl:value-of select="$originatingSource"/>
            </originatingSource> 
            
            <party type="group">
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
                                
                                <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint[string-length(gco:CharacterString) > 0]">
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
            <identifier type="{localFunc:getIdentifierType(.)}">
                <xsl:value-of select="."/>
            </identifier>
            <xsl:if test="contains(., 'http')">
                <location>
                    <address>
                        <electronic type="url">
                            <value>
                                <xsl:value-of select="."/>
                            </value>
                        </electronic>
                    </address>
                </location>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:function name="localFunc:registryObjectClass" as="xs:string">
        <xsl:param name="scopeCode_sequence" as="xs:string*"/>
       <xsl:choose>
            <xsl:when test="count($scopeCode_sequence) > 0">
                <xsl:choose>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'dataset')">
                        <xsl:text>collection</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'collectionSession')">
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
   </xsl:function>
    
    <xsl:function name="localFunc:registryObjectType" as="xs:string*">
        <xsl:param name="scopeCode_sequence" as="xs:string*"/>
        <xsl:choose>
            <xsl:when test="count($scopeCode_sequence) > 0">
                <xsl:choose>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'dataset')">
                        <xsl:text>dataset</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(lower-case($scopeCode_sequence[1]), 'collectionSession')">
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
    
    <xsl:function name="localFunc:getIdentifierType" as="xs:string">
        <xsl:param name="identifier" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="contains(lower-case($identifier), 'orcid')">
                <xsl:text>orcid</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'purl.org')">
                <xsl:text>purl</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'doi.org')">
                <xsl:text>doi</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'scopus')">
                <xsl:text>scopus</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'handle.net')">
                <xsl:text>handle</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'nla.gov.au')">
                <xsl:text>AU-ANL:PEAU</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'fundref')">
                <xsl:text>fundref</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'http')">
                <xsl:text>url</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'ftp')">
                <xsl:text>url</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>local</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>
