<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:murFunc="http://mur.nowhere.yet"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:xoai="http://www.lyncode.com/xoai"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://www.lyncode.com/xoai"
    exclude-result-prefixes="xoai oai oai_dc dc fn murFunc custom">
	
	
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'{requires override}'"/>
    <xsl:param name="global_group" select="'{requires override}'"/>
    <xsl:param name="global_acronym" select="'{requires override}'"/>
    <xsl:param name="global_publisherName" select="'{requires override}'"/>
    <xsl:param name="global_baseURI" select="'{requires override}'"/>
    <xsl:param name="global_path" select="'{requires override}'"/>
        
    <xsl:variable name="licenseCodelist" select="document('license-codelist.xml')"/>
    

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects 
            http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
          
            <xsl:message select="concat('name(oai:OAI-PMH): ', name(oai:OAI-PMH))"/>
            <xsl:apply-templates select="oai:OAI-PMH/*/oai:record"/>
            
        </registryObjects>
    </xsl:template>
    
  
    <xsl:template match="oai:OAI-PMH/*/oai:record">
        <xsl:message select="concat('name(.): ', name(.))"/>
        <xsl:message select="concat('name(.): ', name(oai:metadata/metadata))"/>
           <xsl:apply-templates select="oai:metadata/metadata" mode="collection"/>
            <!--  xsl:apply-templates select="oai:metadata/metadata/dc:funding" mode="funding_party"/-->
        <xsl:apply-templates select="oai:metadata/metadata/element[@name ='dc']/element[@name ='contributor']/element[(@name ='author') or (@name ='publisher')]" mode="party_person"/> 
        <xsl:apply-templates select="oai:metadata/metadata/element[@name ='local']/element[@name ='datasetcontact']/element[@name ='name']" mode="party_person"/> 
        <xsl:apply-templates select="oai:metadata/metadata/element[@name ='local']/element[@name ='datasetcustodian']/element[@name ='name']" mode="party_person"/> 
        
        <xsl:apply-templates select="oai:metadata/metadata/element[@name ='dc']/element[@name ='contributor']/element[@name ='corporate']" mode="party_group"/> 
    </xsl:template>
    
    <xsl:template match="metadata" mode="collection">
        <xsl:variable name="class" select="'collection'"/>
        
        <xsl:message select="concat('name(oai:element[@name=''dc'']): ', name(element[@name ='dc']))"/>
        
        <xsl:variable name="identifierBase">
            <xsl:choose>
                <xsl:when test="string-length(ancestor::oai:record/oai:header/oai:identifier) > 0">
                    <xsl:choose>
                        <xsl:when test="matches(ancestor::oai:record/oai:header/oai:identifier, '[\d]+')">
                            <xsl:analyze-string select="normalize-space(ancestor::oai:record/oai:header/oai:identifier)" regex="[\d]+">
                                <xsl:matching-substring>
                                    <xsl:value-of select="regex-group(0)"/>
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="normalize-space(ancestor::oai:record/oai:header/oai:identifier)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="fn:generate-id(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>   
        <xsl:variable name="numbersFromKey">
            
        </xsl:variable>
        
        <xsl:variable name="key" select="concat($global_acronym, custom:registryObjectKeyFromString($identifierBase))"/>
        <xsl:variable name="key" select="concat($identifierBase, ':', $identifierBase)"/>
        
        
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <key>
                <xsl:value-of select="$key"/>
            </key>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            <xsl:element name="{$class}">
                
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="boolean(custom:sequenceContains(element[@name ='dc']/element[@name ='type'], 'dataset')) = true()">
                            <xsl:value-of select="'dataset'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'collection'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
             
                <xsl:apply-templates select="@todo[string-length(.) > 0]" mode="collection_date_modified"/>
                
                <xsl:apply-templates select="element[@name ='dc']/element[@name ='date']/element[@name ='accessioned']" mode="collection_date_accessioned"/>
                
                <xsl:apply-templates select="element[@name ='dc']/element[@name ='date']/element[@name ='issued']" mode="collection_date_issued"/>
                
                <xsl:apply-templates select="element[@name ='dc']/element[@name ='date']/element[@name ='deposit']" mode="collection_date_deposit"/>
                
                <xsl:apply-templates select="element[@name ='dc']/element[@name ='relation']/element[@name='uri'][string-length(.) > 0]" mode="collection_relatedInfo_uri"/>
                
                <xsl:apply-templates select="element[@name ='local']/element[@name ='relation']/element[@name ='grantdescription'][string-length(.) > 0]" mode="collection_relatedInfo_grantid"/>
                
                <xsl:apply-templates select="element[@name ='local']/element[@name ='identifier']/element[@name='unepublicationid'][string-length(.) > 0]" mode="collection_identifier"/>
                
                <xsl:apply-templates select="element[@name ='local']/element[@name ='dcrelation']/element[@name='publication'][string-length(.) > 0]" mode="collection_description_notes_publicationTitle"/>
                
                <xsl:apply-templates select="element[@name ='local']/element[@name ='relation']/element[@name='fundingsourcenote'][string-length(.) > 0]" mode="collection_description_notes_fundingSource"/>
                
                <xsl:apply-templates select="element[@name ='dc']/element[@name ='identifier']/element[@name='uri'][string-length(.) > 0]" mode="collection_identifier"/>
                
                <xsl:apply-templates select="element[@name ='dc']/element[@name ='identifier']/element[@name='doi'][string-length(.) > 0]" mode="collection_identifier"/>
                
               <!-- if no doi, use handle as location -->
                <xsl:choose>
                    <xsl:when test="count(element[@name ='dc']/element[@name ='identifier']/element[@name='doi'][string-length(.) > 0]) = 0">
                        <xsl:apply-templates select="element[@name ='dc']/element[@name ='identifier']/element[@name='uri'][string-length(.) > 0]" mode="collection_location_uri"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="element[@name ='dc']/element[@name ='identifier']/element[@name='doi'][string-length(.) > 0]" mode="collection_location_doi"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                <!--xsl:apply-templates select="../../oai:header/oai:identifier[contains(.,'oai:eprints.utas.edu.au:')]" mode="collection_location_nodoi"/-->
                
                <xsl:apply-templates select="element[@name ='dc']/element[@name ='title'][string-length(.) > 0]" mode="collection_name"/>
                
                <!-- xsl:apply-templates select="dc:identifier.orcid" mode="collection_relatedInfo"/ -->
                
                <xsl:apply-templates select="element[@name ='dc']/element[@name ='contributor']/element[@name ='author'][string-length(.) > 0]" mode="collection_relatedObject"/>
                
                <xsl:apply-templates select="element[@name ='local']/element[@name ='datasetcontact']/element[@name ='name'][string-length(.) > 0]" mode="collection_relatedObject_isOwnedBy"/>
                
                <xsl:apply-templates select="element[@name ='local']/element[@name ='datasetcontact']/element[@name ='email'][string-length(.) > 0]" mode="collection_contact_email"/>
                
                <xsl:apply-templates select="element[@name ='local']/element[@name ='datasetcustodian']/element[@name ='name'][string-length(.) > 0]" mode="collection_relatedObject_isManagedBy"/>
                
                <xsl:apply-templates select="element[@name ='dc']/element[@name ='contributor']/element[@name ='corporate'][string-length(.) > 0]" mode="collection_relatedObject"/> 
               
                <xsl:apply-templates select="element[@name ='dc']/element[@name ='publisher'][string-length(.) > 0]" mode="collection_relatedObject"/>
                
                <xsl:apply-templates select="element[@name ='local']/element[@name ='subject'][string-length(.) > 0]" mode="collection_subject"/>
                
                <xsl:apply-templates select="element[@name ='dc']/element[@name ='coverage']/element[@name ='spatial'][string-length(.) > 0]" mode="collection_spatial_coverage"/>
                
                <xsl:apply-templates select="element[(@name ='local') or (@name ='dc') or (@name ='dcterms')]/element[@name ='rights'][string-length(.) > 0]" mode="collection_rights"/>
                
                <xsl:apply-templates select="element[(@name ='dcterms')]/element[lower-case(@name) ='rightsholder'][string-length(.) > 0]" mode="collection_rights"/>
                
                <xsl:apply-templates select="element[@name ='dcterms']/element[@name ='accessRights'][string-length(.) > 0]" mode="collection_rights_accessRights"/>
                
                <xsl:apply-templates select="element[@name ='dc']/element[@name ='description'][string-length(.) > 0]" mode="collection_description_full"/>
               
                <xsl:apply-templates select="element[@name ='dc']/element[@name ='coverage']/element[@name ='temporal'][string-length(.) > 0]" mode="collection_dates_coverage"/>
                
                <xsl:apply-templates select="." mode="collection_citation_information"/>
                
             
            </xsl:element>
        </registryObject>
    </xsl:template>
    
    <xsl:template match="metadata" mode="collection_citation_information">
        
        <citationInfo>
            <citationMetadata>
                <xsl:choose>
                    <xsl:when test="count(element[@name ='dc']/element[@name ='identifier']/element[@name='doi'][string-length(.) > 0]) > 0">
                        <xsl:for-each select="element[@name ='dc']/element[@name ='identifier']/element[@name='doi'][string-length(.) > 0]">
                            <identifier type="doi">
                                <xsl:value-of select="normalize-space(.)"/>
                            </identifier>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="count(element[@name ='dc']/element[@name ='identifier']/element[@name='uri'][string-length(.) > 0]) > 0">
                        <xsl:for-each select="element[@name ='dc']/element[@name ='identifier']/element[@name='uri'][string-length(.) > 0]">
                            <identifier type="uri">
                                <xsl:value-of select="normalize-space(.)"/>
                            </identifier>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="count(element[@name ='local']/element[@name ='identifier']/element[@name='unepublicationid'][string-length(.) > 0]) > 0">
                        <xsl:for-each select="element[@name ='local']/element[@name ='identifier']/element[@name='unepublicationid'][string-length(.) > 0]">
                            <identifier type="local">
                                <xsl:value-of select="normalize-space(.)"/>
                            </identifier>
                        </xsl:for-each>
                    </xsl:when>
                </xsl:choose>
                
                <xsl:for-each select="element[@name ='dc']/element[@name ='contributor']/element[@name ='author']/element/field[@name='value'][string-length(.) > 0]">
                    <xsl:variable name="nameValueSpaceSeparated" select="tokenize(murFunc:formatName(.), '\s')" as="xs:string*"/> 
                    <contributor seq="{position()}">
                        <xsl:choose>
                            <xsl:when test="count($nameValueSpaceSeparated) > 1">
                                <namePart type="family">
                                    <xsl:value-of select="$nameValueSpaceSeparated[count($nameValueSpaceSeparated)]"/>
                                </namePart>
                                <namePart type="given">
                                    <xsl:value-of select="$nameValueSpaceSeparated[1]"/>
                                </namePart>
                            </xsl:when>
                            <xsl:when test="count($nameValueSpaceSeparated) = 1">
                                <namePart type="family">
                                    <xsl:value-of select="$nameValueSpaceSeparated[1]"/>
                                </namePart>
                            </xsl:when>
                        </xsl:choose>
                    </contributor>
                </xsl:for-each>
                
                
                <xsl:for-each select="element[@name ='dc']/element[@name ='contributor']/element[@name ='corporate']/element/field[@name='value'][string-length(.) > 0]">
                    <contributor>
                        <namePart type="family">
                            <xsl:value-of select="."/>
                        </namePart>
                    </contributor>
                </xsl:for-each>
                
                
                <xsl:for-each select="element[@name ='dc']/element[@name ='title'][string-length(.) > 0]">
                    <title>
                        <xsl:value-of select="normalize-space(.)"/>
                    </title>
                </xsl:for-each>                
                    
                <!--version>@todo</version-->
                
                <xsl:for-each select="element[@name ='dc']/element[@name ='publisher'][string-length(.) > 0]">
                    <publisher>
                        <xsl:value-of select="normalize-space(.)"/>
                    </publisher>
                </xsl:for-each>
                
                <xsl:for-each select="element[@name ='dc']/element[@name ='date']/element[@name ='issued'][string-length(.) > 0]">
                    <date type="publicationDate">
                        <xsl:value-of select="normalize-space(.)"/>
                    </date>
                </xsl:for-each>
            </citationMetadata>
        </citationInfo>
    </xsl:template>
   
    
     <xsl:template match="@todo" mode="collection_date_modified">
        <xsl:attribute name="dateModified" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="element[@name ='accessioned']" mode="collection_date_accessioned">
        <xsl:for-each select="element/field[@name='value']">
            <xsl:attribute name="dateAccessioned" select="normalize-space(.)"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="element[@name ='issued']" mode="collection_date_issued">
        <xsl:for-each select="element/field[@name='value']">
            <dates type="dc.issued">
                <date type="dateFrom" dateFormat="W3CDTF">
                    <xsl:value-of select="."/>
                </date>
            </dates>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="element[@name ='deposit']" mode="collection_date_deposit">
        <xsl:for-each select="element/field[@name='value']">
            <dates type="dc.dateSubmitted">
                <date type="dateFrom" dateFormat="W3CDTF">
                    <xsl:value-of select="."/>
                </date>
            </dates>
        </xsl:for-each>
    </xsl:template>
       
    <xsl:template match="element[@name='unepublicationid']" mode="collection_identifier">
        <identifier type="{custom:getIdentifierType(.)}">
            <xsl:choose>
                <xsl:when test="starts-with(. , '10.')">
                    <xsl:value-of select="concat('http://doi.org/', .)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </identifier>    
    </xsl:template>
    
    <xsl:template match="element[@name='uri']" mode="collection_identifier">
        <identifier type="{custom:getIdentifierType(.)}">
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>    
    </xsl:template>
    
    <xsl:template match="element[@name='doi']" mode="collection_identifier">
        <identifier type="doi">
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>    
    </xsl:template>
    
    
    
    <xsl:template match="element" mode="collection_contact_email">
        <xsl:for-each select="element/field[@name='value']">
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
    
    <xsl:template match="element[@name='doi']" mode="collection_location_doi">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:choose>
                            <xsl:when test="starts-with(normalize-space(.), '10.')">
                                <xsl:value-of select="concat('http://doi.org/', normalize-space(.))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="element[@name='uri']" mode="collection_location_uri">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="normalize-space(.)"/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <!--xsl:template match="oai:identifier" mode="collection_location_nodoi">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="concat($global_baseURI, $global_path, '/', substring-after(.,'oai:eprints.utas.edu.au:'))"/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template-->
    
    <xsl:template match="element[@name ='title']" mode="collection_name">
        <name type="primary">
            <namePart>
                <xsl:value-of select="normalize-space(.)"/>
            </namePart>
        </name>
    </xsl:template>
    
    
   <xsl:template match="dc:identifier.orcid" mode="collection_relatedInfo">
        <xsl:message select="concat('vivo:orcidId : ', .)"/>
                            
        <relatedInfo type='party'>
            <identifier type="{custom:getIdentifierType(.)}">
                <xsl:value-of select="normalize-space(.)"/>
            </identifier>
            <relation type="hasCollector"/>
        </relatedInfo>
    </xsl:template>
    
    <xsl:template match="element[@name='uri']" mode="collection_relatedInfo_uri">
        <xsl:for-each select="element/field[@name='value']">
            <relatedInfo type='relatedInformation'>
               <identifier type="{custom:getIdentifierType(.)}">
                   <xsl:value-of select="normalize-space(.)"/>
               </identifier>
                <relation type="hasAssociationWith"/>
           </relatedInfo>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="element[@name='grantdescription']" mode="collection_relatedInfo_grantid">
        <xsl:for-each select="element/field[@name='value']">
            <relatedInfo type='activity'>
                <identifier type="{custom:getIdentifierType(.)}">
                    <xsl:choose>
                        <xsl:when test="starts-with(normalize-space(.), 'ARC/')">
                            <xsl:value-of select="substring-after(normalize-space(.), 'ARC/')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="normalize-space(.)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </identifier>
                <relation type="isOutputOf"/>
            </relatedInfo>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="element" mode="collection_relatedObject">
        <xsl:for-each select="element/field[@name='value']">
             <relatedObject>
                 <key>
                     <xsl:value-of select="murFunc:formatKey(murFunc:formatName(.))"/> 
                 </key>
                 <relation type="hasCollector"/>
             </relatedObject>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="element" mode="collection_relatedObject_isOwnedBy">
        <xsl:for-each select="element/field[@name='value']">
            <relatedObject>
                <key>
                    <xsl:value-of select="murFunc:formatKey(murFunc:formatName(.))"/> 
                </key>
                <relation type="isOwnedBy"/>
            </relatedObject>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="element" mode="collection_relatedObject_isManagedBy">
        <xsl:for-each select="element/field[@name='value']">
            <relatedObject>
                <key>
                    <xsl:value-of select="murFunc:formatKey(murFunc:formatName(.))"/> 
                </key>
                <relation type="isManagedBy"/>
            </relatedObject>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="element[@name ='publisher']" mode="collection_relatedObject">
        <xsl:for-each select="element/field[@name='value']">
            <relatedObject>
                <key>
                    <xsl:value-of select="murFunc:formatKey(murFunc:formatName(.))"/> 
                </key>
                <relation type="publisher"/>
            </relatedObject>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="element[@name ='subject']" mode="collection_subject">
        <xsl:for-each select="element[@name = 'for2008']/element[@name = 'en']/field[@name = 'value']">
            <subject type="anzsrc-for">
                <xsl:value-of select="normalize-space(.)"/>
            </subject>
        </xsl:for-each>
        
        <xsl:for-each select="element[@name = 'seo2008']/element[@name = 'en']/field[@name = 'value']">
            <subject type="anzsrc-seo">
                <xsl:value-of select="normalize-space(.)"/>
            </subject>
        </xsl:for-each>
        
        <xsl:for-each select="element[not(@name = 'seo2008') and not(@name = 'for2008')]/element[@name = 'en']/field[@name = 'value']">
            <subject type="local">
                <xsl:value-of select="normalize-space(.)"/>
            </subject>
        </xsl:for-each>
        
    </xsl:template>
   
    <xsl:template match="element[@name ='spatial']" mode="collection_spatial_coverage">
        <xsl:for-each select="element/field[@name='value']">
            
            <xsl:variable name="coordinate_sequence" as="xs:string*">
                <xsl:analyze-string select="normalize-space(.)" regex="[\d.-]+">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(0)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            
            <xsl:variable name="coordinate_sequence_notSwappedLatLongs" as="xs:string*">
                <xsl:for-each select="$coordinate_sequence">
                    <xsl:variable name="postInt" select="position()" as="xs:integer"/>
                    <xsl:if test="$postInt &lt; count($coordinate_sequence)">
                        <xsl:if test="($postInt mod 2) = 1">
                            <xsl:value-of select="concat(., ',', $coordinate_sequence[$postInt + 1])"/>
                            <!-- Swap below with above (uncomment below and comment above) if you need to swap lat long order (i.e. long lat instead)-->
                            <!--xsl:value-of select="concat($coordinate_sequence[$postInt + 1], ',', .)"/-->
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            
          <coverage>
              <xsl:choose>
                  <xsl:when test="contains(lower-case(.), 'northlimit')">
                      <spatial type="iso19139dcmiBox">
                          <xsl:value-of select='normalize-space(.)'/>   
                      </spatial>
                  </xsl:when>
                  <xsl:when test="count($coordinate_sequence) > 1">
                      
                      <xsl:variable name="coordinate_sequence_notSwappedLatLongs" as="xs:string*">
                          <xsl:for-each select="$coordinate_sequence">
                              <xsl:variable name="postInt" select="position()" as="xs:integer"/>
                              <xsl:if test="$postInt &lt; count($coordinate_sequence)">
                                  <xsl:if test="($postInt mod 2) = 1">
                                      <xsl:value-of select="concat(., ',', $coordinate_sequence[$postInt + 1])"/>
                                      <!-- Swap below with above (uncomment below and comment above) if you need to swap lat long order (i.e. long lat instead)-->
                                      <!--xsl:value-of select="concat($coordinate_sequence[$postInt + 1], ',', .)"/-->
                                  </xsl:if>
                              </xsl:if>
                          </xsl:for-each>
                      </xsl:variable>
                      <xsl:if test="count($coordinate_sequence_notSwappedLatLongs) > 0">
                          <spatial type="gmlKmlPolyCoords">
                            <xsl:value-of select="string-join($coordinate_sequence_notSwappedLatLongs, ' ')"/>     
                        </spatial>
                      </xsl:if>
                    </xsl:when>
                  <xsl:otherwise>
                      <spatial type="text">
                          <xsl:value-of select='normalize-space(.)'/>  
                      </spatial>
                  </xsl:otherwise>
              </xsl:choose>
          </coverage>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="element[lower-case(@name) ='rightsholder']" mode="collection_rights">
        <xsl:for-each select="element/field[@name='value']">
            <rights>
                <rightsStatement>
                    <xsl:value-of select="concat('Rights holder: ', normalize-space(.))"/>
                </rightsStatement>
            </rights>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="element[@name ='rights']" mode="collection_rights">
        <xsl:for-each select="element[lower-case(@name)='rightsholder']/element/field[@name='value']">
            <rights>
                <rightsStatement>
                    <xsl:value-of select="concat('Rights holder: ', normalize-space(.))"/>
                </rightsStatement>
            </rights>
        </xsl:for-each>
        <xsl:for-each select="element[@name='statement']/element/field[@name='value']">
            <rights>
                <rightsStatement>
                    <xsl:value-of select="normalize-space(.)"/>
                </rightsStatement>
            </rights>
        </xsl:for-each>
        
        <xsl:for-each select="element[@name='uri']/element[(@name='*') or (@name='en')]/field[@name='value']">
            <rights>
                <rightsStatement rightsUri="{normalize-space(.)}"/>
            </rights>
            
            <xsl:if test="string-length(murFunc:getLicenseTypeFromUri(normalize-space(.))) > 0">
                <rights>
                    <licence>
                        <xsl:attribute name="type">
                            <xsl:value-of select="murFunc:getLicenseTypeFromUri(normalize-space(.))"/>
                        </xsl:attribute>
                    </licence>
                </rights>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="element[@name ='accessRights']" mode="collection_rights_accessRights">
        <rights>
            <accessRights type="{lower-case(normalize-space(element[@name ='en']/field[@name ='value']))}">
                <xsl:value-of select="normalize-space(element[@name ='en']/field[@name ='value'])"/>
            </accessRights>
        </rights>
    </xsl:template>
   
    <xsl:function name="murFunc:getLicenseTypeFromUri" xs:as="xs:string">
        <xsl:param name="uri"/>
        
        <xsl:variable name="currentValueHttpNotHttps" select="normalize-space((replace($uri, 'https', 'http')))"/>
        
        <xsl:message select="concat('$currentValue: ', $currentValueHttpNotHttps)"/>
        <xsl:message select="concat('$currentValue no number: ', replace($currentValueHttpNotHttps, '\d.\d', ''))"/>
        
        <xsl:variable name="customIdentifier_sequence" as="xs:string*">
            <xsl:for-each select="$licenseCodelist/custom:CT_CodelistCatalogue/custom:codelistItem/custom:CodeListDictionary[(@custom:id='LicenseCodeAustralia')]/custom:codeEntry/custom:CodeDefinition">
                <xsl:message select="concat('remarks no {n}: ', normalize-space(replace(custom:remarks, '\{n\}', '')))"/>
                <xsl:if test="contains(replace($currentValueHttpNotHttps, '\d.\d', ''), normalize-space(replace(custom:remarks, '\{n\}', '')))">
                    <xsl:message select="'Match on remarks'"/>
                    <xsl:if test="string-length(custom:identifier) > 0">
                        <xsl:value-of select="custom:identifier"/>
                    </xsl:if>
                    <xsl:message select="concat('remarks: ', normalize-space(replace(custom:remarks, '\{n\}', '')))"/>
                </xsl:if> 
            </xsl:for-each>
            
            <xsl:for-each select="$licenseCodelist/custom:CT_CodelistCatalogue/custom:codelistItem/custom:CodeListDictionary[(@custom:id='LicenseCodeInternational')]/custom:codeEntry/custom:CodeDefinition">
                <xsl:message select="concat('remarks no {n}: ', normalize-space(replace(custom:remarks, '\{n\}', '')))"/>
                <xsl:if test="contains(replace($currentValueHttpNotHttps, '\d.\d', ''), normalize-space(replace(custom:remarks, '\{n\}', '')))">
                    <xsl:message select="concat('Match on remarks :', custom:remarks) "/>
                    <xsl:if test="string-length(custom:identifier) > 0">
                        <xsl:value-of select="custom:identifier"/>
                    </xsl:if>
                </xsl:if> 
            </xsl:for-each>
            
            <xsl:for-each select="$licenseCodelist/custom:CT_CodelistCatalogue/custom:codelistItem/custom:CodeListDictionary[(@custom:id='LicenseCodeAustralia')]/custom:codeEntry/custom:CodeDefinition">
                <xsl:message select="concat('current value no  -: ', translate($currentValueHttpNotHttps, ' ', '-'))"/>
                <xsl:message select="concat('custom:identifier: ', normalize-space(custom:identifier))"/>
                
                <xsl:if test="contains(normalize-space(custom:identifier), translate($currentValueHttpNotHttps, ' ', '-'))">
                    <xsl:message select="concat('Match on identifier :', custom:identifier) "/>
                    <xsl:if test="string-length(custom:identifier) > 0">
                        <xsl:value-of select="custom:identifier"/>
                    </xsl:if>
                </xsl:if> 
            </xsl:for-each>
            
            <xsl:for-each select="$licenseCodelist/custom:CT_CodelistCatalogue/custom:codelistItem/custom:CodeListDictionary[(@custom:id='LicenseCodeInternational')]/custom:codeEntry/custom:CodeDefinition">
                <xsl:message select="concat('current value no  -: ', translate($currentValueHttpNotHttps, ' ', '-'))"/>
                <xsl:message select="concat('custom:identifier: ', normalize-space(custom:identifier))"/>
                
                <xsl:if test="contains(normalize-space(custom:identifier), translate($currentValueHttpNotHttps, ' ', '-'))">
                    <xsl:message select="concat('Match on identifier :', custom:identifier) "/>
                    <xsl:if test="string-length(custom:identifier) > 0">
                        <xsl:value-of select="custom:identifier"/>
                    </xsl:if>
                </xsl:if> 
            </xsl:for-each>
            
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count($customIdentifier_sequence) > 0">
                <xsl:value-of select="$customIdentifier_sequence[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text></xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:template match="element[@name ='description']" mode="collection_description_full">
        <xsl:for-each select="element[@name='abstract']/element/field[@name='value'][string-length(.) > 0]">
            <description type="full">
                <xsl:value-of select="normalize-space(.)"/>
            </description>
        </xsl:for-each>
        <xsl:for-each select="element/field[@name='value'][string-length(.) > 0]">
            <description type="full">
                <xsl:value-of select="normalize-space(.)"/>
            </description>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="element[@name='publication']" mode="collection_description_notes_publicationTitle">
        <xsl:if test="count(element/field[@name='value'][string-length(.) > 0]) > 0">
            <description type="note">
                <xsl:text>&lt;b&gt;Related Publications&lt;/b&gt;</xsl:text>
                <xsl:for-each select="element/field[@name='value'][string-length(.) > 0]">
                    <xsl:text>&lt;br/&gt;</xsl:text>
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:for-each>
            </description>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="element[@name='fundingsourcenote']" mode="collection_description_notes_fundingSource">
        <xsl:if test="count(element/field[@name='value'][string-length(.) > 0]) > 0">
                <description type="note">
                    <xsl:text>&lt;b&gt;Funding Source&lt;/b&gt;</xsl:text>
                    <xsl:for-each select="element/field[@name='value'][string-length(.) > 0]">
                        <xsl:text>&lt;br/&gt;</xsl:text>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:for-each>
                </description>
        </xsl:if>
    </xsl:template>
    
    
    
    <xsl:template match="element[@name ='temporal']" mode="collection_dates_coverage">
        <coverage>
            <temporal>
                <text>
                    <xsl:value-of select="normalize-space(.)"/>
                </text>
            </temporal>
        </coverage>
    </xsl:template>  
    
    <!--xsl:template match="dc:source" mode="collection_citation_info">
        <citationInfo>
           <fullCitation>
                <xsl:value-of select="normalize-space(.)"/>
            </fullCitation>
        </citationInfo>
    </xsl:template-->  
             
     <xsl:template match="element" mode="party_person">
        
         <!--xsl:for-each select="element[@name ='dc']/element[@name ='contributor']/element[(@name ='author') or (@name ='publisher')]"-->
            
             <xsl:for-each select="element/field[@name='value']">
                <xsl:variable name="name" select="normalize-space(.)"/>
                
                <xsl:if test="(string-length(.) > 0)">
                
                       <xsl:if test="string-length(normalize-space(.)) > 0">
                         <registryObject group="{$global_group}">
                            <key>
                                <xsl:value-of select="murFunc:formatKey(murFunc:formatName(.))"/> 
                            </key>
                            <originatingSource>
                                 <xsl:value-of select="$global_originatingSource"/>
                            </originatingSource>
                            
                             <party>
                                <xsl:attribute name="type" select="'person'"/>
                                 
                                 <name type="primary">
                                     <namePart>
                                         <xsl:value-of select="murFunc:formatName(normalize-space(.))"/>
                                     </namePart>   
                                 </name>
                             </party>
                         </registryObject>
                       </xsl:if>
                    </xsl:if>
                </xsl:for-each>
         <!--/xsl:for-each-->
        </xsl:template>
    
    <xsl:template match="element" mode="party_group">
        
        <xsl:for-each select="element/field[@name='value']">
            <xsl:variable name="name" select="normalize-space(.)"/>
            
            <xsl:if test="(string-length(.) > 0)">
                
                <xsl:if test="string-length(normalize-space(.)) > 0">
                    <registryObject group="{$global_group}">
                        <key>
                            <xsl:value-of select="murFunc:formatKey(murFunc:formatName(.))"/> 
                        </key>
                        <originatingSource>
                            <xsl:value-of select="$global_originatingSource"/>
                        </originatingSource>
                        
                        <party>
                            <xsl:attribute name="type" select="'group'"/>
                            
                            <name type="primary">
                                <namePart>
                                    <xsl:value-of select="murFunc:formatName(normalize-space(.))"/>
                                </namePart>   
                            </name>
                        </party>
                    </registryObject>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
                   
    <xsl:function name="murFunc:formatName">
        <xsl:param name="name"/>
        
        <xsl:message select="concat('formatName input: ', $name)"/>
        
        <xsl:variable name="namePart_sequence" as="xs:string*">
            <xsl:analyze-string select="$name" regex="[A-Za-zÀ-ÿ()-]+">
                <xsl:matching-substring>
                    <xsl:if test="regex-group(0) != '-'">
                        <xsl:value-of select="regex-group(0)"/>
                    </xsl:if>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count($namePart_sequence) = 0">
                <xsl:value-of select="$name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="orderedNamePart_sequence" as="xs:string*">
                    <!--  we are going to presume that we have surnames first - otherwise, it's not possible to determine by being
                            prior to a comma because we get:  "surname, firstname, 1924-" sort of thing -->
                    <!-- all names except surname -->
                    <xsl:for-each select="$namePart_sequence">
                        <xsl:if test="position() > 1">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:value-of select="$namePart_sequence[1]"/>
                </xsl:variable>
                <xsl:message select="concat('formatName returning: ', string-join(for $i in $orderedNamePart_sequence return $i, ' '))"/>
                <xsl:value-of select="string-join(for $i in $orderedNamePart_sequence return $i, ' ')"/>
    
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="murFunc:formatKey">
        <xsl:param name="input"/>
        <xsl:variable name="raw" select="translate(normalize-space($input), ' ', '')"/>
        <xsl:variable name="temp">
            <xsl:choose>
                <xsl:when test="substring($raw, string-length($raw), 1) = '.'">
                    <xsl:value-of select="substring($raw, 0, string-length($raw))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$raw"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($global_acronym, '/', $temp)"/>
    </xsl:function>
    
</xsl:stylesheet>
    
