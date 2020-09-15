<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xsl dc oai fn">

    <xsl:import href="OLAC_DC_To_Rifcs.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'PARADISEC'"/>
    <xsl:param name="global_group" select="'PARADISEC'"/>
    <xsl:param name="global_acronym" select="'PARADISEC'"/>
    <xsl:param name="global_publisherName" select="'PARADISEC'"/>
    <xsl:param name="global_baseURI" select="'http://catalog.paradisec.org.au'"/>
    <xsl:param name="global_path" select="'/repository/'"/>
    <xsl:param name="global_access_conditions" select="'https://www.paradisec.org.au/deposit/access-conditions'"/>
    <xsl:param name="global_rightsStatement" select="'Access to the catalog entry is open, but access to records is only open to registered users'"/>
    <xsl:param name="global_access_text_open" select="'Open (subject to agreeing to PDSC access conditions)'"/>
    <xsl:param name="global_headerIdentitierPrefix" select="'oai:paradisec.org.au:'"/>
    
    <!--
        Rules below are for how to determine title - for this example, we'll use collection-item identifier 'GB10-014'

        choose
 	      when (no title) OR ((title is exactly equal to item, e.g. '014') or (title equals '[Title to be supplied]'))
             choose
                when ((there is a description) AND (description does not contain 'No description available'))
                    choose
                        when description greater than 80
                            use for title:  {collection-item} +  ' - ' {first 80 characters of description}
                        otherwise
                            use for title:  {collection-item} +  ' - ' {all description}
                    otherwise (no title, or title equals '[Title to be supplied]' and no description either, so just use collection-item)
                        use for title: {collection-item}
           otherwise (we have a title and it is not just the item identifier)
             use for title: {collection-item} + ' - ' + {title provided}
    -->
    
    <xsl:template match="dc:title" mode="collection_name">
        <!--xsl:variable name="collectionIDandItemID" select="normalize-space(../dc:identifier[not(@*) or not(string-length(@*))][contains(., $itemIdentifierFromHeader)])"/-->
        
        <xsl:variable name="collAndItemIdentifierFromHeader" select="substring-after(normalize-space(ancestor::oai:record/oai:header/oai:identifier), $global_headerIdentitierPrefix)"/>
        
        <xsl:variable name="count" select="count(tokenize($collAndItemIdentifierFromHeader, '-'))" as="xs:integer"/>
        <xsl:variable name="itemIdentifierFromHeader" select="tokenize($collAndItemIdentifierFromHeader, '-')[$count]"/> <!-- e.g. format: '014' 00-->
        <xsl:if test="$global_debug">
            <xsl:message select="concat('Coll and item from header: ', $collAndItemIdentifierFromHeader)"/> <!-- e.g. format: 'CS1-014' 00-->
            <xsl:message select="concat('Item from header: ', $itemIdentifierFromHeader)"/>
            <xsl:message select="concat('dc:title: ', normalize-space(.))"/>
        </xsl:if>
        <xsl:variable name="titleProcessed">
            <xsl:choose>
                <xsl:when test="(string-length(normalize-space(.)) = 0) or
                    (normalize-space(.) = $itemIdentifierFromHeader) or
                    (normalize-space(.) = '[Title to be supplied]')">
                    <xsl:choose>
                        <xsl:when test="(string-length(normalize-space(../dc:description)) > 0) and
                                        not(contains(lower-case(../dc:description), 'no description available'))">
                            <xsl:choose>
                                <xsl:when test="string-length(../dc:description) > 80">
                                    <xsl:value-of select="concat($collAndItemIdentifierFromHeader, ' - ', substring(../dc:description, 1, 80), '...')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat($collAndItemIdentifierFromHeader, ' - ', ../dc:description)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$collAndItemIdentifierFromHeader"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($collAndItemIdentifierFromHeader, ' - ', normalize-space(.))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:if test="string-length($titleProcessed) > 0">
            <xsl:if test="$global_debug"><xsl:message select="concat('Using $titleProcessed (instead of dc:title): ', $titleProcessed)"/></xsl:if>
            <name type="primary">
                <namePart>
                    <xsl:value-of select="$titleProcessed"/>
                </namePart>
            </name>
        </xsl:if>
        
    </xsl:template>
    
    
</xsl:stylesheet>
    
