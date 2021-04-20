<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xpath-default-namespace="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:here="http://here.nowhere.yet"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" >
    
    <xsl:param name="columnSeparator" select="'^'"/>
    <xsl:param name="valueSeparator" select="','"/>
    
    <xsl:output omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>  
    
    <xsl:import href="CustomFunctions.xsl"/>
        
       
    
    <xsl:variable name="keyPrefix" select="'e-publications.une.edu.au/'"/>
    <!--xsl:variable name="keyPrefix" select="''"/-->
    
    <xsl:param name="compareWithOtherDatasource" select="true()"/>
    <!--xsl:param name="registry_address_input" select="'demo.researchdata.ardc.edu.au'"/-->
    <xsl:param name="registry_address_input" select="'researchdata.edu.au'"/>
    <xsl:param name="registry_address_other" select="'researchdata.edu.au'"/>
    <!-- Presuming comparing demo xml with prod file -->
    <!-- change the following the the correct other datasource content for the contributor that you are working with and set $compareWithOtherDatasource to true()-->
    <!--xsl:variable name="otherDatasourceRifCS" select="document('~/projects/UniversityOfCanberra/PURE-at-University-of-Canberra-RIF-CS-Export_demo_Collections.xml')"/-->
    <!--xsl:variable name="otherDatasourceRifCS" select="document('~/projects/RMIT/RMIT-Figshare-RIF-CS-Export_DemoFigshare.xml')"/-->
    <!--xsl:variable name="otherDatasourceRifCS" select="document('~/projects/UNE_Project/FromRDA/university-of-new-england-une-dspace-RIF-CS-Export_demo.xml')"/-->
    <!--xsl:variable name="otherDatasourceRifCS" select="document('~/projects/SouthernCrossUniversity/InProdNew/SCU-Esploro-RIF-CS-Export_ProductionPublishedCollections_360.xml')"/-->
    <!--xsl:variable name="otherDatasourceRifCS" select="document('~/projects/RMIT/RMIT-Redbox-RIF-CS-Export_ProdRedBox_PublishedCollections_Figshare_357.xml')"/-->
    <!--xsl:variable name="otherDatasourceRifCS" select="document('~/projects/ACU_Victoria/ACU_20202/CompareDemoProd/ACU_InProdRDA.xml')"/-->
    <xsl:variable name="otherDatasourceRifCS" select="document('~/projects/CQU_Project/CompareKeys/Central-Queensland-University-RIF-CS-Export_OldProd.xml')"/>
  
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="node()[ancestor::field and not(self::text())]">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="/">
       
        <xsl:text>location</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>key</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>class</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>originating_source</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>type</xsl:text><xsl:value-of select="$columnSeparator"/>
       <xsl:text>identifier_local</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>identifier_url</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>name</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>description_full</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>description_brief</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>electronic_url</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>doi</xsl:text><xsl:value-of select="$columnSeparator"/>
        
        <xsl:if test="$compareWithOtherDatasource = true()">
            <xsl:text>registry_match_name_if_exists</xsl:text><xsl:value-of select="$columnSeparator"/>
            <xsl:text>registry_match_key_if_exists</xsl:text><xsl:value-of select="$columnSeparator"/>
            <xsl:text>registry_match_url_if_exists</xsl:text><xsl:value-of select="$columnSeparator"/>
            <xsl:text>match_element_if_match_in_other_datasource_found</xsl:text><xsl:value-of select="$columnSeparator"/>
            <xsl:text>doi_other_datasource</xsl:text><xsl:value-of select="$columnSeparator"/>
        </xsl:if>
        
        <xsl:message select="concat('result: ', count(//registryObject[count(collection|service) > 0]))"></xsl:message>
        
        <xsl:apply-templates select="//registryObject[count(collection|service) > 0]"/>
    
    </xsl:template>
    
    
    <xsl:template match="registryObject">
       
        <xsl:text>&#xa;</xsl:text>
        
        <!--	column: location -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="concat('https://', $registry_address_input, '/view?key=', key)"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: key	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="key"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: class	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:choose>
            <xsl:when test="count(service) > 0">
                <xsl:text>service</xsl:text>
            </xsl:when>
            <xsl:when test="count(collection) > 0">
                <xsl:text>collection</xsl:text>
            </xsl:when>
            <xsl:when test="count(party) > 0">
                <xsl:text>party</xsl:text>
            </xsl:when>
            <xsl:when test="count(activity) > 0">
                <xsl:text>activity</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: type	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="originatingSource"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: originating_source	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="(collection|service|party|activity)/@type"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: identifier_local	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="*/identifier[@type = 'local']"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: identifier_uri	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="(collection|service|party|activity)/identifier[starts-with(lower-case(@type), 'ur')]"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: name	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="(collection|service|party|activity)/name/namePart"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: description full	(mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="(collection|service|party|activity)/description[@type='full']"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: description brief	(optional) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="(collection|service|party|activity)/description[@type='brief']"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <!--	column: electronic url (mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="(collection|service|party|activity)/location/address/electronic[lower-case(@type) = 'url']/value"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <xsl:variable name="doi">
            <xsl:choose>
                <xsl:when test="string-length((collection|service|party|activity)/identifier[lower-case(@type)='doi']) > 0">
                    <xsl:value-of select="(collection|service|party|activity)/identifier[lower-case(@type)='doi']"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="doiValue_Sequence" select="custom:getDOIFromString(normalize-space((collection|service|party|activity)/citationInfo/fullCitation))" as="xs:string*"/>
                    <xsl:if test="count($doiValue_Sequence) > 0">
                        <xsl:value-of select="$doiValue_Sequence[1]"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!--	column: doi-->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$doi"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <xsl:variable name="objectNamePart" select="(collection|service|party|activity)/name[contains(lower-case(@type), 'primary')]/namePart"/>
        
        <xsl:variable name="handlePostFixFromKey" select="substring-after(key, $keyPrefix)"/>
        <xsl:message select="concat('$handlePostFixFromKey ', $handlePostFixFromKey)"/>
        
        <xsl:variable name="doiPostFixFromKey" select="substring-after(key, 'doi.org/')"/>
        <xsl:variable name="doiPostFixFromDoi" select="substring-after($doi, 'doi.org/')"/>
        
        <xsl:variable name="handlePostFixFromHandle" select="substring-after((collection|service|party|activity)/identifier[lower-case(@type)='handle'], 'e-publications.une.edu.au/')"/>
        <xsl:message select="concat('$handlePostFixFromHandle ', $handlePostFixFromHandle)"/>
        
        
        <xsl:if test="$compareWithOtherDatasource = true()">
            <!--	column: other_datasource_url_if_exists (mandatory) -->
            <!-- Find record in other datasource that has matching name -->
           
            
            <xsl:choose>
                <xsl:when test="(string-length($doiPostFixFromKey) > 0) and count($otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($doiPostFixFromKey))]]/key) > 0">
                    <xsl:message select="concat('doi found: ', $doiPostFixFromKey)"/>
                    
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($doiPostFixFromKey))]]/(collection|service|party|activity)/name[contains(lower-case(@type), 'primary')]/namePart"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($doiPostFixFromKey))]]/key"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="concat('https://', $registry_address_other, '/view?key=', $otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($doiPostFixFromKey))]]/key)"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    
                    <xsl:text>&quot;</xsl:text>
                    <xsl:text>doi</xsl:text>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    <xsl:for-each select="($otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($doiPostFixFromKey))]])[1]">
                        <xsl:call-template name="here:populateOtherDatasourceDOI"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="(string-length($doiPostFixFromDoi) > 0) and count($otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($doiPostFixFromDoi))]]/key) > 0">
                    <xsl:message select="concat('doi found: ', $doiPostFixFromDoi)"/>
                   
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($doiPostFixFromDoi))]]/(collection|service|party|activity)/name[contains(lower-case(@type), 'primary')]/namePart"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($doiPostFixFromDoi))]]/key"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="concat('https://', $registry_address_other, '/view?key=', $otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($doiPostFixFromDoi))]]/key)"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    
                    <xsl:text>&quot;</xsl:text>
                    <xsl:text>doi</xsl:text>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    <xsl:for-each select="($otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($doiPostFixFromDoi))]])[1]">
                        <xsl:call-template name="here:populateOtherDatasourceDOI"/>
                    </xsl:for-each>
                </xsl:when>
                 <xsl:when test="(string-length($handlePostFixFromHandle) > 0) and count($otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($handlePostFixFromHandle))]]/key) > 0">
                    <xsl:message select="concat('handle found: ', $handlePostFixFromHandle)"/>
                    
                    <xsl:text>&quot;</xsl:text>
                     <xsl:value-of select="$otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($handlePostFixFromHandle))]]/(collection|service|party|activity)/name[contains(lower-case(@type), 'primary')]/namePart"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                     
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($handlePostFixFromHandle))]]/key"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                     
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="concat('https://', $registry_address_other, '/view?key=', $otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($handlePostFixFromHandle))]]/key)"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    
                     <xsl:text>&quot;</xsl:text>
                    <xsl:text>handle</xsl:text>
                     <xsl:text>&quot;</xsl:text>
                     <xsl:value-of select="$columnSeparator"/>
                     <xsl:for-each select="($otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($handlePostFixFromHandle))]])[1]">
                         <xsl:call-template name="here:populateOtherDatasourceDOI"/>
                     </xsl:for-each>
                 </xsl:when>
                <xsl:when test="(string-length($handlePostFixFromKey) > 0) and count($otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($handlePostFixFromKey))]]/key) > 0">
                    <xsl:message select="concat('handle found: ', $handlePostFixFromKey)"/>
                    
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($handlePostFixFromKey))]]/(collection|service|party|activity)/name[contains(lower-case(@type), 'primary')]/namePart"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($handlePostFixFromKey))]]/key"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="concat('https://', $registry_address_other, '/view?key=', $otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($handlePostFixFromKey))]]/key)"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    
                    <xsl:text>&quot;</xsl:text>
                    <xsl:text>handle</xsl:text>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    <xsl:for-each select="($otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($handlePostFixFromKey))]])[1]">
                        <xsl:call-template name="here:populateOtherDatasourceDOI"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="count($otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/name[lower-case(normalize-space(namePart)) = lower-case(normalize-space($objectNamePart))]]/key) > 0">
                    <xsl:message select="concat('Found ', count($otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/name[lower-case(normalize-space(namePart)) = lower-case(normalize-space($objectNamePart))]]/key), ' collection(s) from other datasource with name: ', $objectNamePart)"/>
                    
                    <xsl:text>&quot;</xsl:text>
                    <xsl:for-each select="$otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/name[lower-case(normalize-space(namePart)) = lower-case(normalize-space($objectNamePart))]]/(collection|service|party|activity)/name[contains(lower-case(@type), 'primary')]/namePart">
                        <xsl:value-of select="."/>
                    </xsl:for-each>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    
                    <xsl:text>&quot;</xsl:text>
                    <xsl:for-each select="$otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/name[lower-case(normalize-space(namePart)) = lower-case(normalize-space($objectNamePart))]]/key">
                        <xsl:value-of select="."/>
                    </xsl:for-each>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    
                    <xsl:text>&quot;</xsl:text>
                    <xsl:for-each select="$otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/name[lower-case(normalize-space(namePart)) = lower-case(normalize-space($objectNamePart))]]/key">
                        <xsl:value-of select="concat('https://', $registry_address_other, '/view?key=', ., ' ')"/>
                    </xsl:for-each>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    
                    <xsl:text>&quot;</xsl:text>
                    <xsl:text>namePart</xsl:text>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    <xsl:for-each select="($otherDatasourceRifCS/registryObjects/registryObject[(collection|service|party|activity)/name[lower-case(normalize-space(namePart)) = lower-case(normalize-space($objectNamePart))]])[1]">
                        <xsl:call-template name="here:populateOtherDatasourceDOI"/>
                    </xsl:for-each>
                    
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:message select="concat('No match found for: ', (collection|service|party|activity)/name/namePart)"/>
                </xsl:otherwise>
            </xsl:choose>
        
            
            
           
        </xsl:if>
         
    </xsl:template>
    
    <xsl:template name="here:populateOtherDatasourceDOI">
       
        <xsl:variable name="doiOtherDatasource">
            <xsl:choose>
                <xsl:when test="string-length(./(collection|service|party|activity)/identifier[lower-case(@type)='doi']) > 0">
                    <xsl:value-of select="./(collection|service|party|activity)/identifier[lower-case(@type)='doi']"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="doiValue_Sequence" select="custom:getDOIFromString(normalize-space(./(collection|service|party|activity)/citationInfo/fullCitation))" as="xs:string*"/>
                    <xsl:if test="count($doiValue_Sequence) > 0">
                        <xsl:value-of select="$doiValue_Sequence[1]"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:message select="concat('populateOtherDatasourceDOI: ', $doiOtherDatasource)"/>
        
        <!--	column: doi_otherDatasource -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$doiOtherDatasource"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
    </xsl:template>
    
</xsl:stylesheet>
