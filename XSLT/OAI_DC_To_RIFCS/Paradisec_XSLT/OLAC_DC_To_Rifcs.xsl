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
    exclude-result-prefixes="xsl dc oai oai_dc dcterms olac fn xs xsi">
	
	
    <xsl:import href="CustomFunctions.xsl"/>
    <xsl:import href="OAI_DC_To_Rifcs.xsl"/>
    
    <xsl:param name="global_collectionPath" select="'/collections/'"/>
    

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
    
    <!-- Override for paradisec -->
    <xsl:template match="*" mode="collection_key">
        <key>
            <xsl:value-of select="concat($global_acronym, '/', dc:identifier[not(@*) or not(string-length(@*))][1])"/>
        </key>
    </xsl:template>
    
  
    <xsl:template match="oai:OAI-PMH/*/oai:record">
            <xsl:message select="concat('name: ', name(.), ', namespace-uri: ', fn:namespace-uri(.), ', prefix: ', fn:prefix-from-QName(node-name(.)))"/>
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
                <xsl:value-of select="concat($global_baseURI, $global_collectionPath, $collectionId)"/> 
            </key>
            <relation type="isPartOf"/>
        </relatedObject>
    </xsl:template>
    
    <xsl:template match="dcterms:bibliographicCitation" mode="collection_extract_DOI_identifier">
        <xsl:variable name="doiValue" select="normalize-space(substring-after(.,'DOI:'))"/>
        <xsl:if test="string-length($doiValue) > 0">
            <identifier type='doi'>
                <xsl:value-of select="$doiValue"/>
            </identifier>
        </xsl:if>
    </xsl:template>  
    
    <xsl:template match="dcterms:bibliographicCitation" mode="collection_extract_DOI_location">
        <xsl:variable name="doiValue" select="normalize-space(substring-after(.,'DOI:'))"/>
        <xsl:if test="string-length($doiValue) > 0">
            <location>
                <address>
                    <electronic type="url" target="landingPage">
                        <value>
                            <xsl:value-of select="concat('http://doi.org/', $doiValue)"/>
                        </value>
                    </electronic>
                </address>
            </location> 
        </xsl:if>
    </xsl:template>  
    
    <xsl:template match="dc:identifier[@xsi:type ='dcterms:URI']" mode="collection_location_if_no_DOI">
        <xsl:variable name="doiValue" select="normalize-space(substring-after(ancestor::olac:olac/dcterms:bibliographicCitation,'DOI:'))"/>
        <!-- if there isn't a doi value and so the template above didn't use the doi as location,
            use this uri as location -->
        <xsl:if test="string-length($doiValue) = 0">
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
            <subject type="{@xsi:type}">
                <xsl:value-of select="normalize-space(@olac:code)"/>
            </subject>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dc:coverage" mode="collection_spatial_coverage">
        <coverage>
            <spatial>
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="string-length(@xsi:type) > 0">
                            <xsl:value-of select="@xsi:type"/>
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
    
