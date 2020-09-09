<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:custom="http://custom.nowhere.yet"
    exclude-result-prefixes="xs custom"
    version="2.0">
    
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*:registryObject/*:collection/*:identifier">
        <xsl:variable name="doiValue_Sequence" select="custom:getDOI_FromString(normalize-space(ancestor::*:registryObject/*:collection/*:citationInfo/*:fullCitation))" as="xs:string*"/>
        <xsl:if test="count($doiValue_Sequence) > 0">
            <identifier type="doi">
                <xsl:value-of select="$doiValue_Sequence[1]"/>
            </identifier>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
