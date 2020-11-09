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
    
    <xsl:param name="compareWithDemo" select="true()"/>
    <!-- change the following the the correct demo content for the contributor that you are working with and set $compareWithDemo to true()-->
    <!--xsl:variable name="demoRifCs" select="document('/home/ada168/projects/UniversityOfCanberra/PURE-at-University-of-Canberra-RIF-CS-Export_demo_Collections.xml')"/-->
    <!--xsl:variable name="demoRifCs" select="document('/home/ada168/projects/RMIT/RMIT-Figshare-RIF-CS-Export_DemoFigshare.xml')"/-->
    <!--xsl:variable name="demoRifCs" select="document('/home/ada168/projects/UNE_Project/FromRDA/university-of-new-england-une-dspace-RIF-CS-Export_demo.xml')"/-->
    <xsl:variable name="demoRifCs" select="document('file:/home/ada168/projects/SouthernCrossUniversity/InDemoNew/Southern-Cross-University-Esploro-RIF-CS-Export_DEMO_Esploro_616.xml')"/>
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
        <xsl:text>electronic_url</xsl:text><xsl:value-of select="$columnSeparator"/>
        <xsl:text>doi_prod</xsl:text><xsl:value-of select="$columnSeparator"/>
        
        <xsl:if test="$compareWithDemo = true()">
            <xsl:text>demo_url_if_exists(matching title, handle or doi)</xsl:text><xsl:value-of select="$columnSeparator"/>
            <xsl:text>match_element_if_demo_match_found</xsl:text><xsl:value-of select="$columnSeparator"/>
            <xsl:text>doi_demo</xsl:text><xsl:value-of select="$columnSeparator"/>
        </xsl:if>
        
        <xsl:message select="concat('result: ', count(//registryObject[count(collection|service) > 0]))"></xsl:message>
        
        <xsl:apply-templates select="//registryObject[count(collection|service) > 0]"/>
    
    </xsl:template>
    
    
    <xsl:template match="registryObject">
       
        <xsl:text>&#xa;</xsl:text>
        
        <!--	column: location -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="concat('https://researchdata.ands.org.au/view?key=', key)"/>
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
        
        <!--	column: electronic url (mandatory) -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="(collection|service|party|activity)/location/address/electronic[lower-case(@type) = 'url']/value"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <xsl:variable name="doi_prod">
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
        
        <!--	column: doi_prod-->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$doi_prod"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <xsl:variable name="objectNamePart" select="(collection|service|party|activity)/name[contains(lower-case(@type), 'primary')]/namePart"/>
        
        <xsl:variable name="handlePostFixFromKey" select="substring-after(key, $keyPrefix)"/>
        <xsl:message select="concat('$handlePostFixFromKey ', $handlePostFixFromKey)"/>
        
        <xsl:variable name="doiPostFixFromKey" select="substring-after(key, 'doi.org/')"/>
        <xsl:variable name="doiPostFixFromDoi" select="substring-after($doi_prod, 'doi.org/')"/>
        
        <xsl:variable name="handlePostFixFromHandle" select="substring-after((collection|service|party|activity)/identifier[lower-case(@type)='handle'], 'e-publications.une.edu.au/')"/>
        <xsl:message select="concat('$handlePostFixFromHandle ', $handlePostFixFromHandle)"/>
        
        
        <xsl:if test="$compareWithDemo = true()">
            <!--	column: demo_url_if_exists (mandatory) -->
            <!-- Find record in demo that has matching name -->
           
            
            <xsl:choose>
                <xsl:when test="count($demoRifCs/registryObjects/registryObject[(collection|service|party|activity)/name[contains(lower-case(namePart), lower-case($objectNamePart))]]/key) > 0">
                    <xsl:message select="concat('Found ', count($demoRifCs/registryObjects/registryObject[(collection|service|party|activity)/name[contains(lower-case(namePart), lower-case($objectNamePart))]]/key), ' collection(s) from demo with name: ', $objectNamePart)"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:for-each select="$demoRifCs/registryObjects/registryObject[(collection|service|party|activity)/name[contains(lower-case(namePart), lower-case($objectNamePart))]]/key">
                        <xsl:value-of select="concat('https://demo.ands.org.au/view?key=', ., ' ')"/>
                    </xsl:for-each>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:text>namePart</xsl:text>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    <xsl:for-each select="($demoRifCs/registryObjects/registryObject[(collection|service|party|activity)/name[contains(lower-case(namePart), lower-case($objectNamePart))]])[1]">
                     <xsl:call-template name="here:populateDemoDOI"/>
                    </xsl:for-each>
                       
                </xsl:when>
                <xsl:when test="(string-length($handlePostFixFromKey) > 0) and count($demoRifCs/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($handlePostFixFromKey))]]/key) > 0">
                    <xsl:message select="concat('handle found: ', $handlePostFixFromKey)"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="concat('https://demo.ands.org.au/view?key=', $demoRifCs/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($handlePostFixFromKey))]]/key)"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:text>handle</xsl:text>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    <xsl:for-each select="($demoRifCs/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($handlePostFixFromKey))]])[1]">
                        <xsl:call-template name="here:populateDemoDOI"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="(string-length($doiPostFixFromKey) > 0) and count($demoRifCs/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($doiPostFixFromKey))]]/key) > 0">
                    <xsl:message select="concat('doi found: ', $doiPostFixFromKey)"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="concat('https://demo.ands.org.au/view?key=', $demoRifCs/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($doiPostFixFromKey))]]/key)"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:text>doi</xsl:text>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    <xsl:for-each select="($demoRifCs/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($doiPostFixFromKey))]])[1]">
                        <xsl:call-template name="here:populateDemoDOI"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="(string-length($doiPostFixFromDoi) > 0) and count($demoRifCs/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($doiPostFixFromDoi))]]/key) > 0">
                    <xsl:message select="concat('doi found: ', $doiPostFixFromDoi)"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="concat('https://demo.ands.org.au/view?key=', $demoRifCs/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($doiPostFixFromDoi))]]/key)"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:text>doi</xsl:text>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    <xsl:for-each select="($demoRifCs/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($doiPostFixFromDoi))]])[1]">
                        <xsl:call-template name="here:populateDemoDOI"/>
                    </xsl:for-each>
                </xsl:when>
                 <xsl:when test="(string-length($handlePostFixFromHandle) > 0) and count($demoRifCs/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($handlePostFixFromHandle))]]/key) > 0">
                    <xsl:message select="concat('handle found: ', $handlePostFixFromHandle)"/>
                     <xsl:text>&quot;</xsl:text>
                     <xsl:value-of select="concat('https://demo.ands.org.au/view?key=', $demoRifCs/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($handlePostFixFromHandle))]]/key)"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:value-of select="$columnSeparator"/>
                    <xsl:text>&quot;</xsl:text>
                    <xsl:text>handle</xsl:text>
                     <xsl:text>&quot;</xsl:text>
                     <xsl:value-of select="$columnSeparator"/>
                     <xsl:for-each select="($demoRifCs/registryObjects/registryObject[(collection|service|party|activity)/identifier[contains(lower-case(.), lower-case($handlePostFixFromHandle))]])[1]">
                         <xsl:call-template name="here:populateDemoDOI"/>
                     </xsl:for-each>
                 </xsl:when>
                <xsl:otherwise>
                    <xsl:message select="concat('No match found for: ', (collection|service|party|activity)/name/namePart)"/>
                </xsl:otherwise>
            </xsl:choose>
        
            
            
           
        </xsl:if>
         
    </xsl:template>
    
    <xsl:template name="here:populateDemoDOI">
       
        <xsl:variable name="doiDemo">
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
        
        <xsl:message select="concat('populateDemoDOI: ', $doiDemo)"/>
        
        <!--	column: doi_demo -->
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$doiDemo"/>
        <xsl:text>&quot;</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
    </xsl:template>
    
</xsl:stylesheet>
