<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    exclude-result-prefixes="xsl dc">

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
    
    
    <!-- if title is empty or equal to the item identifier after the '-', e.g. '014'
            use the identifier value for title e.g. 'CS1-014' rather than just this item id '014' 
            ; otherwise, prepend identifier before rich title, e.g. 'CS1-014 - Rich Title -->
    
    <xsl:template match="dc:title" mode="collection_name">
       
        <xsl:variable name="titleProcessed">
            <xsl:choose>
                <xsl:when test="(string-length(normalize-space(.)) = 0) or
                    (normalize-space(.) = substring-after(normalize-space(../dc:identifier[not(@*) or not(string-length(@*))]), '-'))">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(../dc:description)) > 0">
                            <xsl:choose>
                                <xsl:when test="string-length(../dc:description) > 80">
                                    <xsl:value-of select="concat(normalize-space(../dc:identifier[not(@*) or not(string-length(@*))]), ' - ', substring(../dc:description, 1, 80), '...')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat(normalize-space(../dc:identifier[not(@*) or not(string-length(@*))]), ' - ', ../dc:description)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="normalize-space(../dc:identifier[not(@*) or not(string-length(@*))])"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat(normalize-space(../dc:identifier[not(@*) or not(string-length(@*))]), ' - ', normalize-space(.))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:if test="string-length($titleProcessed) > 0">
            <name type="primary">
                <namePart>
                    <xsl:value-of select="$titleProcessed"/>
                </namePart>
            </name>
        </xsl:if>
        
    </xsl:template>
    
    
</xsl:stylesheet>
    
