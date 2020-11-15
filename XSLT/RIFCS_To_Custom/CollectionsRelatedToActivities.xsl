<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:ro="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:extRif="http://ands.org.au/standards/rif-cs/extendedRegistryObjects" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="1.0">
    
    <xsl:param name="columnSeparator" select="'^'"/>
    <xsl:param name="valueSeparator" select="','"/>
    
    <xsl:param name="activityXML" select="document('file:///home/csiroanu/projects/UNIofAdelaide_Project/FromProductionRDA_DataConnect/University-of-Adelaide-MainDatasource_And_MintDatasource_RIF-CS-Export_ProductionPublishedActivities.xml')"/>
    <xsl:param name="collectionXML_prod" select="document('file:///home/csiroanu/projects/UNIofAdelaide_Project/University-of-Adelaide-Figshare-RIF-CS-Export_FigshareProdPublishedCollections.xml')"/>
    
    <!-- This can be run on Collection registryObjects xml, to find each activity related to the Collection -->
    
    <xsl:output omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>  
    
    
    <xsl:template match="/">
        
        <xsl:text>activityInProductionRDA</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <xsl:text>activityID</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <xsl:text>activityName</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <xsl:text>collectionInProductionRDA</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <xsl:text>collectionTitle</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
        
        <xsl:text>collectionIsInDemoRDA (from figshare)</xsl:text>
        <xsl:value-of select="$columnSeparator"/>
       
        <xsl:text>&#xa;</xsl:text>
        
        <xsl:apply-templates select="//ro:registryObject/ro:collection[count(ro:relatedObject[contains(ro:relation/@type, 'isOutputOf')])]"/>
            
    </xsl:template>
    
    <xsl:template match="ro:collection">
        
        <xsl:variable name="currentCollectionKey" select="preceding-sibling::ro:key"/>
        
        <xsl:variable name="currentCollectionName" select="ro:name/ro:namePart"/>
        
        <xsl:for-each select="ro:relatedObject[contains(ro:relation/@type, 'isOutputOf')]">
            
            
            <xsl:variable name="currentActivityKey" select="ro:key"/>
            
            <!--	column: activity in production -->
            <xsl:text>&quot;</xsl:text>
            <xsl:value-of select="concat('https://researchdata.ands.org.au/view/?key=', ro:key)"/>
            <xsl:text>&quot;</xsl:text>
            <xsl:value-of select="$columnSeparator"/>
            
            <xsl:choose>
                <xsl:when test="count($activityXML/ro:registryObjects/ro:registryObject/ro:activity[contains(preceding-sibling::ro:key, $currentActivityKey)]) > 1">
                    <xsl:message><xsl:value-of select="concat('Unexpected:  found more than one activity with key: ', $currentActivityKey)"/></xsl:message>
                </xsl:when>
                <xsl:when test="count($activityXML/ro:registryObjects/ro:registryObject/ro:activity[contains(preceding-sibling::ro:key, $currentActivityKey)]) = 1">
                    <xsl:message><xsl:value-of select="concat('Found one activity with key: ', $currentActivityKey)"/></xsl:message>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message><xsl:value-of select="concat('Found zero activities with key: ', $currentActivityKey)"/></xsl:message>
                </xsl:otherwise>
            </xsl:choose>
            
            <!--	column: activity purl	 -->
            <xsl:text>&quot;</xsl:text>
            <xsl:choose>
                <xsl:when test="count($activityXML/ro:registryObjects/ro:registryObject/ro:activity[contains(preceding-sibling::ro:key, $currentActivityKey)]) > 0">
                    <xsl:if test="string-length($activityXML/ro:registryObjects/ro:registryObject/ro:activity[contains(preceding-sibling::ro:key, $currentActivityKey)][1]/ro:identifier[@type = 'purl' or contains(., 'adelaide.edu.au')]) > 0">
                        <xsl:value-of select="$activityXML/ro:registryObjects/ro:registryObject/ro:activity[contains(preceding-sibling::ro:key, $currentActivityKey)][1]/ro:identifier[@type = 'purl' or contains(., 'adelaide.edu.au')]"/>    
                    </xsl:if>
                </xsl:when>         
            </xsl:choose>
            
            <xsl:text>&quot;</xsl:text>
            <xsl:value-of select="$columnSeparator"/>
            
            <!--	column: activity name	 -->
            <xsl:text>&quot;</xsl:text>
            <xsl:choose>
                 <xsl:when test="count($activityXML/ro:registryObjects/ro:registryObject/ro:activity[contains(preceding-sibling::ro:key, $currentActivityKey)]) > 0">
                     <xsl:if test="string-length($activityXML/ro:registryObjects/ro:registryObject/ro:activity[contains(preceding-sibling::ro:key, $currentActivityKey)][1]/ro:name/ro:namePart) > 0">
                         <xsl:value-of select="$activityXML/ro:registryObjects/ro:registryObject/ro:activity[contains(preceding-sibling::ro:key, $currentActivityKey)][1]/ro:name/ro:namePart"/>    
                     </xsl:if>
                 </xsl:when>         
            </xsl:choose>
            
            <xsl:text>&quot;</xsl:text>
            <xsl:value-of select="$columnSeparator"/>
            
            
            <!--	column: collection key	(mandatory) -->
            <xsl:text>&quot;</xsl:text>
            <xsl:value-of select="concat('https://researchdata.ands.org.au/view/?key=', $currentCollectionKey)"/>
            <xsl:text>&quot;</xsl:text>
            <xsl:value-of select="$columnSeparator"/>
            
            <!--	column: collection name (mandatory) -->
            <xsl:text>&quot;</xsl:text>
            <xsl:value-of select="$currentCollectionName"/>
            <xsl:text>&quot;</xsl:text>
            <xsl:value-of select="$columnSeparator"/>
            
            <!--	column: collection in demo (mandatory) -->
            <xsl:text>&quot;</xsl:text>
            <xsl:choose>
                <xsl:when test="count($collectionXML_prod/ro:registryObjects/ro:registryObject/ro:collection[contains(ro:name/ro:namePart, $currentCollectionName)]) > 0">
                    <xsl:message>Collection is in figshare</xsl:message>
                    <xsl:if test="string-length($collectionXML_prod/ro:registryObjects/ro:registryObject/ro:collection[contains(ro:name/ro:namePart, $currentCollectionName)][1]/ro:name/ro:namePart) > 0">
                        <xsl:message><xsl:value-of select="concat('Collection in figshare has name: ', $collectionXML_prod/ro:registryObjects/ro:registryObject/ro:collection[contains(ro:name/ro:namePart, $currentCollectionName)][1]/preceding-sibling::ro:key)"/></xsl:message>
                        <xsl:value-of select="concat('https://researchdata.ands.org.au/view/?key=', $collectionXML_prod/ro:registryObjects/ro:registryObject/ro:collection[contains(ro:name/ro:namePart, $currentCollectionName)][1]/preceding-sibling::ro:key)"/>    
                    </xsl:if>
                </xsl:when>         
             </xsl:choose>
            <xsl:text>&quot;</xsl:text>
            <xsl:value-of select="$columnSeparator"/>
            
            <xsl:text>&#xa;</xsl:text>
            
            
        </xsl:for-each>
        
        
    
    </xsl:template>
    
</xsl:stylesheet>