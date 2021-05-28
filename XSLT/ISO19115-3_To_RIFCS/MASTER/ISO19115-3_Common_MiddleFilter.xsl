<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="fn xs mdb">
    
    
    <!-- 
        This ISO19115_1_Common_MiddleFilter.xsl removes version after namespace so that files with slightly 
        different versions, yet not much difference, can be passed to ISO19115_1_Common_Base to be handled - 
        e.g. whether they have http://standards.iso.org/iso/19115/-3/mdb/1.0 or 
        http://standards.iso.org/iso/19115/-3/mdb/2.0 they will be transformed here in the 
        ISO19115_1_Common_MiddleFilter.xsl to have just http://standards.iso.org/iso/19115/-3/mdb (no version)
        and then passed to ISO19115_1_Common_MiddleFilter.xsl for common processing.
        If you need to handle anything specific to the version, do this within templates in these higher levels: 
            -   either in the ISO19115_1_Custom_TopLevel.xsl if per provider, or here in the 
                ISO19115_1_Common_MiddleFilter.xsl if it's a 2.0 thing for example, that
                multiple providers may have 
    -->
    
    <xsl:import href="ISO19115-3_To_RIFCS.xsl"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <!--xsl:strip-space elements="*"/-->
    
    <xsl:template match="/" mode="middleFilter">
        <xsl:variable name="identity">
            <xsl:apply-templates mode="middleFilter"/>     
        </xsl:variable>
        
        <!--xsl:variable name="documentReplacedNamespace" select="fn:parse-xml($identity)"/-->
        
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
            
            <xsl:apply-templates select="$identity" mode="filter"/>
        </registryObjects>
        
    </xsl:template>
    
    <!-- override this in top-level xsl that call this, if you want to filter on anything,
        for example, MD_Metadata objects with a certain scopecode -->
    <xsl:template match="@*|node()" mode="filter">
        <xsl:if test="$global_debug"><xsl:message select="'All mdb:MD_Metadata objects processed - override in higher xsl if filter required'"/></xsl:if>
        <xsl:for-each select="//mdb:MD_Metadata">
            <xsl:apply-templates select="." mode="process"/>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- identity transform -->
    
    <xsl:template match="@*|node()" mode="middleFilter">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="middleFilter"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node()[string-length(namespace-uri()) > 0]" mode="middleFilter">
        <xsl:variable name="namespaceNoVersionPostfix_sequence" as="xs:string*">
            <xsl:variable name="namespaceUri_sequence" select="tokenize(namespace-uri(), '/')" as="xs:string*"/>
            <xsl:for-each select="$namespaceUri_sequence">
                <xsl:if test="position() &lt; count($namespaceUri_sequence)">
                    <xsl:value-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="count($namespaceNoVersionPostfix_sequence) > 0">
                <xsl:element name="{name()}" namespace="{string-join($namespaceNoVersionPostfix_sequence, '/')}">
                    <xsl:apply-templates select="@*|node()" mode="middleFilter"/>  
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{name()}">
                    <xsl:apply-templates select="@*|node()" mode="middleFilter"/>  
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
