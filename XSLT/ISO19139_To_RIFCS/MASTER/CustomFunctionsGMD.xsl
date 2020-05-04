<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:customGMD="http://customGMD.nowhere.yet"
    exclude-result-prefixes="customGMD">
    <xsl:import href="CustomFunctions.xsl"/>
    
    
     <xsl:function name="customGMD:originatingSourceOrganisationFromURL" as="xs:string*">
         <xsl:param name="url" as="xs:string"/>
        
           <xsl:choose>
            <!-- Note that we may have metadata point of truth containing 'eatlas' while originating source is AIMS.
                 In such a case, we want the eatlas crosswalk to be called, hence placing the test for 'eatlas'
                 in metadata point of truth above the test for 'aims' in originating source -->
             <xsl:when test="
                 contains($url, 'eatlas.org')">
                <xsl:text>eAtlas</xsl:text>
             </xsl:when>
             <xsl:when test="
                 contains($url, 'metoc.gov')">
                <xsl:text>Navy METOC (Meteorology and Oceanography)</xsl:text>
             </xsl:when>
             <xsl:when test="
                 contains($url, 'niwa.co.nz')">
                <xsl:text>National Institute of Water and Atmospheric Research (NIWA)</xsl:text>
             </xsl:when>
             <xsl:when test="
                 contains($url, 'ga.gov')">
                <xsl:text>Commonwealth of Australia (Geoscience Australia)</xsl:text>
             </xsl:when>
             <xsl:when test="
                 contains($url, 'imas.utas')">
                 <xsl:text>Institute of Marine Science, University of Tasmania</xsl:text>
             </xsl:when>
             <xsl:when test="
                 contains($url, 'imosmest.aodn') or
                 contains($url, 'imos.aodn')">
                 <xsl:text>Integrated Marine Observing System</xsl:text>
             </xsl:when>
             <xsl:when test="
                 contains($url, 'ivec.org') or
                 contains($url, 'pawsey.org')">
                 <xsl:text>Pawsey Super Computing Centre, University of Western Australia</xsl:text>
             </xsl:when>
             <xsl:when test="
                 contains($url, 'data.aims')">
                 <xsl:text>Australian Institute of Marine Science</xsl:text>
             </xsl:when>
             <xsl:when test="
                 contains($url, 'aodn.org')">
                 <xsl:text>Australian Ocean Data Network</xsl:text>
             </xsl:when>
             <xsl:when test="
                 contains($url, 'csiro.au')">
                 <xsl:text>CSIRO</xsl:text>
             </xsl:when>
             <xsl:when test="
                 contains($url, 'aad')">
                 <xsl:text>Australian Antarctic Division</xsl:text>
             </xsl:when>
        </xsl:choose>
     </xsl:function>
        
        
    <xsl:function name="customGMD:originatingSourceURL" as="xs:string">
        <xsl:param name="MD_Metadata" as="node()"/>
        
        <xsl:variable name="metadataPointOfTruth_sequence" select="$MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage[contains(lower-case(following-sibling::gmd:protocol/gco:CharacterString), 'metadata-url')]/gmd:URL[string-length(.) > 0]" as="xs:string*"/>
        
        <xsl:variable name="originatingSourceURL_sequence" as="xs:string*">
             <xsl:for-each select="distinct-values($metadataPointOfTruth_sequence)">
                 <xsl:if test="string-length(custom:getDomainFromURL(.)) > 0">
                     <xsl:value-of select="custom:getDomainFromURL(.)"/>
                 </xsl:if>
             </xsl:for-each>
             <xsl:for-each select="$MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL[string-length(.) > 0]">
                 <xsl:if test="string-length(custom:getDomainFromURL(.)) > 0">
                     <xsl:value-of select="custom:getDomainFromURL(.)"/>
                 </xsl:if>
             </xsl:for-each>
            <xsl:for-each select="$MD_Metadata/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL[string-length(.) > 0]">
                <xsl:if test="string-length(custom:getDomainFromURL(.)) > 0">
                    <xsl:value-of select="custom:getDomainFromURL(.)"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
         <xsl:when test="count($originatingSourceURL_sequence) > 0">
             <xsl:copy-of select="$originatingSourceURL_sequence[1]"/>
         </xsl:when>
         <xsl:otherwise>
             <xsl:text></xsl:text>
         </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
      
   
     <xsl:function name="customGMD:originatingSourceOrganisation" as="xs:string">
        <xsl:param name="MD_Metadata" as="node()"/>
        
        
        
         <xsl:variable name="originatingSourceURL" select="customGMD:originatingSourceURL($MD_Metadata)"/>
         
         <xsl:variable name="originatingSourceOrgFromURL_sequence" select="customGMD:originatingSourceOrganisationFromURL($originatingSourceURL)"/>
         
        <xsl:choose>
            
            <xsl:when test=" (count($originatingSourceOrgFromURL_sequence) > 0) and (string-length($originatingSourceOrgFromURL_sequence[1]) > 0)">
                <xsl:value-of select="$originatingSourceOrgFromURL_sequence[1]"/>
            </xsl:when>
           <xsl:otherwise>
                <xsl:variable name="originatingSourceOrgansationFromParties" select="customGMD:originatingSourceOrganisationFromParties($MD_Metadata)"/>
                <xsl:value-of select="$originatingSourceOrgansationFromParties"/>
            </xsl:otherwise>
            
         </xsl:choose>
            
    </xsl:function>
        
        
   <xsl:function name="customGMD:originatingSourceOrganisationFromParties" as="xs:string">
        <xsl:param name="MD_Metadata" as="node()"/>
        
          <xsl:variable name="originator_sequence" as="node()*" select="
                $MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'originator'] |
                $MD_Metadata/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'originator')] |
                $MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'originator'] |
                $MD_Metadata/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'originator']"/>
            
            <xsl:variable name="author_sequence" as="node()*" select="
                $MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'author'] |
                $MD_Metadata/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'author')] |
                $MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'author'] |
                $MD_Metadata/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'author']"/>
            
            <xsl:variable name="creator_sequence" as="node()*" select="
                $MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'creator'] |
                $MD_Metadata/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[(lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'creator')] |
                $MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'creator'] |
                $MD_Metadata/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'creator']"/>
            
            <xsl:variable name="resourceProvider_sequence" as="node()*" select="
                $MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'resourceprovider'] |
                $MD_Metadata/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'resourceprovider'] |
                $MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'resourceprovider'] |
                $MD_Metadata/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'resourceprovider']"/>
            
            <xsl:variable name="owner_sequence" as="node()*" select="
                $MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'owner'] |
                $MD_Metadata/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'owner'] |
                $MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'owner'] |
                $MD_Metadata/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'owner']"/>
            
            <xsl:variable name="custodian_sequence" as="node()*" select="
                $MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'custodian'] |
                $MD_Metadata/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'custodian'] |
                $MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'custodian'] |
                $MD_Metadata/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue) = 'custodian']"/>
            
            <xsl:variable name="pointOfContact_sequence" as="node()*" select="
                $MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty[contains(lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue), 'contact')] |
                $MD_Metadata/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[contains(lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue), 'contact')] |
                $MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty[contains(lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue), 'contact')] |
                $MD_Metadata/gmd:identificationInfo/*[contains(lower-case(name()),'identification')]/gmd:pointOfContact/gmd:CI_ResponsibleParty[contains(lower-case(gmd:role/gmd:CI_RoleCode/@codeListValue), 'contact')]"/>
            
            
            <xsl:variable name="contact_sequence" as="node()*" select="
                $MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty"/>
            
            <xsl:choose>
                <xsl:when test="(count($originator_sequence) > 0) and string-length($originator_sequence[1]/gmd:organisationName) > 0">
                    <xsl:value-of select="$originator_sequence[1]/gmd:organisationName"/>
                </xsl:when>
                <xsl:when test="(count($author_sequence) > 0) and string-length($author_sequence[1]/gmd:organisationName) > 0">
                    <xsl:value-of select="$author_sequence[1]/gmd:organisationName"/>
                </xsl:when>
                <xsl:when test="(count($creator_sequence) > 0) and string-length($creator_sequence[1]/gmd:organisationName) > 0">
                    <xsl:value-of select="$creator_sequence[1]/gmd:organisationName"/>
                </xsl:when>
                <xsl:when test="(count($resourceProvider_sequence) > 0) and string-length($resourceProvider_sequence[1]/gmd:organisationName) > 0">
                    <xsl:value-of select="$resourceProvider_sequence[1]/gmd:organisationName"/>
                </xsl:when>
                <xsl:when test="(count($owner_sequence) > 0) and string-length($owner_sequence[1]/gmd:organisationName) > 0">
                    <xsl:value-of select="$owner_sequence[1]/gmd:organisationName"/>
                </xsl:when>
                <xsl:when test="(count($custodian_sequence) > 0) and string-length($custodian_sequence[1]/gmd:organisationName) > 0">
                    <xsl:value-of select="$custodian_sequence[1]/gmd:organisationName"/>
                </xsl:when>
                <xsl:when test="(count($pointOfContact_sequence) > 0) and string-length($pointOfContact_sequence[1]/gmd:organisationName) > 0">
                    <xsl:value-of select="$pointOfContact_sequence[1]/gmd:organisationName"/>
                </xsl:when>
                <xsl:when test="(count($contact_sequence) > 0) and string-length($contact_sequence[1]/gmd:organisationName) > 0">
                    <xsl:value-of select="$contact_sequence[1]/gmd:organisationName"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
              </xsl:choose>
              
    </xsl:function>
    
    <xsl:function name="customGMD:replaceOWS_specificProtocol">
        <xsl:param name="url"/>
        <xsl:param name="protocol"/>
        
        <!-- The following is case insensitive - replaces 'ows' with specific protocol, so that:
                    http://geoserver.domain.org.au/geoserver/OWS?request=GetCapabilities&service=WxS
             is replaced by:
                    http://geoserver.domain.org.au/geoserver/WxS?request=GetCapabilities&service=WxS
        -->
        <xsl:choose>
            <xsl:when test="matches($url,'OWS')">
                <xsl:value-of select="replace($url, 'OWS', upper-case($protocol), 'i')"/>
            </xsl:when>
            <xsl:when test="matches($url,'ows')">
                <xsl:value-of select="replace($url, 'ows', lower-case($protocol), 'i')"/>
            </xsl:when>
            <xsl:when test="matches($url,'ows', 'i')"> <!-- for combination case -->
                <xsl:value-of select="replace($url, 'ows', upper-case($protocol), 'i')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$url"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="customGMD:extractSpecific_OWS_protocol_maintainCase">
        <xsl:param name="protocol"/>
        
        <xsl:if test="contains(lower-case($protocol),'ogc:')">
            
            <xsl:variable name="indexAfterOGC" select="string-length(substring-before(lower-case($protocol), 'ogc:')) + string-length('ogc:')" as="xs:integer"/>
            <xsl:message select="concat('protocol : ', $protocol)"/>
            <xsl:message select="concat('index after ''ogc'' : ', $indexAfterOGC)"/>
            <xsl:variable name="protocolAfter_ogc" select="substring($protocol, ($indexAfterOGC + 1), string-length($protocol))"/>
            <xsl:message select="concat('protocolAfter ogc : ', $protocolAfter_ogc)"/>
            <xsl:choose>
                <xsl:when test="contains($protocolAfter_ogc,'-')">
                    <xsl:value-of select="substring-before($protocolAfter_ogc, '-')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <!-- If contains non alpha characters, take all alpha before the non-alpha -->
                        <xsl:when test="matches($protocolAfter_ogc,'[^A-Za-z]')">
                            <xsl:value-of select="tokenize($protocolAfter_ogc, '[^A-Za-z]')[1]"/>
                        </xsl:when>
                        <!-- Does not contain non alpha, so if contains alpha, return this value -->
                        <xsl:otherwise>
                            <xsl:if test="matches($protocolAfter_ogc,'[A-Za-z]')">
                                <xsl:value-of select="$protocolAfter_ogc"/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
</xsl:stylesheet>
