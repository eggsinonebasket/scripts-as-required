<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:murFunc="http://mur.nowhere.yet"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:datacite="http://datacite.org/schema/kernel-4"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:oaire="http://namespace.openaire.eu/schema/oaire/"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xsl murFunc custom dc oai oaire fn xs xsi">
	
	
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="''"/>
    <xsl:param name="global_group" select="''"/>
    <xsl:param name="global_acronym" select="''"/>
    <xsl:param name="global_publisherName" select="''"/>
    <xsl:param name="global_rightsStatement" select="''"/>
    <!--xsl:param name="global_baseURI" select="''"/-->
    <!--xsl:param name="global_path" select="''"/-->
      
   <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects 
            http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
          
            <xsl:message select="concat('name(oai:OAI-PMH): ', name(oai:OAI-PMH))"/>
            <xsl:apply-templates select="//oai:record"/>
            
        </registryObjects>
    </xsl:template>
    
  
    <xsl:template match="oai:record">
        <xsl:apply-templates select="oai:metadata/oaire:resource" mode="collection"/>
        <!--  xsl:apply-templates select="oai:metadata/oaire:resource/dc:funding" mode="funding_party"/-->
        <xsl:apply-templates select="oai:metadata/oaire:resource" mode="party"/> 
     </xsl:template>
    
    <xsl:template match="oaire:resource"  mode="collection">
        
        <xsl:variable name="class" select="'collection'"/>
        
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <xsl:apply-templates select="ancestor::oai:record/oai:header/oai:identifier" mode="collection_key"/>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            <xsl:element name="{$class}">
                
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="boolean(custom:sequenceContains(oaire:resourceType, 'dataset')) = true()">
                            <xsl:value-of select="'dataset'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'collection'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
             
                <xsl:apply-templates select="@todo[string-length(.) > 0]" mode="collection_date_modified"/>
                
                <xsl:apply-templates select="ancestor::oai:record/oai:header/oai:datestamp" mode="collection_date_accessioned"/>
                
                <xsl:apply-templates select="datacite:identifier" mode="identifier"/>
                
                <xsl:apply-templates select="datacite:alternateIdentifier" mode="identifier"/>
                
                <xsl:apply-templates select="datacite:identifier[(@identifierType = 'DOI') and (string-length(.) > 0)]" mode="collection_location_doi"/>
                
                <!-- if no doi, use url as location -->
                <xsl:if test="count(datacite:identifier[(@identifierType = 'DOI') and (string-length(.) > 0)]) = 0">
                    <xsl:apply-templates select="datacite:alternateIdentifier[(@identifierType = 'URL') and (string-length(.) > 0)[1]]" mode="collection_location_url"/>
                </xsl:if>
                
                <!--xsl:apply-templates select="../../oai:header/oai:identifier[contains(.,'oai:eprints.utas.edu.au:')]" mode="collection_location_nodoi"/-->
                
                <xsl:apply-templates select="datacite:title[string-length(.) > 0]" mode="collection_name"/>
                
                
                <!--xsl:apply-templates select="dc:identifier[not(@*) or not(string-length(@*))][1]" mode="collection_relatedObject"/-->
                
                <!--xsl:apply-templates select="dc:identifier[@xsi:type ='dcterms:URI']" mode="collection_location_if_no_DOI"/-->
                
                <xsl:apply-templates select="datacite:creators/datacite:creator[string-length(.) > 0]" mode="collection_relatedObject"/>
               
                <xsl:apply-templates select="datacite:contributors/datacite:contributor[string-length(.) > 0]" mode="collection_relatedObject"/>
                
                <xsl:apply-templates select="datacite:subject" mode="collection_subject"/>
                
                <xsl:apply-templates select="datacite:dates/datacite:date[string-length(.) > 0]" mode="collection_dates_date"/>
                
                <!--xsl:apply-templates select="dc:coverage[string-length(.) > 0]" mode="collection_spatial_coverage"/-->
                
                <xsl:apply-templates select="datacite:rights[string-length(.) > 0]" mode="collection_rights"/>
                
                <xsl:call-template name="rightsStatement"/>
                
                <xsl:choose>
                    <xsl:when test="count(dc:description[string-length(.) > 0]) > 0">
                        <xsl:apply-templates select="dc:description[string-length(.) > 0]" mode="collection_description_full"/>
                    </xsl:when>
                    <xsl:when test="count(datacite:title[string-length(.) > 0]) > 0">
                        <xsl:apply-templates select="datacite:title[string-length(.) > 0]" mode="collection_description_brief"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="collection_description_default"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:apply-templates select="." mode="collection_citationInfo_citationMetadata"/>
                
            </xsl:element>
        </registryObject>
    </xsl:template>
    
    <xsl:template match="oai:identifier" mode="collection_key">
        <key>
            <xsl:value-of select="substring(string-join(for $n in fn:reverse(fn:string-to-codepoints(.)) return string($n), ''), 0, 50)"/>
        </key>
    </xsl:template>
   
    
    <xsl:template match="@todo" mode="collection_date_modified">
        <xsl:attribute name="dateModified" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="oai:datestamp" mode="collection_date_accessioned">
        <xsl:attribute name="dateAccessioned" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="datacite:identifier | datacite:alternateIdentifier" mode="identifier">
        <identifier>
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="lower-case(@identifierType) = 'doi'">
                        <xsl:text>doi</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="custom:getIdentifierType(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="normalize-space(.)"/>
        </identifier>    
    </xsl:template>
    
    <xsl:template match="datacite:identifier" mode="collection_identifier_maybe_not_doi">
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
    
    <!--xsl:template match="dc:identifier[@xsi:type ='dcterms:URI']" mode="collection_location_if_no_DOI">
    </xsl:template-->
    
    <xsl:template match="datacite:identifier" mode="collection_location_doi">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:choose>
                            <xsl:when test="starts-with(. , '10.')">
                                <xsl:value-of select="concat('http://doi.org/', .)"/>
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
    
    <xsl:template match="datacite:identifier" mode="collection_location_url">
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
    
    <xsl:template match="datacite:title" mode="collection_name">
        <name type="primary">
            <namePart>
                <xsl:value-of select="normalize-space(.)"/>
            </namePart>
        </name>
    </xsl:template>
    
    
   <!--xsl:template match="dc:identifier.orcid" mode="collection_relatedInfo">
        <xsl:message select="concat('orcidId : ', .)"/>
                            
        <relatedInfo type='party'>
            <identifier type="{custom:getIdentifierType(.)}">
                <xsl:value-of select="normalize-space(.)"/>
            </identifier>
            <relation type="hasCollector"/>
        </relatedInfo>
    <xsl:template-->
    
    <xsl:template match="datacite:creator" mode="collection_relatedObject">
        <relatedObject>
            <key>
                <xsl:value-of select="murFunc:formatKey(murFunc:formatName(datacite:creatorName))"/> 
            </key>
            <relation type="hasCollector"/>
        </relatedObject>
    </xsl:template>
    
    <xsl:template match="datacite:contributor" mode="collection_relatedObject">
        <relatedObject>
            <key>
                <xsl:value-of select="murFunc:formatKey(murFunc:formatName(datacite:contributorName))"/> 
            </key>
            <relation type="hasCollector"/>
        </relatedObject>
    </xsl:template>
    
    <xsl:template match="datacite:subject" mode="collection_subject">
        <xsl:if test="string-length(.) > 0">
            <subject type="local">
                <xsl:value-of select="normalize-space(.)"/>
            </subject>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="datacite:date" mode="collection_dates_date">
        <dates type="{lower-case(@dateType)}">
            <date type="dateFrom">
                <xsl:value-of select="."/>
            </date>
        </dates>
    </xsl:template>

    
    <!--xsl:template match="dc:coverage" mode="collection_spatial_coverage">
        <coverage>
            <spatial type='text'>
                <xsl:value-of select='normalize-space(.)'/>
            </spatial>
        </coverage>
    </xsl:template-->
   
    <xsl:template name="rightsStatement">
        <!-- override with rights statement for all in olac_dc if required -->
    </xsl:template>
   
    <xsl:template match="datacite:rights" mode="collection_rights">
        <rights>
            <accessRights>
                <xsl:attribute name="rightsUri">
                    <xsl:value-of select="@rightsURI"/>
                </xsl:attribute>
                <xsl:if test="(lower-case(.) = 'open access')">
                    <xsl:attribute name="type">
                        <xsl:text>open</xsl:text>
                    </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
            </accessRights>
        </rights>
        
          </xsl:template>
    
    <xsl:template name="collection_description_default">
        <description type="brief">
            <xsl:value-of select="'(no description)'"/>
        </description>
    </xsl:template>
    
    <xsl:template match="dc:description" mode="collection_description_full">
        <description type="full">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <!-- for when there is no description - use title in brief description -->
    <xsl:template match="datacite:title" mode="collection_description_brief">
        <description type="brief">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <xsl:template match="oaire:resource" mode="collection_citationInfo_citationMetadata">
        <citationInfo>
            <citationMetadata>
                <xsl:choose>
                    <xsl:when test="count(datacite:identifier[(@identifierType = 'DOI') and (string-length() > 0)]) > 0">
                        <xsl:apply-templates select="datacite:identifier[(@identifierType = 'DOI')]" mode="identifier"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="datacite:alternateIdentifier[(@alternateIdentifierType = 'URL')]" mode="identifier"/>
                    </xsl:otherwise>
                </xsl:choose>
                            
                <xsl:for-each select="datacite:creators/datacite:creator/datacite:creatorName">
                    <xsl:apply-templates select="." mode="citationMetadata_contributor"/>
                </xsl:for-each>
                
                <xsl:for-each select="datacite:contributors/datacite:contributor/datacite:contributorName">
                    <xsl:apply-templates select="." mode="citationMetadata_contributor"/>
                </xsl:for-each>
                
                <title>
                    <xsl:value-of select="datacite:title"/>
                </title>
                <!--version></version-->
                <!--placePublished></placePublished-->
                <publisher>
                    <xsl:value-of select="dc:publisher"/>
                </publisher>
                <date type="publicationDate">
                    <xsl:value-of select="datacite:dates/datacite:date[@dateType = 'Issued']"/>
                </date>
                <url>
                    <xsl:value-of select="datacite:alternateIdentifier[(@alternateIdentifierType = 'URL')]"/>
                </url>
            </citationMetadata>
        </citationInfo>
        
    </xsl:template>
    
    <xsl:template match="datacite:contributorName | datacite:creatorName" mode="citationMetadata_contributor">
        <contributor>
            <namePart type="family">
                <xsl:choose>
                    <xsl:when test="contains(., ',')">
                        <xsl:value-of select="normalize-space(substring-before(.,','))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </namePart>
            <namePart type="given">
                <xsl:if test="contains(., ',')">
                    <xsl:value-of select="normalize-space(substring-after(.,','))"/>
                </xsl:if>
            </namePart>
        </contributor>
    </xsl:template>
    
             
     <xsl:template match="*" mode="party">
        
         <xsl:for-each select="datacite:creators/datacite:creator | datacite:contributors/datacite:contributor">
            
            <xsl:variable name="name" select="normalize-space(.)"/>
            
            <xsl:if test="(string-length(.) > 0)">
            
                   <xsl:if test="string-length(normalize-space(.)) > 0">
                     <registryObject group="{$global_group}">
                        <key>
                            <xsl:value-of select="murFunc:formatKey(murFunc:formatName(datacite:creatorName | datacite:contributorName))"/> 
                        </key>
                        <originatingSource>
                             <xsl:value-of select="$global_originatingSource"/>
                        </originatingSource>
                        
                         <party>
                            <xsl:attribute name="type" select="'person'"/>
                             
                             <name type="primary">
                                 <namePart>
                                     <xsl:value-of select="murFunc:formatName(normalize-space(datacite:creatorName | datacite:contributorName))"/>
                                 </namePart>   
                             </name>
                             <xsl:for-each select="datacite:nameIdentifier">
                                 <identifier type="{lower-case(@nameIdentifierScheme)}">
                                    <xsl:value-of select="normalize-space(.)"/>
                                 </identifier>
                             </xsl:for-each>
                         </party>
                     </registryObject>
                   </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:template>
                   
    <xsl:function name="murFunc:formatName">
        <xsl:param name="name"/>
        
        <xsl:variable name="namePart_sequence" as="xs:string*">
            <xsl:analyze-string select="$name" regex="[A-Za-z()-]+">
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
    