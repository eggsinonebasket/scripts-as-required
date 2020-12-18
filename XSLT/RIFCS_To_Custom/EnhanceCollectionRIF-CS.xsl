<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:extRif="http://ands.org.au/standards/rif-cs/extendedRegistryObjects"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xpath-default-namespace="http://ands.org.au/standards/rif-cs/registryObjects"
    exclude-result-prefixes="xs custom extRif"
    version="2.0">
    
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="getCitationDOI_populateIdentifier_AppendExisting" select="true()"/>
    <xsl:param name="getCitationDOI_populateElectronicLocation_ReplaceExisting" select="true()"/>
    <xsl:param name="replaceDodgyCharactersName" select="true()"/>
    
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
    
    <xsl:template match="registryObject/collection/identifier[(@type='doi') or (contains(.,'doi.org')) or (starts-with(., '10.'))]">
        <!-- if we are going to replace this doi, don't pass these on - catch them here -->
        <xsl:variable name="doiValue_Sequence" select="custom:getDOI_FromString(normalize-space(ancestor::*:registryObject/*:collection/*:citationInfo/*:fullCitation), false())" as="xs:string*"/>
        <xsl:choose>
            <xsl:when test="($getCitationDOI_populateIdentifier_AppendExisting = false()) or ((count($doiValue_Sequence) = 0) or (string-length($doiValue_Sequence[1]) = 0))">
                <!-- we won't be replacing the doi so use those provided -->
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
          </xsl:choose>
    </xsl:template>
    
    <xsl:template match="registryObject/collection/location/address/electronic">
        <!-- if we are going to replace this doi, don't pass these on - catch them here -->
        <xsl:variable name="doiValue_Sequence" select="custom:getDOI_FromString(normalize-space(ancestor::*:registryObject/*:collection/*:citationInfo/*:fullCitation), false())" as="xs:string*"/>
        <xsl:choose>
            <xsl:when test="($getCitationDOI_populateElectronicLocation_ReplaceExisting = false()) or ((count($doiValue_Sequence) = 0) or (string-length($doiValue_Sequence[1]) = 0))">
                <!-- we won't be replacing the electronic location so use those provided -->
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="registryObject/collection">
        <!-- construct collection element -->
        <collection>
            <!-- construct attributes-->
            <xsl:apply-templates select="@*"/>
            
            <xsl:variable name="doiValue_Sequence_short" select="custom:getDOI_FromString(normalize-space(ancestor::*:registryObject/*:collection/*:citationInfo/*:fullCitation), false())" as="xs:string*"/>
            
            <!-- add identifier type 'doi', using doi from full citation-->
            <xsl:if test="($getCitationDOI_populateIdentifier_AppendExisting = true()) and ((count($doiValue_Sequence_short) > 0) and (string-length($doiValue_Sequence_short[1]) > 0))">
                <identifier type="doi">
                    <xsl:value-of select="$doiValue_Sequence_short[1]"/>
                </identifier>
            </xsl:if>
            
            <xsl:variable name="doiValue_Sequence_http" select="custom:getDOI_FromString(normalize-space(ancestor::*:registryObject/*:collection/*:citationInfo/*:fullCitation), true())" as="xs:string*"/>
            
            
            <xsl:if test="($getCitationDOI_populateElectronicLocation_ReplaceExisting= true()) and ((count($doiValue_Sequence_http) > 0) and (string-length($doiValue_Sequence_http[1]) > 0))">
                <location>
                    <address>
                        <electronic type="url" target="landingPage">
                            <value>
                                <xsl:value-of select="$doiValue_Sequence_http[1]"/>
                            </value>
                        </electronic>
                    </address>
                </location>
            </xsl:if>
            
            <xsl:apply-templates select="node()"/>
        </collection>
    </xsl:template>
        
  
    
</xsl:stylesheet>
