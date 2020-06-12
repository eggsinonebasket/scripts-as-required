<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:csw="http://www.opengis.net/cat/csw"
    xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:cat="http://standards.iso.org/iso/19115/-3/cat" 
    xmlns:cit="http://standards.iso.org/iso/19115/-3/cit" 
    xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx" 
    xmlns:gex="http://standards.iso.org/iso/19115/-3/gex" 
    xmlns:lan="http://standards.iso.org/iso/19115/-3/lan" 
    xmlns:srv="http://standards.iso.org/iso/19115/-3/srv" 
    xmlns:mas="http://standards.iso.org/iso/19115/-3/mas" 
    xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc" 
    xmlns:mco="http://standards.iso.org/iso/19115/-3/mco" 
    xmlns:mda="http://standards.iso.org/iso/19115/-3/mda" 
    xmlns:mds="http://standards.iso.org/iso/19115/-3/mds" 
    xmlns:mdt="http://standards.iso.org/iso/19115/-3/mdt" 
    xmlns:mex="http://standards.iso.org/iso/19115/-3/mex" 
    xmlns:mmi="http://standards.iso.org/iso/19115/-3/mmi" 
    xmlns:mpc="http://standards.iso.org/iso/19115/-3/mpc" 
    xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc" 
    xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd" 
    xmlns:mri="http://standards.iso.org/iso/19115/-3/mri" 
    xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl" 
    xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs" 
    xmlns:msr="http://standards.iso.org/iso/19115/-3/msr" 
    xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq" 
    xmlns:mac="http://standards.iso.org/iso/19115/-3/mac" 
    xmlns:gco="http://standards.iso.org/iso/19115/-3/gco" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:gml="http://www.opengis.net/gml" 
    xmlns:ows="http://www.opengis.net/ows"
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:geonet="http://www.fao.org/geonetwork" 
    xmlns:oai="http://www.openarchives.org/OAI"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:gaFunc="http://gafunc.nowhere.yet"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="ows xs csw gaFunc oai lan mrc xlink srv mrd geonet mas mri mcc mrl xs mco mrs xsi mda msr mdb mds mdq cat mdt mac cit mex gco gcx mmi gmx gex mpc gml custom">
    
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements='*'/>
    <xsl:param name="global_debug" select="false()" as="xs:boolean"/>
    <xsl:param name="global_debugExceptions" select="false()" as="xs:boolean"/>
    
    <!-- Override the following by constructing a stylesheet with the params below populated appropriately, then import this stylesheet.  Run the stylesheet with the params, on your source XML -->
    <xsl:param name="global_PID_Codespace" select="''"/>
    <xsl:param name="global_originatingSource" select="''"/>
    <xsl:param name="global_acronym" select="''"/>
    <xsl:param name="global_baseURI" select="''"/>
    <xsl:param name="global_baseURI_PID" select="''"/>
    <xsl:param name="global_path_PID" select="''"/>
    <xsl:param name="global_path" select="''"/>
    <xsl:param name="global_group" select="''"/>
    <xsl:param name="global_publisherName" select="''"/>
    <xsl:param name="global_publisherPlace" select="''"/>
    <xsl:param name="global_spatialProjection" select="''"/>
    <xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/>
    <xsl:variable name="codelists" select="document('codelists_ISO19115-1.xml')"/>
    
    <!-- =========================================== -->
    <!-- RegistryObjects (root) Template             -->
    <!-- =========================================== -->
    
    <!--xsl:template match="/">
        <registryObjects>
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:text>http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="//mdb:MD_Metadata" mode="registryObjects"/>
        </registryObjects>
    </xsl:template-->
    
    <!--xsl:template match="node()"/-->

    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject Template          -->
    <!-- =========================================== -->
    
    <xsl:template match="mdb:MD_Metadata" mode="process">
        
        <xsl:variable name="originatingSource">
            <xsl:choose>
                <xsl:when test="count(mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0]) > 0">
                    <xsl:value-of select="distinct-values(mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0])"/>
                </xsl:when>
                <xsl:when test="count(mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0]) > 0">
                    <xsl:value-of select="distinct-values(mdb:identificationInfo/*[contains(lower-case(name()),'identification')]/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0])"/>
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
            
            <xsl:apply-templates select="mdb:metadataIdentifier/mcc:MD_Identifier[contains(mcc:codeSpace, 'uuid')]/mcc:code[string-length(.) > 0]" mode="registryObject_key"/>
        
            <originatingSource>
                <xsl:value-of select="$originatingSource"/>
            </originatingSource>
            
            <xsl:variable name="registryObjectTypeSubType_sequence" as="xs:string*">
                <xsl:variable name="scopeCode" select="mdb:metadataScope[1]/mdb:MD_MetadataScope[1]/mdb:resourceScope[1]/mcc:MD_ScopeCode[1]/@codeListValue[1]"/>
                <xsl:choose>
                    <xsl:when test="string-length($scopeCode) > 0">
                        <xsl:choose>
                            <xsl:when test="substring(lower-case($scopeCode), 0, 8) = 'service'">
                                <xsl:text>service</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="string-length(mdb:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType) > 0">
                                        <xsl:value-of select="normalize-space(mdb:identificationInfo/srv:SV_ServiceIdentification/srv:serviceType)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>software</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                
                            </xsl:when>
                            <xsl:when test="substring(lower-case($scopeCode), 0, 9) = 'software'">
                                <xsl:text>collection</xsl:text>
                                <xsl:text>software</xsl:text>
                            </xsl:when>
                            <xsl:when test="substring(lower-case($scopeCode), 0, 21) = 'nongeographicdataset'">
                                <xsl:text>collection</xsl:text>
                                <xsl:text>publication</xsl:text>
                            </xsl:when>
                            <xsl:when test="substring(lower-case($scopeCode), 0, 8) = 'dataset'">
                                <xsl:text>collection</xsl:text>
                                <xsl:text>dataset</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>collection</xsl:text>
                                <xsl:text>dataset</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>collection</xsl:text>
                        <xsl:text>dataset</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
                
            <xsl:element name="{$registryObjectTypeSubType_sequence[1]}">
    
                <xsl:attribute name="type" select="$registryObjectTypeSubType_sequence[2]"/>
                        
                <xsl:if test="$registryObjectTypeSubType_sequence[1] = 'collection'">
                    <xsl:if test="string-length(mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date) > 0">
                            <xsl:attribute name="dateAccessioned">
                                <xsl:value-of select="mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date"/>
                            </xsl:attribute>  
                        </xsl:if>
                </xsl:if>
                
                <xsl:for-each select=".//mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource">
                    <!-- Test for service (then call relatedService but only if current registry object is a collection); otherwise, handle as non service for all objects -->
                    <xsl:choose>
                        <xsl:when test="contains(lower-case(cit:linkage), 'thredds') or contains(lower-case(cit:linkage), '.nc')">
                            <!-- Not sure what to do with many thredds and .nc links just yet - download link maybe later -->
                        </xsl:when>
                        <xsl:when test="contains(cit:protocol, 'ESRI') or contains(cit:protocol, 'OGC') or contains(lower-case(cit:linkage), '?')">
                                <xsl:if test="$registryObjectTypeSubType_sequence[1] = 'collection'">
                                    <xsl:apply-templates select="." mode="registryObject_relatedInfo_service"/>
                                </xsl:if>
                          </xsl:when>
                        <xsl:when test="not(contains(lower-case(cit:description), 'point-of-truth'))">
                            <xsl:apply-templates select="." mode="registryObject_relatedInfo_nonService"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
                
                <xsl:apply-templates select="mdb:metadataIdentifier/mcc:MD_Identifier[contains(mcc:codeSpace, 'uuid')]/mcc:code"
                    mode="registryObject_identifier_global"/>
                
                <xsl:choose>
                   <xsl:when test="string-length(mdb:metadataLinkage/cit:CI_OnlineResource
                        [contains(lower-case(cit:description), 'point-of-truth metadata')]/cit:linkage) > 0">
                        <xsl:apply-templates 
                            select="mdb:metadataLinkage/cit:CI_OnlineResource[contains(lower-case(cit:description), 'point-of-truth metadata')]/cit:linkage" 
                            mode="registryObject_identifier_metadata_URL"/>
                       
                       <xsl:apply-templates 
                           select="mdb:metadataLinkage/cit:CI_OnlineResource[contains(lower-case(cit:description), 'point-of-truth metadata')]/cit:linkage" 
                           mode="registryObject_location_metadata_URL"/>
                    </xsl:when>
                    <xsl:when test="string-length(.//mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[contains(lower-case(mcc:codeSpace), 'persistent identifier')]/mcc:code) > 0">
                        <xsl:apply-templates select=".//mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:identifier/mcc:MD_Identifier[contains(lower-case(mcc:codeSpace), 'persistent identifier')]/mcc:code"
                            mode="registryObject_location_PID"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="mdb:metadataIdentifier/mcc:MD_Identifier[contains(mcc:codeSpace, 'uuid')]/mcc:code"
                                mode="registryObject_location_uuid"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:apply-templates
                    select="mdb:resourceLineage/mrl:LI_Lineage/mrl:statement[string-length(.) > 0]"
                    mode="registryObject_description_lineage"/>
                
                <xsl:apply-templates
                    select="mdb:identificationInfo/*/mri:credit[string-length(.) > 0]"
                    mode="registryObject_description_notes"/>
                
                <xsl:apply-templates
                    select="mdb:identificationInfo/*/mri:purpose[string-length(.) > 0]"
                    mode="registryObject_description_notes"/>
                  
                <xsl:apply-templates select="mdb:identificationInfo/*[contains(lower-case(name()),'identification')]" mode="registryObject">
                    <xsl:with-param name="registryObjectTypeSubType_sequence" select="$registryObjectTypeSubType_sequence"/>
                </xsl:apply-templates>
            </xsl:element>
                
        </registryObject>
        
        <xsl:apply-templates select="mdb:identificationInfo/*[contains(lower-case(name()),'identification')]" mode="relatedRegistryObjects">
            <xsl:with-param name="originatingSource" select="$originatingSource"/>
        </xsl:apply-templates>

    </xsl:template>
    
    <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="registryObject">
        <xsl:param name="registryObjectTypeSubType_sequence"/>
        
        <xsl:for-each-group select="mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address" group-by="cit:electronicMailAddress">
            <xsl:apply-templates select="cit:electronicMailAddress" mode="registryObject_location_email"/>
        </xsl:for-each-group>
        
        <xsl:apply-templates select="srv:containsOperations/srv:SV_OperationMetadata/srv:connectPoint/cit:CI_OnlineResource/cit:linkage" mode="registryObject_identifier_service_URL"/>
        <xsl:apply-templates select="srv:containsOperations/srv:SV_OperationMetadata/srv:connectPoint/cit:CI_OnlineResource/cit:linkage" mode="registryObject_location_service_URL"/>
        
        <xsl:apply-templates select="srv:operatesOn[string-length(@uuidref) > 0]" mode="registryObject_relatedObject_isSupportedBy"/>
        
        <xsl:apply-templates select="mri:citation/cit:CI_Citation/cit:title[string-length(.) > 0]" mode="registryObject_name"/>
        
        
        
        <xsl:variable name="organisationNamesOnly_sequence" as="xs:string*">
            <xsl:for-each-group
                select="mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organisation[count(cit:individual) =0] |
                ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[count(cit:individual) =0] |
                ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[count(cit:individual) =0] |
                ancestor::mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact/cit:CI_Responsibility/cit:party /cit:CI_Organisation[count(cit:individual) =0] |
                ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[count(cit:individual) =0]"
                group-by="cit:name">
                <xsl:value-of select="current-grouping-key()"/>
            </xsl:for-each-group>
        </xsl:variable>
        
         <xsl:for-each
            select="mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party |
            ancestor::mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact/cit:CI_Responsibility/cit:party |
            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party">
            <xsl:apply-templates select="." mode="registryObject_related_object">
                <xsl:with-param name="orgNamesOnly_sequence" select="$organisationNamesOnly_sequence" as="xs:string*"/>
            </xsl:apply-templates>
        </xsl:for-each>
        
        <xsl:apply-templates
            select="mri:topicCategory/mri:MD_TopicCategoryCode[string-length(.) > 0]"
            mode="registryObject_subject"/>
        
        <xsl:apply-templates
            select="mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword[string-length(.) > 0]"
            mode="registryObject_subject"/>
        
         <xsl:apply-templates
             select="mri:abstract[string-length(.) > 0]"
            mode="registryObject_description_brief"/>
        
        <xsl:apply-templates select="mri:extent/gex:EX_Extent/gex:geographicElement/gex:EX_GeographicBoundingBox" mode="registryObject_coverage_spatial"/>
        <xsl:apply-templates select="mri:extent/gex:EX_Extent/gex:geographicElement/gex:EX_BoundingPolygon" mode="registryObject_coverage_spatial"/>
       
       
        <xsl:apply-templates
            select="mri:extent/gex:EX_Extent/gex:temporalElement/gex:EX_TemporalExtent"
            mode="registryObject_coverage_temporal"/>
         
        <xsl:apply-templates
            select="mri:resourceConstraints/mco:MD_LegalConstraints[(count(mco:reference/cit:CI_Citation) = 0) and (mco:useConstraints/mco:MD_RestrictionCode/@codeListValue = 'license') and (string-length(mco:otherConstraints) > 0)]"
            mode="registryObject_rights_license_otherConstraint"/>
       
        <xsl:apply-templates
            select="mri:resourceConstraints/mco:MD_LegalConstraints[(string-length(mco:reference/cit:CI_Citation/cit:title) > 0) and (mco:useConstraints/mco:MD_RestrictionCode/@codeListValue = 'license')]"
            mode="registryObject_rights_license_citation"/>
        
        <xsl:apply-templates
            select="."
           mode="registryObject_rights_access"/>
        
        
        <xsl:if test="$registryObjectTypeSubType_sequence[1] = 'collection'">
            <xsl:apply-templates select="mdb:dateInfo/cit:CI_Date" mode="registryObject_dates"/>
            <xsl:apply-templates select="mri:citation/cit:CI_Citation/cit:date/cit:CI_Date" mode="registryObject_dates"/>
            <xsl:apply-templates select="mri:citation/cit:CI_Citation" mode="registryObject_citationMetadata_citationInfo">
                <xsl:with-param name="registryObjectTypeSubType_sequence" select="$registryObjectTypeSubType_sequence"/>
            </xsl:apply-templates>
        </xsl:if>
        
         
        
   </xsl:template>
    
    
    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject - Related Party Templates -->
    <!-- =========================================== -->
    
    <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="relatedRegistryObjects">
        <xsl:param name="originatingSource"/>
        
        <xsl:for-each
            select="
            mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            
            ancestor::mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            ancestor::mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            
            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)] |
            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual[(string-length(normalize-space(cit:name)) > 0) or (string-length(normalize-space(cit:positionName)) > 0)]">
            <xsl:apply-templates select="." mode="party_person">
                <xsl:with-param name="originatingSource" select="$originatingSource"/>
            </xsl:apply-templates>
        </xsl:for-each>
    
        <xsl:for-each
            select="
            mri:citation/cit:CI_Citation/cit:citedResponsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0] |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributionFormat/mrd:MD_Format/mrd:formatDistributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0]  |
            ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0] |
            ancestor::mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0] |
            ancestor::mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation[string-length(normalize-space(cit:name)) > 0]">
            <xsl:apply-templates select="." mode="party_group">
                <xsl:with-param name="originatingSource" select="$originatingSource"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- =========================================== -->
    <!-- RegistryObject RegistryObject - Child Templates -->
    <!-- =========================================== -->

    <!-- RegistryObject - Key Element  -->
    <xsl:template match="mcc:code" mode="registryObject_key">
        <key>
            <xsl:value-of select="concat($global_acronym, '/', normalize-space(.))"/>
        </key>
    </xsl:template>
    
  <xsl:template match="mcc:code" mode="registryObject_identifier_global">
        <identifier type="global">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>
    
    <!-- RegistryObject - Identifier Element  -->
    
    <xsl:template match="cit:linkage" mode="registryObject_identifier_service_URL">
        <identifier type="uri">
            <xsl:choose>
                <xsl:when test="contains(.,'?')">
                    <xsl:value-of select="substring-before(., '?')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>    
                </xsl:otherwise>
            </xsl:choose>
        </identifier>
    </xsl:template>
    
    <xsl:template match="cit:linkage" mode="registryObject_location_service_URL">
        <location>
            <address>
                <electronic>
                    <xsl:attribute name="type">
                        <xsl:text>url</xsl:text>
                    </xsl:attribute>
                     <!--xsl:attribute name="target">
                        <xsl:text>online</xsl:text>
                    </xsl:attribute-->
                    <value>
                        <xsl:value-of select="."/>    
                    </value>
                </electronic>
            </address>
        </location>
    </xsl:template>
    
    
    
    <xsl:template match="cit:linkage" mode="registryObject_identifier_metadata_URL">
        <identifier type="uri">
            <xsl:value-of select="."/>    
        </identifier>
    </xsl:template>
    
    <xsl:template match="mcc:code" mode="registryObject_location_PID">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="."/>
                    </value>
                </electronic>
            </address>
        </location>
    </xsl:template>
    
   <xsl:template match="mcc:code" mode="registryObject_identifier">
        <identifier>
            <xsl:attribute name="type">
                    <xsl:choose>
                        <!-- - If codespace is provided:
                                      - use mapped type from codespace if it was determined (i.e.default 'local' was not returned); or
                                      - use mapped type from identifier value if it was determined (i.e. default 'local' was not returned); or
                                      - use the codeSpace provided
                                  -If codespace was not provided:
                                       - use mapped type from identifier value
                           -->
                        <xsl:when test="string-length(following-sibling::mcc:codeSpace) > 0">
                            <xsl:choose>
                             <xsl:when test="custom:getIdentifierType(following-sibling::mcc:codeSpace) != 'local'">
                                 <xsl:value-of select="custom:getIdentifierType(following-sibling::mcc:codeSpace)"/>
                             </xsl:when>
                                <xsl:when test="custom:getIdentifierType(.) != 'local'">
                                    <xsl:value-of select="custom:getIdentifierType(.)"/>
                                </xsl:when>
                             <xsl:otherwise>
                                 <xsl:value-of select="following-sibling::mcc:codeSpace"/>
                             </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="custom:getIdentifierType(.)"/>
                        </xsl:otherwise>
                    </xsl:choose>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="contains(., 'hdl:')">
                    <xsl:value-of select="normalize-space(replace(.,'hdl:', ''))"/>   
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(.)"/>   
                </xsl:otherwise>
            </xsl:choose>
            
        </identifier>
    </xsl:template>
    
    <!-- RegistryObject - Identifier Element  -->
    <xsl:template match="cit:linkage" mode="registryObject_identifier">
        <identifier>
            <xsl:attribute name="type" select="custom:getIdentifierType(.)"/>
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="cit:linkage" mode="registryObject_location_metadata_URL">
        <location>
            <address>
                <electronic>
                    <xsl:attribute name="type">
                        <xsl:text>url</xsl:text>
                    </xsl:attribute>
                     <xsl:attribute name="target">
                        <xsl:text>landingPage</xsl:text>
                    </xsl:attribute>
                    <value>
                        <xsl:value-of select="."/>
                    </value>
                </electronic>
            </address>
        </location>
    </xsl:template>
    
    <xsl:template match="mcc:code" mode="registryObject_location_uuid">
        <location>
            <address>
                <electronic>
                    <xsl:attribute name="type">
                        <xsl:text>url</xsl:text>
                    </xsl:attribute>
                     <xsl:attribute name="target">
                        <xsl:text>landingPage</xsl:text>
                    </xsl:attribute>
                    <value>
                        <xsl:value-of select="concat('http://', $global_baseURI, $global_path, .)"/>
                    </value>
                </electronic>
            </address>
        </location>
    </xsl:template>
    
    <xsl:template match="cit:electronicMailAddress" mode="registryObject_location_email">
        <location>
            <address>
                <electronic>
                    <xsl:attribute name="type">
                        <xsl:text>email</xsl:text>
                    </xsl:attribute>
                    <value>
                        <xsl:value-of select="."/>
                    </value>
                </electronic>
            </address>
        </location>
    </xsl:template>
    

    <!-- RegistryObject - Name Element  -->
    <xsl:template match="mri:citation/cit:CI_Citation/cit:title" mode="registryObject_name">
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
    <xsl:template match="cit:CI_Date" mode="registryObject_dates">
        
        <xsl:variable name="dateValue_sequence" select="normalize-space(cit:date/gco:DateTime)" as="xs:string*"/>
        <xsl:variable name="dateCode_sequence" select="normalize-space(cit:dateType/cit:CI_DateTypeCode/@codeListValue)" as="xs:string*"/>
        
        <xsl:if test="$global_debugExceptions">
            <xsl:if test="count($dateValue_sequence) = 0">
                <xsl:message select="'Exception - No value in cit:date/gco:DateTime'"/>
            </xsl:if>
            <xsl:if test="count($dateValue_sequence) > 1">
                <xsl:message select="'Exception - More than one value in cit:date/gco:DateTime'"/>
            </xsl:if>
            <xsl:if test="count($dateCode_sequence) = 0">
                <xsl:message select="'Exception - No value in cit:dateType/cit:CI_DateTypeCode/@codeListValue'"/>
            </xsl:if>
            <xsl:if test="count($dateCode_sequence) > 1">
                <xsl:message select="'Exception - More than one value in cit:dateType/cit:CI_DateTypeCode/@codeListValue'"/>
            </xsl:if>
        </xsl:if>
        
        <xsl:if test="(count($dateValue_sequence) > 0) and (string-length($dateValue_sequence[1]) > 0)">
            <dates>
                
                    <xsl:if test="count($dateCode_sequence) > 0 and (string-length($dateCode_sequence[1]) > 0)">
                        <xsl:attribute name="type">
                            <xsl:choose>
                                <xsl:when test="contains(lower-case($dateCode_sequence[1]), 'creation')">
                                    <xsl:text>created</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains(lower-case($dateCode_sequence[1]), 'publication')">
                                    <xsl:text>issued</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains(lower-case($dateCode_sequence[1]), 'revision')">
                                    <xsl:text>modified</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:if>
                
                <date>
                    <xsl:attribute name="type">
                        <xsl:text>dateFrom</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="dateFormat">
                        <xsl:text>W3CDTF</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="$dateValue_sequence[1]"/>
                </date>
            </dates>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Related Object (Organisation or Individual) Element -->
    <xsl:template match="cit:party" mode="registryObject_related_object">
        <xsl:param name="orgNamesOnly_sequence" as="xs:string*"/>
        
            <xsl:variable name="name">
                <xsl:choose>
                    <xsl:when test="string-length(*/cit:name) > 0">
                        <xsl:value-of select="*/cit:name"/>
                    </xsl:when>
                    <xsl:when test="string-length(*/cit:positionName) > 0">
                        <xsl:value-of select="*/cit:positionName"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
        
              
            <xsl:choose>
                <!-- If dealing with an organisation that has an individual, don't use the person's role to relate the organisation - only
                        relate this organisation if not already related, and use general 'hasAssociationWithin'-->
                <xsl:when test="(string-length(cit:CI_Organisation/cit:name) > 0) and (count(cit:CI_Organisation/cit:individual/cit:CI_Individual) > 0)">
                    <xsl:if test="(count($orgNamesOnly_sequence[. = $name]) = 0)">
                        <relatedObject>
                            <key>
                                <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space($name),' ',''))"/>
                            </key>
                            <relation>
                               <xsl:attribute name="type">
                                   <xsl:text>hasAssociationWith</xsl:text>
                               </xsl:attribute>
                            </relation>
                        </relatedObject>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="count(distinct-values(preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValu) > 0)">
                            <xsl:for-each select="distinct-values(preceding-sibling::cit:role/cit:CI_RoleCode/@codeListValue)">
                                <xsl:variable name="role" select="."/>
                                    <xsl:variable name="codelist"
                                        select="$codelists/codelists/codelist[@name = 'CI_RoleCode']"/>
                                    
                                    <xsl:if test="$global_debug">
                                        <xsl:message select="concat('entries in codelist : ', count($codelist/entry))"/>
                                    </xsl:if>
                                    
                                    <xsl:variable name="type">
                                        <xsl:value-of select="$codelist/entry[code = $role]/description"/>
                                    </xsl:variable>
                                    
                                  <relatedObject>
                                      <key>
                                          <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space($name),' ',''))"/>
                                      </key>
                                      <relation>
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
                                  </relatedObject>
                            </xsl:for-each>
                        </xsl:when>
                       <xsl:otherwise>
                           <!-- no roles, so use default 'hasAssociationWith'-->
                           <relatedObject>
                               <key>
                                   <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space($name),' ',''))"/>
                               </key>
                               <relation>
                                 <xsl:attribute name="type">
                                     <xsl:text>hasAssociationWith</xsl:text>
                                 </xsl:attribute>
                               </relation>
                           </relatedObject> </xsl:otherwise>
                    </xsl:choose>
                
                </xsl:otherwise>
        </xsl:choose>
        
            <xsl:for-each select="cit:CI_Organisation/cit:individual/cit:CI_Individual">
                  <xsl:variable name="name">
                      <xsl:choose>
                          <xsl:when test="string-length(cit:name) > 0">
                              <xsl:value-of select="cit:name"/>
                          </xsl:when>
                          <xsl:when test="string-length(cit:positionName) > 0">
                              <xsl:value-of select="cit:positionName"/>
                          </xsl:when>
                      </xsl:choose>
                  </xsl:variable>
                      
                    <xsl:if test="string-length(normalize-space($name)) > 0">
                        <relatedObject>
                            <key>
                                <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space($name),' ',''))"/>
                            </key>
                            <xsl:for-each select="distinct-values(../../../../cit:role/cit:CI_RoleCode/@codeListValue)">
                                <xsl:variable name="role" select="."/>
                                  <relation>
                                      <xsl:variable name="codelist"
                                          select="$codelists/codelists/codelist[@name = 'CI_RoleCode']"/>
                                      
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
                            </xsl:for-each>
                        </relatedObject>
                    </xsl:if>
                </xsl:for-each>

    </xsl:template>
    
    <xsl:template match="mri:MD_TopicCategoryCode" mode="registryObject_subject">
        <subject type="local">
            <xsl:value-of select="."></xsl:value-of>
        </subject>
    </xsl:template>
    
    

    <xsl:template match="mri:keyword" mode="registryObject_subject">
        <subject>
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="contains(lower-case(following-sibling::mri:thesaurusName/cit:CI_Citation/cit:title), 'anzsrc')">
                        <xsl:text>anzsrc-for</xsl:text>    
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>local</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="normalize-space(.)"></xsl:value-of>
        </subject>
    </xsl:template>
    
    <!-- RegistryObject - Decription Element -->
    <xsl:template match="mri:abstract" mode="registryObject_description_brief">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="brief">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <!-- RegistryObject - Decription Element - lineage -->
    <xsl:template match="mrl:statement" mode="registryObject_description_lineage">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="lineage">
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="mri:credit" mode="registryObject_description_notes">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="notes">
                <xsl:text>&lt;b&gt;Credit&lt;/b&gt;</xsl:text>
                <xsl:text>&lt;br/&gt;</xsl:text>
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="mri:purpose" mode="registryObject_description_notes">
        <xsl:if test="string-length(normalize-space(.)) > 0">
            <description type="notes">
                <xsl:text>&lt;b&gt;Purpose&lt;/b&gt;</xsl:text>
                <xsl:text>&lt;br/&gt;</xsl:text>
                <xsl:value-of select="."/>
            </description>
        </xsl:if>
    </xsl:template>
    
   <!-- RegistryObject - Coverage Spatial Element -->
    <xsl:template match="gex:EX_GeographicBoundingBox" mode="registryObject_coverage_spatial">
        
        <xsl:if test="string-length(normalize-space(gex:northBoundLatitude/gco:Decimal)) > 0"/>
        <xsl:if
             test="
                (string-length(normalize-space(gex:northBoundLatitude/gco:Decimal)) > 0) and
                (string-length(normalize-space(gex:southBoundLatitude/gco:Decimal)) > 0) and
                (string-length(normalize-space(gex:westBoundLongitude/gco:Decimal)) > 0) and
                (string-length(normalize-space(gex:eastBoundLongitude/gco:Decimal)) > 0)">
                 <xsl:variable name="spatialString">
                     <xsl:value-of
                         select="normalize-space(concat('northlimit=',gex:northBoundLatitude/gco:Decimal,'; southlimit=',gex:southBoundLatitude/gco:Decimal,'; westlimit=',gex:westBoundLongitude/gco:Decimal,'; eastLimit=',gex:eastBoundLongitude/gco:Decimal))"/>
                     
                     <xsl:if
                         test="
                         (string-length(normalize-space(gex:EX_VerticalExtent/gex:maximumValue/gco:Real)) > 0) and
                         (string-length(normalize-space(gex:EX_VerticalExtent/gex:minimumValue/gco:Real)) > 0)">
                         <xsl:value-of
                             select="normalize-space(concat('; uplimit=',gex:EX_VerticalExtent/gex:maximumValue/gco:Real,'; downlimit=',gex:EX_VerticalExtent/gex:minimumValue/gco:Real))"
                         />
                     </xsl:if>
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

    <!-- RegistryObject - Coverage Temporal Element -->
    <xsl:template match="gex:EX_TemporalExtent" mode="registryObject_coverage_temporal">
        <xsl:if
            test="(string-length(normalize-space(gex:extent/gml:TimePeriod/gml:beginPosition)) > 0) or
            (string-length(normalize-space(gex:extent/gml:TimePeriod/gml:endPosition)) > 0)">
            <coverage>
                <temporal>
                    <xsl:if
                        test="string-length(normalize-space(gex:extent/gml:TimePeriod/gml:beginPosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateFrom</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gex:extent/gml:TimePeriod/gml:beginPosition)"
                            />
                        </date>
                    </xsl:if>
                    <xsl:if
                        test="string-length(normalize-space(gex:extent/gml:TimePeriod/gml:endPosition)) > 0">
                        <date>
                            <xsl:attribute name="type">
                                <xsl:text>dateTo</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="dateFormat">
                                <xsl:text>W3CDTF</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                                select="normalize-space(gex:extent/gml:TimePeriod/gml:endPosition)"
                            />
                        </date>
                    </xsl:if>
                </temporal>
            </coverage>
        </xsl:if>
    </xsl:template>

    <xsl:template match="srv:operatesOn" mode="registryObject_relatedObject_isSupportedBy">
            <relatedObject>
                <key>
                    <xsl:value-of select="concat($global_acronym, '/', normalize-space(@uuidref))"/>
                </key>
                <relation type="isSupportedBy"/>
            </relatedObject>
    </xsl:template>
    
  <xsl:template match="cit:CI_OnlineResource" mode="registryObject_relatedInfo_service">       
        
        <xsl:variable name="identifierValue" select="normalize-space(cit:linkage)"/>
        
        <relatedInfo>
            <xsl:attribute name="type" select="'service'"/>   
            
            <xsl:apply-templates select="." mode="relatedInfo_all"/>
            
            <relation>
                <xsl:attribute name="type">
                    <xsl:text>supports</xsl:text>
                </xsl:attribute>
                <xsl:if test="(contains($identifierValue, '?')) or (contains($identifierValue, '.nc'))">
                    <url>
                        <xsl:value-of select="$identifierValue"/>
                    </url>
                </xsl:if>
            </relation>
            
            
        </relatedInfo>
        
    </xsl:template>
    
    <xsl:template match="cit:CI_OnlineResource" mode="registryObject_relatedInfo_nonService">       
        
        <relatedInfo>
            <xsl:attribute name="type" select="'relatedInformation'"/>   
            
            <xsl:apply-templates select="." mode="relatedInfo_all"/>
            
            <relation>
                <xsl:attribute name="type">
                    <xsl:text>hasAssociationWith</xsl:text>
                </xsl:attribute>
            </relation>
            
            
        </relatedInfo>
        
    </xsl:template>
    
    
    <xsl:template match="cit:CI_OnlineResource" mode="relatedInfo_all">     
        
        <xsl:variable name="identifierValue" select="normalize-space(cit:linkage)"/>
        
        <identifier>
            <xsl:attribute name="type">
                <xsl:value-of select="custom:getIdentifierType($identifierValue)"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="contains($identifierValue, '?')">
                    <xsl:value-of select="substring-before(., '?')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$identifierValue"/>
                </xsl:otherwise>
            </xsl:choose>
            
        </identifier>
        
        <xsl:choose>
            <!-- Use description as title if we have it... -->
            <xsl:when test="string-length(normalize-space(cit:description)) > 0">
                <title>
                    <xsl:value-of select="normalize-space(cit:description)"/>
                    
                    <!-- ...and then name in brackets following -->
                    <xsl:if
                        test="not(normalize-space(cit:name) = normalize-space(cit:description)) and string-length(normalize-space(cit:name)) > 0">
                        <xsl:value-of select="concat(' (', cit:name, ')')"/>
                    </xsl:if>
                </title>
            </xsl:when>
            <!-- No description, so use name as title if we have it -->
            <xsl:otherwise>
                <xsl:if
                    test="string-length(normalize-space(cit:name)) > 0">
                    <title>
                        <xsl:value-of select="concat('(', cit:name, ')')"/>
                    </title>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="mco:MD_LegalConstraints" mode="registryObject_rights_license_otherConstraint">
        
        <xsl:variable name="licenceText" select="mco:otherConstraints"/>
        <xsl:call-template name="populateLicence">
            <xsl:with-param name="licenceText" select="$licenceText"/>
        </xsl:call-template>
     </xsl:template>
    
    <xsl:template match="mco:MD_LegalConstraints" mode="registryObject_rights_license_citation">
        
        <xsl:variable name="licenceText" select="mco:reference/cit:CI_Citation/cit:title"/>
        <xsl:call-template name="populateLicence">
            <xsl:with-param name="licenceText" select="$licenceText"/>
        </xsl:call-template>
        
    </xsl:template>
    
   <!-- RegistryObject - Rights License -->
    <xsl:template name="populateLicence">
        <xsl:param name="licenceText"/>
        
        <xsl:if test="$global_debug">
            <xsl:message select="concat('count $licenseCodelist : ', count($licenseCodelist))"/>
        </xsl:if>
        
                    
                    <xsl:variable name="inputTransformed" select="normalize-space(replace(replace(replace($licenceText, 'icence', 'icense', 'i'), '[\d.]+', ''), '-', ''))"/>
                    <xsl:variable name="codeDefinition_sequence" select="$licenseCodelist/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[@gml:id='LicenseCodeAustralia' or @gml:id='LicenseCodeInternational']/gmx:codeEntry/gmx:CodeDefinition[normalize-space(replace(replace(gml:name, '\{n\}', ' '), '-', '')) = $inputTransformed]" as="node()*"/>
                    
                    
                     <xsl:if test="$global_debug">
                         <xsl:message select="concat('count $codeDefinition_sequence : ', count($codeDefinition_sequence))"/>
                     </xsl:if>
                     
                    <xsl:choose>
                        <xsl:when test="count($codeDefinition_sequence) > 0">
                             <xsl:for-each select="$codeDefinition_sequence">
                                 <xsl:variable name="codeDefinition" select="." as="node()"/>
                                  <xsl:variable name="licenceVersion" as="xs:string*">
                                     <xsl:analyze-string select="normalize-space($licenceText)"
                                         regex="[\d.]+">
                                         <xsl:matching-substring>
                                             <xsl:value-of select="regex-group(0)"/>
                                         </xsl:matching-substring>
                                     </xsl:analyze-string>
                                  </xsl:variable>
                                 
                                 <xsl:variable name="licenceURI">
                                      <xsl:choose>
                                          <xsl:when test="(number($licenceVersion) > 3) and contains(gml:remarks, '/au')">
                                                  <xsl:value-of select="substring-before(replace($codeDefinition/gml:remarks, '\{n\}', $licenceVersion), '/au')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="replace($codeDefinition/gml:remarks, '\{n\}', $licenceVersion)"/>
                                            </xsl:otherwise>
                                      </xsl:choose>
                                  </xsl:variable>
                     
                                  <xsl:if test="$global_debug">
                                     <xsl:message select="concat('licenceURI : ', $licenceURI)"/>
                                  </xsl:if>
                                  
                                 <xsl:variable name="type" select="gml:identifier"/>
                                 
                                 <rights>
                                     <licence>
                                         
                                         <xsl:if test="string-length($licenceURI) and count($licenceVersion) > 0">
                                              <xsl:attribute name="rightsUri">
                                                  <xsl:value-of select="$licenceURI"/>
                                              </xsl:attribute>
                                         </xsl:if>
                                         
                                         <xsl:if test="string-length($type) > 0">
                                              <xsl:attribute name="type">
                                                  <xsl:value-of select="$type"/>
                                              </xsl:attribute>
                                         </xsl:if>
                                         
                                         <xsl:value-of select="$licenceText"/>
                                     </licence>
                                  </rights>
                                 
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <rights>
                                <licence>
                                    <xsl:value-of select="$licenceText"/>
                                </licence>
                            </rights>
                         </xsl:otherwise>
                    </xsl:choose>
     </xsl:template>
    
    <!-- RegistryObject - Rights Statement Access -->
    <xsl:template match="*[contains(lower-case(name()),'identification')]" mode="registryObject_rights_access">
        <!-- if there is one or more MD_ClassificationCode of 'unclassified', and all occurences of MD_ClassificationCode are 'unclassified', set accessRights to 'open' -->
        <rights>
            <accessRights>
                <xsl:choose>
                    <xsl:when test="count(mri:resourceConstraints/mco:MD_SecurityConstraints/mco:classification/mco:MD_ClassificationCode[@codeListValue = 'unclassified']) > 0 and
                        count(mri:resourceConstraints/mco:MD_SecurityConstraints/mco:classification/mco:MD_ClassificationCode/@codeListValue) = 
                        count(mri:resourceConstraints/mco:MD_SecurityConstraints/mco:classification/mco:MD_ClassificationCode[@codeListValue = 'unclassified'])">
                        <xsl:attribute name="type">
                            <xsl:text>open</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                    <!-- when MD_ClassificationCode is populated, but not as above -->
                    <xsl:when test="count(mri:resourceConstraints/mco:MD_SecurityConstraints/mco:classification/mco:MD_ClassificationCode/@codeListValue) > 0">
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
    
     <!-- RegistryObject - CitationInfo Element -->
    <xsl:template match="cit:CI_Citation" mode="registryObject_citationMetadata_citationInfo">
        <xsl:param name="registryObjectTypeSubType_sequence"/>
        
        <!-- Attempt to obtain contributor names; only construct citation if we have contributor names -->
        
        <xsl:variable name="allContributorName_sequence" as="xs:string*">
            <xsl:choose>
                <!-- use any invidual names that are either author or coAuthor -->
                <xsl:when test="
                    ((count(cit:citedResponsibleParty/cit:CI_Responsibility[contains(lower-case(cit:role/cit:CI_RoleCode/@codeListValue), 'author')]/cit:party/cit:CI_Individual/cit:name[string-length(.) > 0]) > 0) or
                    (count(cit:citedResponsibleParty/cit:CI_Responsibility[contains(lower-case(cit:role/cit:CI_RoleCode/@codeListValue), 'author')]/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:name[string-length(.) > 0]) > 0))">
                    <!-- note that even when no results are found, value-of constructs empty text node, so copy-of is used below instead -->
                    <xsl:copy-of select="cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'author']/cit:party/cit:CI_Individual/cit:name[string-length(.) > 0]"/>
                    <xsl:copy-of select="cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'author']/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:name[string-length(.) > 0]"/>
                    <xsl:copy-of select="cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'coAuthor']/cit:party/cit:CI_Individual/cit:name[string-length(.) > 0]"/>
                    <xsl:copy-of select="cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'coAuthor']/cit:party/cit:CI_Organisation/cit:individual/cit:CI_Individual/cit:name[string-length(.) > 0]"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- there are no invidual names that are either author or coAuthor, so use organisation names -->
                     <xsl:copy-of select="cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'author']/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0]"/>
                    <xsl:copy-of select="cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'coAuthor']/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0]"/>
                </xsl:otherwise>
             </xsl:choose>
        </xsl:variable>
        
       <xsl:if test="$global_debug">
            <xsl:for-each select="$allContributorName_sequence">
                    <xsl:message select="concat('Contributor name: ', .)"/>
            </xsl:for-each>
        </xsl:if>
        
  
        
        <xsl:if test="count($allContributorName_sequence) > 0">
           <citationInfo>
                <citationMetadata>
                    <identifier>
                        <xsl:choose>
                                <xsl:when 
                                    test="count(cit:identifier/mcc:MD_Identifier/mcc:code) and (string-length(cit:identifier[1]/mcc:MD_Identifier/mcc:code[1]) > 0)">
                                   <xsl:variable name="identifier" select="cit:identifier[1]/mcc:MD_Identifier/mcc:code[1]"/>   
                                   <xsl:choose>
                                       <xsl:when test="contains($identifier, 'hdl:')">
                                            <xsl:attribute name="type" select="'handle'"/>
                                            <xsl:value-of select="normalize-space(replace($identifier,'hdl:', ''))"/>   
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="type" select="'uri'"/>
                                            <xsl:value-of select="normalize-space($identifier)"/>   
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="type" select="'uri'"/>
                                    <xsl:value-of select="concat('http://', $global_baseURI, $global_path, ancestor::mdb:MD_Metadata/mdb:metadataIdentifier[1]/mcc:MD_Identifier[1]/mcc:code[1])"/>
                                </xsl:otherwise>
                        </xsl:choose>
                    </identifier>
             
                    <title>
                        <xsl:value-of select="cit:title"/>
                    </title>
                    
                    <xsl:if test="$global_debugExceptions">
                        <xsl:choose>
                            <xsl:when test="count(cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime) > 1">
                                <xsl:message select="'Exception: more than one publication date in citation block'"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:if>
                    
                   <date>
                        <xsl:attribute name="type">
                            <xsl:text>publicationDate</xsl:text>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when 
                                test="(count(cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date/gco:DateTime) > 0) and
                                      (string-length(cit:date[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date/gco:DateTime) > 3)">
                                <xsl:value-of select="substring(cit:date[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date/gco:DateTime, 1, 4)"/>
                            </xsl:when>
                            <xsl:when 
                                test="(count(cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime) > 0) and
                                    (string-length(cit:date[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime) > 3)">
                                <xsl:value-of select="substring(cit:date[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime, 1, 4)"/>
                            </xsl:when>
                            <xsl:when 
                                test="(count(cit:date/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date/gco:DateTime) > 0) and
                                    (string-length(cit:date[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date/gco:DateTime) > 3)">
                                <xsl:value-of select="substring(cit:date[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date/gco:DateTime, 1, 4)"/>
                            </xsl:when>
                            <xsl:when 
                                test="(count(ancestor::mdb:MD_Metadata/mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date/gco:DateTime) > 0) and
                                    (string-length(ancestor::mdb:MD_Metadata/mdb:dateInfo[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date/gco:DateTime) > 3)">
                                <xsl:value-of select="ancestor::mdb:MD_Metadata/mdb:dateInfo[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'revision']/cit:date/gco:DateTime"/>
                            </xsl:when>
                            <xsl:when 
                                test="(count(ancestor::mdb:MD_Metadata/mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime) > 0) and
                                    (string-length(ancestor::mdb:MD_Metadata/mdb:dateInfo[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime) > 3)">
                                <xsl:value-of select="ancestor::mdb:MD_Metadata/mdb:dateInfo[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'publication']/cit:date/gco:DateTime"/>
                            </xsl:when>
                            <xsl:when 
                                test="(count(ancestor::mdb:MD_Metadata/mdb:dateInfo/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date/gco:DateTime) > 0) and
                                    (string-length(ancestor::mdb:MD_Metadata/mdb:dateInfo[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date/gco:DateTime) > 3)">
                                <xsl:value-of select="ancestor::mdb:MD_Metadata/mdb:dateInfo[1]/cit:CI_Date[cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/cit:date/gco:DateTime"/>
                            </xsl:when>
                            </xsl:choose>
                    </date>
                    
                  <!-- If there is more than one contributor, and publisher 
                  name is within contributor list, remove it -->
                    
                    <xsl:variable name="publisher_sequence" as="node()*" select="
                        cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher']/cit:party |
                        ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher']/cit:party"/>  
                    
                    
                    <xsl:choose>
                        <xsl:when test="count($allContributorName_sequence) > 0">
                            <xsl:for-each select="distinct-values($allContributorName_sequence)">
                                        <contributor seq="{position()}">
                                            <namePart>
                                                <xsl:value-of select="."/>
                                            </namePart>
                                        </contributor>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>
                    
                    <publisher>
                        <xsl:choose>
                            <xsl:when test="count(cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher']/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0]) > 0">
                                <xsl:value-of select="cit:citedResponsibleParty/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher'][1]/cit:party[1]/cit:CI_Organisation/cit:name"/>    
                            </xsl:when>
                            <xsl:when test="count(ancestor::mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher']/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0]) > 0">
                                <xsl:value-of select="ancestor::mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher'][1]/cit:party[1]/cit:CI_Organisation/cit:name"/>
                            </xsl:when>
                            <xsl:when test="count(ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher']/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0]) > 0">
                                <xsl:value-of select="ancestor::mdb:MD_Metadata/mdb:distributionInfo/*/mrd:distributor/mrd:MD_Distributor/mrd:distributorContact/cit:CI_Responsibility[cit:role/cit:CI_RoleCode/@codeListValue = 'publisher'][1]/cit:party[1]/cit:CI_Organisation/cit:name"/>
                            </xsl:when>
                            <!--xsl:when test="count(ancestor::mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name[string-length(.) > 0]) > 0">
                                <xsl:value-of select="ancestor::mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/cit:CI_Responsibility[1]/cit:party[1]/cit:CI_Organisation/cit:name"/>
                            </xsl:when-->
                        </xsl:choose>
                    </publisher>
                    
               </citationMetadata>
            </citationInfo>
        </xsl:if>
    </xsl:template>
    
  
    <!-- ====================================== -->
    <!-- Party RegistryObject - Child Templates -->
    <!-- ====================================== -->

    <xsl:template match="cit:CI_Individual" mode="party_person">
        <xsl:param name="originatingSource"/>
        
        <xsl:variable name="name">
            <xsl:choose>
                <xsl:when test="string-length(cit:name) > 0">
                    <xsl:value-of select="cit:name"/>
                </xsl:when>
                <xsl:when test="string-length(cit:positionName) > 0">
                    <xsl:value-of select="cit:positionName"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <registryObject group="{$global_group}">
            
            <key>
                <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space($name),' ',''))"/>
            </key>
            
            <originatingSource>
                <xsl:value-of select="$originatingSource"/>
            </originatingSource> 
            
            <party type="person">
                <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:onlineResource/cit:CI_OnlineResource"/>
                
                <name type="primary">
                    <namePart>
                        <xsl:value-of select="normalize-space($name)"/>
                    </namePart>
                </name>
                
                
                <!-- If this individual does not have contactInfo, and is a child of CI_Organisation , associate email and phone number from the Organisation with this individual -->
                <xsl:choose>
                    <xsl:when test="(count(cit:contactInfo) = 0) and contains(name(../..), 'CI_Organisation')">
                        <xsl:apply-templates select="ancestor::cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress[string-length(.) > 0]"/>
                        <xsl:apply-templates select="ancestor::cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone[count(*) > 0]"/>
                        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address[count(*) > 0]"/>
                        <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress[string-length(.) > 0]"/>
                        <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone[count(*) > 0]"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                
                
            </party>
        </registryObject>
    </xsl:template>
        
    <xsl:template match="cit:CI_Organisation" mode="party_group">
        <xsl:param name="originatingSource"/>
            
           <registryObject group="{$global_group}">
            
                <key>
                    <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(cit:name),' ',''))"/>
               </key>
                
                <originatingSource>
                    <xsl:value-of select="$originatingSource"/>
                </originatingSource> 
                
                <party type="group">
                    <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:onlineResource/cit:CI_OnlineResource"/>
                    <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:onlineResource/cit:CI_OnlineResource[contains(lower-case(.), 'abn')]" mode="ABN"/>
                    
                    <name type="primary">
                        <namePart>
                            <xsl:value-of select="normalize-space(cit:name)"/>
                        </namePart>
                    </name>
                    
                    <xsl:choose>
                        <xsl:when test="(count(cit:individual/cit:CI_Individual) > 0)"> 
                            <!--  individual position name, so relate this individual to this organisation... -->
                            <xsl:for-each select="cit:individual/cit:CI_Individual">
                                <xsl:variable name="name">
                                    <xsl:choose>
                                        <xsl:when test="string-length(cit:name) > 0">
                                            <xsl:value-of select="cit:name"/>
                                        </xsl:when>
                                        <xsl:when test="string-length(cit:positionName) > 0">
                                            <xsl:value-of select="cit:positionName"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:variable>
                                
                                <xsl:if test="(string-length($name) > 0)">
                                  <relatedObject>
                                      <key>
                                          <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space($name),' ',''))"/>
                                      </key>
                                      <relation type="hasMember"/>
                                  </relatedObject>
                                </xsl:if>  
                             </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <!--  no individual position name, so use this address for this organisation -->
                            <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address[count(*) > 0]"/>
                            <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress[string-length(.) > 0]"/>
                            <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone[count(*) > 0]"/>
                        </xsl:otherwise>
                   </xsl:choose>
                    
                </party>
        </registryObject>
        <!--xsl:if test="(count(cit:individual/cit:CI_Individual) > 0) and (string-length(cit:individual/cit:CI_Individual/cit:positionName) > 0)"> 
            <xsl:apply-templates select="." mode="party_position">
                <xsl:with-param name="originatingSource" select="$originatingSource"/>
            </xsl:apply-templates>
        </xsl:if-->
     </xsl:template>     
     
     <!--xsl:template match="cit:CI_Organisation" mode="party_position">
            <xsl:param name="originatingSource"/>
            
           <registryObject group="{$global_group}">
            
                <key>
                    <xsl:value-of select="concat($global_acronym, '/', translate(normalize-space(cit:individual/cit:CI_Individual/cit:positionName),' ',''))"/>
               </key>
                
                <originatingSource>
                    <xsl:value-of select="$originatingSource"/>
                </originatingSource> 
                
                <party type="person">
                    <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:onlineResource/cit:CI_OnlineResource"/>
                    
                    <name type="primary">
                        <namePart>
                            <xsl:value-of select="normalize-space(cit:individual/cit:CI_Individual/cit:positionName)"/>
                        </namePart>
                    </name>
                    
                    <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address"/>
                    <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress[string-length(.) > 0]"/>
                    <xsl:apply-templates select="cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone"/>
                    
                </party>
        </registryObject>
     </xsl:template-->
    
    <xsl:template match="cit:CI_OnlineResource">
        <xsl:if test="string-length(cit:linkage) > 0">
            <identifier>
                <xsl:attribute name="type">
                    <xsl:value-of select="custom:getIdentifierType(cit:linkage)"/>       
                </xsl:attribute>
                <xsl:value-of select="cit:linkage"/>
            </identifier>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="cit:CI_OnlineResource[contains(lower-case(.), 'abn')]" mode="ABN">
        <xsl:if test="string-length(cit:linkage) > 0">
            <identifier>
                <xsl:attribute name="type">
                    <xsl:text>ABN</xsl:text>
                </xsl:attribute>
                <xsl:analyze-string select="cit:linkage" regex="[\d]+">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(0)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </identifier>
        </xsl:if>
    </xsl:template>
    
                     
    <xsl:template match="cit:CI_Address">
       <location>
        <address>
            <physical type="streetAddress">
               
                <xsl:for-each select="cit:deliveryPoint">
                     <addressPart type="addressLine">
                         <xsl:value-of select="normalize-space(.)"/>
                     </addressPart>
                </xsl:for-each>
                
                 <xsl:for-each select="cit:city">
                      <addressPart type="suburbOrPlaceLocality">
                          <xsl:value-of select="normalize-space(.)"/>
                      </addressPart>
                </xsl:for-each>
                
                 <xsl:for-each select="cit:administrativeArea">
                     <addressPart type="stateOrTerritory">
                         <xsl:value-of select="normalize-space(.)"/>
                     </addressPart>
                 </xsl:for-each>
                    
                 <xsl:for-each select="cit:postalCode">
                     <addressPart type="postCode">
                         <xsl:value-of select="normalize-space(.)"/>
                     </addressPart>
                 </xsl:for-each>
                 
                  <xsl:for-each select="cit:country">
                     <addressPart type="country">
                         <xsl:value-of select="normalize-space(.)"/>
                     </addressPart>
                </xsl:for-each>
            </physical>
        </address>
    </location>
    </xsl:template>
    
    <xsl:template match="cit:electronicMailAddress">

        <location>
            <address>
                <electronic type="email">
                    <value>
                        <xsl:value-of select="normalize-space(.)"/>
                    </value>
                </electronic>
            </address>
        </location>
    </xsl:template>
    
    <xsl:template match="cit:CI_Telephone">
        <xsl:for-each select=".[cit:numberType/cit:CI_TelephoneTypeCode/@codeListValue = 'facsimile']/cit:number">
            <location>
                <address>
                    <physical type="streetAddress">
                        <addressPart>
                            <xsl:attribute name="type">
                                <xsl:text>faxNumber</xsl:text>
                            </xsl:attribute>
                           <xsl:value-of select="normalize-space(.)"/>
                        </addressPart>
                    </physical>
                </address>
            </location>
        </xsl:for-each>
        
        <xsl:for-each select=".[cit:numberType/cit:CI_TelephoneTypeCode/@codeListValue = 'voice']/cit:number">
            <location>
                <address>
                    <physical type="streetAddress">
                        <addressPart>
                            <xsl:attribute name="type">
                                <xsl:text>telephoneNumber</xsl:text>
                            </xsl:attribute>
                           <xsl:value-of select="normalize-space(.)"/>
                        </addressPart>
                    </physical>
                </address>
            </location>
        </xsl:for-each>
    </xsl:template>
    
   
    
</xsl:stylesheet>