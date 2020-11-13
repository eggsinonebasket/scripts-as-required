<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:extRif="http://ands.org.au/standards/rif-cs/extendedRegistryObjects"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xpath-default-namespace="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="xs custom extRif"
    version="2.0">
    
    <xsl:param name="getCitationDOI_populateIdentifier_AppendExisting" select="true()"/>
    <xsl:param name="getCitationDOI_populateElectronicLocation_ReplaceExisting" select="true()"/>
    <xsl:param name="replaceDodgyCharactersName" select="true()"/>
    
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_debug" select="true()"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="registryObject/*/name/namePart">
        <xsl:choose>
             <xsl:when test="$replaceDodgyCharactersName = true()">
                 <namePart>
                     <xsl:value-of select="custom:characterReplace(.)"/>
                 </namePart>
             </xsl:when>
             <xsl:otherwise>
                 <xsl:copy>
                     <xsl:apply-templates select="@*|node()"/>
                 </xsl:copy>
             </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="registryObject/collection/identifier">
        
        <xsl:if test="$getCitationDOI_populateIdentifier_AppendExisting = true()">
          <xsl:variable name="doiValue_Sequence" select="custom:getDOI_FromString(normalize-space(ancestor::*:registryObject/*:collection/*:citationInfo/*:fullCitation), false())" as="xs:string*"/>
          <xsl:if test="(count($doiValue_Sequence) > 0) and (string-length($doiValue_Sequence[1]) > 0)">
              <identifier type="doi">
                  <xsl:value-of select="$doiValue_Sequence[1]"/>
              </identifier>
          </xsl:if>
        </xsl:if>
        <!-- do the following either way, to tranfer other identifiers as they are-->
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="registryObject/collection/location/address/electronic">
        
        <xsl:choose>
            <xsl:when test="$getCitationDOI_populateElectronicLocation_ReplaceExisting= true()">
                <xsl:variable name="doiValue_Sequence" select="custom:getDOI_FromString(normalize-space(ancestor::*:registryObject/*:collection/*:citationInfo/*:fullCitation), true())" as="xs:string*"/>
                <xsl:if test="(count($doiValue_Sequence) > 0) and (string-length($doiValue_Sequence[1]) > 0)">
                    <electronic type="url" target="landingPage">
                        <value>
                            <xsl:value-of select="$doiValue_Sequence"/>
                        </value>
                    </electronic>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
