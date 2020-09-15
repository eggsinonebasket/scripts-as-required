<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:olac="http://www.language-archives.org/OLAC/1.1/"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:custom="http://custom.nowhere.yet"
    exclude-result-prefixes="custom xsl dc oai oai_dc dcterms olac fn xs xsi">
	
	
    <xsl:import href="CustomFunctions.xsl"/>
    <xsl:import href="OAI_DC_To_Rifcs.xsl"/>
    
    <xsl:param name="global_collectionKeyBase" select="'paradisec.org.au/collection/'"/>
    <xsl:param name="global_language_resolution_iso636-3" select="'https://iso639-3.sil.org/code/'"/>
    <xsl:param name="global_language_resolution_glottolog" select="'https://glottolog.org/glottolog?iso='"/>
    <xsl:param name="global_language_resolution_archive" select="'http://www.language-archives.org/language/'"/>
    <xsl:param name="global_access_text_open" select="''"/>
    <xsl:param name="global_access_conditions" select="''"/>
    <xsl:param name="global_rightsStatement" select="''"/>
    <xsl:param name="global_debug" select="false()"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects 
            http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
          
            <xsl:apply-templates select="oai:OAI-PMH/*/oai:record"/>
            
        </registryObjects>
    </xsl:template>
    
    <!-- Override for paradisec -->
    <xsl:template match="*" mode="collection_key">
        <key>
            <xsl:value-of select="concat($global_acronym, '/', dc:identifier[not(@*) or not(string-length(@*))][1])"/>
        </key>
    </xsl:template>
    
  
    <xsl:template match="oai:OAI-PMH/*/oai:record">
            <!--xsl:message select="concat('name: ', name(.), ', namespace-uri: ', fn:namespace-uri(.), ', prefix: ', fn:prefix-from-QName(node-name(.)))"/-->
            <xsl:apply-templates select="oai:metadata/olac:olac" mode="collection"/>
            <!--  xsl:apply-templates select="oai:metadata/oai_dc:dc/dc:funding" mode="funding_party"/-->
            <!--xsl:apply-templates select="oai:metadata/olac:dc" mode="party"/--> 
     </xsl:template>
    
    <xsl:template match="dc:identifier" mode="collection_relatedObject">
        <!-- Identifier is in form 'collection-item' e.g. AA1-001 so get collection from this, e.g. 'AA1' -->
        <xsl:variable name="collectionId" select="tokenize(., '-')[1]"/>
        <xsl:if test="string-length($collectionId) > 0"></xsl:if>
        <relatedObject>
            <key>
                <xsl:value-of select="concat($global_collectionKeyBase, $collectionId)"/> 
            </key>
            <relation type="isPartOf"/>
        </relatedObject>
    </xsl:template>
    
    <xsl:template match="dcterms:bibliographicCitation" mode="collection_extract_DOI_identifier">
        <xsl:variable name="doiValue" select="custom:getDOI_FromString(normalize-space(.), false())"/>
        <xsl:if test="string-length($doiValue) > 0">
            <identifier type='doi'>
                <xsl:value-of select="$doiValue"/>
            </identifier>
        </xsl:if>
        
    </xsl:template>  
    
    <xsl:template match="dcterms:bibliographicCitation" mode="collection_extract_DOI_location">
        <xsl:variable name="doiValue_sequence" select="custom:getDOI_FromString(normalize-space(.), true())" as="xs:string*"/>
        <xsl:if test="count($doiValue_sequence) > 0">
            <location>
                <address>
                    <electronic type="url" target="landingPage">
                        <value>
                            <xsl:value-of select="$doiValue_sequence[1]"/>
                        </value>
                    </electronic>
                </address>
            </location> 
        </xsl:if>
    </xsl:template>  
    
   
    
    <xsl:template match="dc:identifier[@xsi:type ='dcterms:URI']" mode="collection_location_if_no_DOI">
        <!-- if there isn't a doi value and so the template above didn't use the doi as location,
            use this uri as location -->
        <xsl:variable name="doiValue_sequence" select="custom:getDOI_FromString(normalize-space(ancestor::olac:olac/dcterms:bibliographicCitation), false())" as="xs:string*"/>
        <xsl:if test="count($doiValue_sequence) = 0">
            <xsl:if test="string-length(.) > 0">
                <location>
                    <address>
                        <electronic type="url" target="landingPage">
                            <value>
                                <xsl:value-of select="."/>
                            </value>
                        </electronic>
                    </address>
                </location> 
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
   
    
    <xsl:template match="dc:subject" mode="collection_subject">
        <xsl:if test="(string-length(@xsi:type) > 0) and (string-length(@olac:code) > 0)">
            <xsl:choose>
                <xsl:when test="@xsi:type = 'olac:language'">
                    <subject>
                        <xsl:attribute name="type">
                            <xsl:value-of select="@xsi:type"/>
                        </xsl:attribute>
                        <xsl:attribute name="termIdentifier">
                            <xsl:value-of select="concat($global_language_resolution_iso636-3, @olac:code)"/>
                        </xsl:attribute>
                        <xsl:value-of select="normalize-space(@olac:code)"/>
                    </subject>
                    <relatedInfo type="reuseInformation">
                        <identifier type="uri">
                            <xsl:value-of select="concat($global_language_resolution_iso636-3, @olac:code)"/>
                        </identifier>
                    </relatedInfo>
                    <relatedInfo type="reuseInformation">
                        <identifier type="uri">
                            <xsl:value-of select="concat($global_language_resolution_glottolog, @olac:code)"/>
                        </identifier>
                    </relatedInfo>
                    <relatedInfo type="reuseInformation">
                        <identifier type="uri">
                            <xsl:value-of select="concat($global_language_resolution_archive, @olac:code)"/>
                        </identifier>
                    </relatedInfo>
                </xsl:when>
                <xsl:otherwise>
                    <subject type="{@xsi:type}">
                        <xsl:value-of select="normalize-space(@olac:code)"/>
                    </subject>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="rightsStatement">
        <rights>
            <xsl:if test="string-length($global_rightsStatement) > 0">
                <rightsStatement>
                    <xsl:value-of select="$global_rightsStatement"/>
                </rightsStatement>
            </xsl:if>
        </rights>
    </xsl:template>
    
    <xsl:template match="dc:rights" mode="collection_rights_rightsStatement">
        <rights>
            <accessRights>
                <xsl:choose>
                    <xsl:when test="(string-length($global_access_text_open) > 0) and (. = $global_access_text_open)">
                        <xsl:attribute name="type">
                            <xsl:text>open</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="string-length($global_access_conditions) > 0">
                    <xsl:attribute name="rightsUri">
                        <xsl:value-of select="$global_access_conditions"/>
                    </xsl:attribute>
                </xsl:if>
            </accessRights>
        </rights>
    </xsl:template>
    
    <xsl:template match="dc:coverage" mode="collection_spatial_coverage">
        <coverage>
            <spatial>
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="string-length(@xsi:type) > 0">
                            <xsl:choose>
                                <xsl:when test="contains(@xsi:type,'dcterms:Box')">
                                    <xsl:text>iso19139dcmiBox</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains(@xsi:type,'dcterms:')">
                                    <xsl:value-of select="substring-after(@xsi:type, 'dcterms:')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@xsi:type"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>    
                        <xsl:otherwise>
                            <xsl:text>text</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:value-of select='normalize-space(.)'/>
            </spatial>
        </coverage>
    </xsl:template>
    
    <xsl:template match="dc:creator" mode="collection_relatedObject">
        <!-- not creating parties at the moment because they may already be in the Paradisec
            collection feed and we can't work out their ids from this item metadata -->
        <!--relatedObject>
            <key>
                <xsl:value-of select="murFunc:formatKey(murFunc:formatName(.))"/> 
            </key>
            <relation type="hasCollector"/>
        </relatedObject-->
    </xsl:template>
    
    <xsl:template match="dc:contributor" mode="collection_relatedObject">
        <!-- not creating parties at the moment because they may already be in the Paradisec
            collection feed and we can't work out their ids from this item metadata -->
        <!--relatedObject>
            <key>
                <xsl:value-of select="murFunc:formatKey(murFunc:formatName(.))"/> 
            </key>
            <relation type="hasCollector"/>
        </relatedObject-->
    </xsl:template>
    
</xsl:stylesheet>
    
