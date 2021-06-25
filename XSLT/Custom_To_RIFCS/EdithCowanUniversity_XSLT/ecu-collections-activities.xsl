<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0" exclude-result-prefixes="dc">
    
    <xsl:param name="global_originatingSource" select="'Edith Cowan University'"/>
    <xsl:param name="global_baseURI" select="'ro.ecu.edu.au'"/>
    <xsl:param name="global_group" select="'Edith Cowan University'"/>
    <xsl:param name="global_publisherName" select="'Edith Cowan University'"/>
    <xsl:param name="global_debug" select="false()"/>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
            <xsl:apply-templates select="//oai:record/oai:metadata/*:document-export/*:documents/*:document" mode="collection"/>
            <xsl:apply-templates select="//oai:record/oai:metadata/*:document-export/*:documents/*:document" mode="activity"/>
            <xsl:apply-templates select="//oai:record/oai:metadata/*:document-export/*:documents/*:document" mode="party"/>
        </registryObjects>
    </xsl:template>

    <!--
    <xsl:template match="record">
        <xsl:variable name="key" select="header/identifier/text()"/>
        <xsl:variable name="class" select="substring-after(oai:header/oai:setSpec[starts-with(text(),'class:')]/text(),'class:')"/>
            <xsl:apply-templates select="oai:metadata/dc">
                <xsl:with-param name="key" select="$key"/>
                <xsl:with-param name="class" select="$class"/>
            </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="oai:setSpec">
        <xsl:variable name="key" select="oai:header/oai:identifier/text()"/>
        <xsl:variable name="class" select="oai:header/oai:identifier/text()"/>
        <xsl:apply-templates select="oai:metadata/dc">
            <xsl:with-param name="key" select="$key"/>
        </xsl:apply-templates>
    </xsl:template>
    -->

    <xsl:template match="document" mode="collection">

        <xsl:param name="key" select="custom:getKey(., true())"/>
            
        <xsl:param name="class" select="'collection'"/>
        <xsl:param name="type" select="'dataset'"/>
      
        <registryObject>
            <xsl:attribute name="group"><xsl:value-of select="$global_group"/></xsl:attribute>
            <key>
                <xsl:value-of select="$key"/>
            </key>
            <originatingSource><xsl:value-of select="$global_originatingSource"/></originatingSource>
            <xsl:element name="{$class}">

                <xsl:attribute name="type"><xsl:value-of select="$type"/></xsl:attribute>
                
                <xsl:if test="$global_debug"><xsl:message select="concat('name: ', name(.))"/></xsl:if>
                <xsl:apply-templates select="title"/>
                <xsl:apply-templates select="fields/field[@name='doi']/value"/>
                <xsl:apply-templates select="fields/field[@name='data_url']/value"/>
                <xsl:apply-templates select="abstract"/>
                <xsl:apply-templates select="fields/field[@name='addl_info']/value"/>
                <xsl:apply-templates select="fields/field[@name='distribution_license']/value"/>
                <xsl:apply-templates select="fields/field[@name='rights']/value"/>
                <xsl:apply-templates select="fields/field[@name='coverage']/value"/>
                <xsl:apply-templates select="keywords"/>
                <xsl:apply-templates select="disciplines"/>
                <xsl:apply-templates select="fields/field[@name='for_code']"/>
                <xsl:apply-templates select="fields/field[@name='longitude']"/>
                <xsl:apply-templates select="native-url"/>
                <xsl:apply-templates select="fields/field[@name='custom_citation']/value"/>
                <xsl:apply-templates select="fields/field[@name='related_content']" mode="collection"/>
                <xsl:apply-templates select="fields/field[@name='grant_num']" mode="collection"/>
                <xsl:apply-templates select="fields/field[@name='project_links']" mode="collection"/>
                <xsl:apply-templates select="fields/field[@name='contact']"/>
                <xsl:apply-templates select="coverpage-url"/>
                <xsl:apply-templates select="authors/author" mode="collection"/>
                <!--xsl:apply-templates select="fields/field[@name='comments']/value" mode="collection"/-->
            </xsl:element>
        </registryObject>
    </xsl:template>

    <xsl:template match="document" mode="activity">

        <xsl:param name="activityKey" select="concat(custom:getKey(., false()), ':activity')"/>
        <xsl:param name="collectionKey" select="custom:getKey(., true())"/>
        
        <xsl:param name="class" select="'activity'"/>
        <xsl:param name="type" select="'project'"/>
       
            <xsl:choose>
            <xsl:when test=".//field[@name='research_title']/value">
                <xsl:choose>
                    <xsl:when test=".//field[@name='research_description']/value">
                        <registryObject>
                        <xsl:attribute name="group"><xsl:value-of select="$global_group"/></xsl:attribute>
                        <key>
                            <xsl:value-of select="$activityKey"/>
                        </key>
                        <originatingSource><xsl:value-of select="$global_originatingSource"/></originatingSource>
                        <xsl:element name="{$class}">
                            <xsl:attribute name="type" select="$type"/>
                            <xsl:apply-templates select="fields/field[@name='research_title']/value"/>
                            <xsl:apply-templates select="fields/field[@name='research_description']/value"/>
                            <xsl:apply-templates select="keywords"/>
                            <xsl:apply-templates select="disciplines"/>
                            <xsl:apply-templates select="fields/field[@name='for_code']"/>
                            <xsl:apply-templates select="fields/field[@name='related_content']" mode="activity"/>
                            <xsl:apply-templates select="fields/field[@name='grant_num']" mode="activity"/>
                            <xsl:apply-templates select="fields/field[@name='project_links']" mode="activity"/>
                            <xsl:apply-templates select="fields/field[@name='contact']"/>
                            <xsl:apply-templates select="coverpage-url"/>
                            <xsl:apply-templates select="authors/author" mode="activity"/>
                            <!--xsl:apply-templates select="fields/field[@name='comments']/value" mode="activity"/-->
                            <relatedObject>
                                <key><xsl:value-of select="$collectionKey"/></key>
                              <relation type="hasOutput"/>
                            </relatedObject>
                            <relatedInfo type="party">
                                <identifier type="AU-ANL:PEAU">
                                    <xsl:text>http://nla.gov.au/nla.party-578358</xsl:text>
                                </identifier>
                                <relation type="isManagedBy"/>
                                <title>Edith Cowan University</title>
                            </relatedInfo>
                        </xsl:element>
                        </registryObject>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="document" mode="party">
        
        <xsl:if test="$global_debug"><xsl:message select="concat('document name(.): ', name(.))"/></xsl:if>
        
        <xsl:for-each select="authors/author">
            
            <xsl:variable name="firstName" select="fname"/>
            <xsl:variable name="lastName" select="lname"/>
            
            <xsl:variable name="nameFormatted" select="concat($firstName, ' ', $lastName)"/>
            
            <xsl:variable name="key" select="custom:formatKey($nameFormatted)"/>
             
            <xsl:variable name="class" select="'party'"/>
            <xsl:variable name="type" select="'person'"/>
             
             <registryObject>
                 <xsl:attribute name="group"><xsl:value-of select="$global_group"/></xsl:attribute>
                 <key>
                     <xsl:value-of select="custom:formatKey($nameFormatted)"/>
                 </key>
                 <originatingSource><xsl:value-of select="$global_originatingSource"/></originatingSource>
                 <xsl:element name="{$class}">
                     
                     <xsl:attribute name="type" select="$type"/>
                     
                     <xsl:variable name="htmlFormatted">
                         <xsl:variable name="html" select="../../fields/field[@name='comments']/value[contains(text(), '&lt;')]"/>
                         <xsl:if test="string-length($html)> 0">
                             <xsl:value-of select="fn:replace(fn:replace(fn:replace($html, '&lt;br /&gt;' , ''), '&lt;br/&gt;' , ''), '&amp;', '&amp;amp;')"/>
                         </xsl:if>
                     </xsl:variable>
                     
                     <xsl:if test="$global_debug"><xsl:message select="concat('$htmlFormatted :', $htmlFormatted)"/></xsl:if>
                     
                     
                    <xsl:variable name="identifier_sequence" select="custom:getIdentifiersForName_sequence($nameFormatted, $htmlFormatted)" as="xs:string*"/>
                     <xsl:if test="count($identifier_sequence) > 0">
                         <xsl:for-each select="distinct-values($identifier_sequence)">
                             <xsl:if test="string-length(normalize-space(.)) > 0">
                                 <xsl:if test="$global_debug"><xsl:message select="concat('Identifier for ', $nameFormatted, ': ', .)"/></xsl:if>
                                 <identifier type="{custom:identifierType(.)}">
                                     <xsl:value-of select="."/>
                                 </identifier>
                             </xsl:if>
                         </xsl:for-each>
                     </xsl:if>
                     <name type="primary">
                         <xsl:if test="string-length($firstName)> 0">
                             <namePart type="given">
                                 <xsl:value-of select="$firstName"/>
                             </namePart> 
                         </xsl:if>
                         <xsl:if test="string-length($lastName)> 0">
                             <namePart type="family">
                                 <xsl:value-of select="$lastName"/>
                             </namePart> 
                         </xsl:if>
                     </name>
                     
                     <xsl:if test="string-length(email)> 0">
                         <location>
                             <address>
                                <electronic type="email">
                                    <value>
                                        <xsl:value-of select="email"/>
                                    </value>
                                </electronic>
                                 </address>
                         </location>
                     </xsl:if>
                     
                     
                     <xsl:if test="string-length(institution) > 0">
                        <xsl:variable name="institutionID_TypeValuePair" select="custom:getId_TypeValuePair(institution)"/>
                        <xsl:if test="count($institutionID_TypeValuePair) = 2">
                           <relatedInfo type="party">
                               <title><xsl:value-of select="institution"/></title>
                               <identifier type="{$institutionID_TypeValuePair[1]}">
                                   <xsl:value-of select="$institutionID_TypeValuePair[2]"/>
                               </identifier>
                               <relation type="isMemberOf"/>
                           </relatedInfo>
                        </xsl:if>
                     </xsl:if>
                 </xsl:element>
             </registryObject>
        </xsl:for-each>
        
    </xsl:template>
  
    <xsl:template match="title">
        <name type="full">
            <namePart>
                <xsl:value-of select="."/>
            </namePart>
        </name>
    </xsl:template>

    <xsl:template match="field[@name='research_title']/value">
        <name type="primary">
            <namePart>
                <xsl:value-of select="."/>
            </namePart>
        </name>
    </xsl:template>

    <xsl:template match="field[@name='research_description']/value">
        <description type="full">
            <xsl:value-of select="."/>
        </description>
    </xsl:template>


    <!--
    <xsl:template match="document-type">
        <type>
            <xsl:value-of select="."/>
        </type>
    </xsl:template>
    -->

    <xsl:template match="field[@name='doi']/value">
        <identifier type="doi">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="field[@name='data_url']/value">
        <xsl:if test="$global_debug"><xsl:message select="concat('data_url: ', .)"/></xsl:if>
        <xsl:analyze-string select="." regex="href=&quot;(http.+?)&quot;">
            <xsl:matching-substring>
             <identifier>
                 <xsl:attribute name="type">
                     <xsl:choose>
                         <xsl:when test="contains(lower-case(.), 'doi')">
                             <xsl:text>doi</xsl:text>
                         </xsl:when>
                         <xsl:otherwise>
                             <xsl:text>uri</xsl:text>
                         </xsl:otherwise>
                     </xsl:choose>
                 </xsl:attribute>
                 <xsl:value-of select="regex-group(1)"/>
             </identifier>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="author" mode="collection">
            
        <xsl:variable name="firstName" select="fname"/>
        <xsl:variable name="lastName" select="lname"/>
        
        <xsl:variable name="nameFormatted" select="concat($firstName, ' ', $lastName)"/>
        
        <xsl:variable name="key" select="custom:formatKey($nameFormatted)"/>
        
        <xsl:if test="string-length($key) > 0">
            <relatedObject>
                <key>
                    <xsl:value-of select="$key"/>
                </key>
                <relation type="hasCollector"/>
            </relatedObject>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="author" mode="activity">
              
        <xsl:variable name="firstName" select="fname"/>
        <xsl:variable name="lastName" select="lname"/>
        
        <xsl:variable name="nameFormatted" select="concat($firstName, ' ', $lastName)"/>
        
        <xsl:variable name="key" select="custom:formatKey($nameFormatted)"/>
        
        <xsl:if test="string-length($key) > 0">
            <relatedObject>
                <key>
                    <xsl:value-of select="$key"/>
                </key>
                <relation type="hasAssociationWith"/>
            </relatedObject>
        </xsl:if>
        
    </xsl:template>
    
   <!--xsl:template match="field[@name='comments']/value" mode="collection">
       
        <xsl:variable name="unescapedContent" as="document-node()">
            <xsl:copy-of select="parse-xml(concat('&lt;root&gt;', ., '&lt;/root&gt;'))"/>
        </xsl:variable>
       
       <xsl:for-each select="$unescapedContent/root/p/a/@href">
           <relatedInfo type="party">
                <xsl:choose>
                    <xsl:when test="contains(., 'scopus')">
                        <identifier type="scopus">
                            <xsl:value-of select="."/>
                        </identifier>
                    </xsl:when>
                    <xsl:when test="contains(., 'researcherid')">
                        <identifier type="uri">
                            <xsl:value-of select="."/>
                        </identifier>
                    </xsl:when>
                    <xsl:when test="contains(., 'orcid')">
                        <identifier type="orcid">
                            <xsl:value-of select="."/>
                        </identifier>
                    </xsl:when>
                    <xsl:when test="contains(., 'nla')">
                        <identifier type="AU-ANL:PEAU">
                            <xsl:value-of select="."/>
                        </identifier>
                    </xsl:when>
                    <xsl:otherwise>
                        <identifier type="uri">
                            <xsl:value-of select="."/>
                        </identifier>
                    </xsl:otherwise>
                </xsl:choose>
               <relation type="hasCollector"/>
           </relatedInfo>           
        </xsl:for-each>
   </xsl:template-->
    
    <!--xsl:template match="field[@name='comments']/value" mode="activity">
        
        <xsl:variable name="unescapedContent" as="document-node()">
            <xsl:copy-of select="parse-xml(concat('&lt;root&gt;', ., '&lt;/root&gt;'))"/>
        </xsl:variable>
        
        <xsl:for-each select="$unescapedContent/root/p/a/@href">
            <relatedInfo type="party">
                <xsl:choose>
                    <xsl:when test="contains(., 'scopus')">
                        <identifier type="scopus">
                            <xsl:value-of select="."/>
                        </identifier>
                    </xsl:when>
                    <xsl:when test="contains(., 'researcherid')">
                        <identifier type="uri">
                            <xsl:value-of select="."/>
                        </identifier>
                    </xsl:when>
                    <xsl:when test="contains(., 'orcid')">
                        <identifier type="orcid">
                            <xsl:value-of select="."/>
                        </identifier>
                    </xsl:when>
                    <xsl:when test="contains(., 'nla')">
                        <identifier type="AU-ANL:PEAU">
                            <xsl:value-of select="."/>
                        </identifier>
                    </xsl:when>
                    <xsl:otherwise>
                        <identifier type="uri">
                            <xsl:value-of select="."/>
                        </identifier>
                    </xsl:otherwise>
                </xsl:choose>
                <relation type="hasAssociationWith"/>
            </relatedInfo>           
        </xsl:for-each>
    </xsl:template-->

    <xsl:template match="abstract">
        <description type="full">
            <xsl:value-of select="."/>
        </description>
    </xsl:template>

    <xsl:template match="field[@name='addl_info']/value">
        <description type="note">
            <xsl:value-of select="."/>
        </description>
    </xsl:template>

    <xsl:template match="field[@name='rights']/value">
        <rights>
            <rightsStatement>
                <xsl:value-of select="."/>
            </rightsStatement>
        </rights>
    </xsl:template>
    
    <xsl:template match="field[@name='distribution_license']/value">
        
        <rights>
            <licence>
                <xsl:choose>
                    <xsl:when test="contains(., 'http')">
                        <xsl:attribute name="rightsUri">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                        <xsl:if test="contains(., 'creativecommons')">
                            <xsl:if test="$global_debug"><xsl:message select="concat('creativecommons: ', .)"/></xsl:if>
                            <xsl:analyze-string select="." regex="(http://creativecommons.org/licenses/)(.*)(/\d)">
                                <xsl:matching-substring>
                                    <xsl:if test="string-length(regex-group(2)) > 0">
                                        <xsl:attribute name="type">
                                            <xsl:value-of select="upper-case(concat('cc-', regex-group(2)))"/>
                                        </xsl:attribute>
                                    </xsl:if>
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
            </licence>
        </rights>
    </xsl:template>

    <xsl:template match="field[@name='coverage']/value">
        <coverage>
            <temporal type="text">
                    <xsl:value-of select="."/>
                </temporal>
        </coverage>
    </xsl:template>

    <!--
    <xsl:template match="coverage[starts-with(.,'Spatial: ')]">
        <coverage>
            <spatial type="text">
                <xsl:value-of select="substring-after(.,'Spatial:')"/>
            </spatial>
        </coverage>
    </xsl:template>
    -->

    <xsl:template match="field[@name='longitude']">
        <location>
            <spatial type="kmlPolyCoords">
                <xsl:value-of select="value"/>,<xsl:value-of select="preceding-sibling::field[@name='latitude']/value"/>
            </spatial>
        </location>
    </xsl:template>

    <xsl:template match="keywords">

        <xsl:for-each select="keyword">
            <subject type="local">
                <xsl:value-of select="."/>
            </subject>
        </xsl:for-each>

    </xsl:template>

    <xsl:template match="disciplines">

        <xsl:for-each select="discipline">
            <subject type="local">
                <xsl:value-of select="."/>
            </subject>
        </xsl:for-each>

    </xsl:template>

    <xsl:template match="field[@name='for_code']">

        <xsl:for-each select="value">
            <subject type="anzsrc-for">
                <xsl:value-of select="."/>
            </subject>
        </xsl:for-each>

    </xsl:template>

    <xsl:template match="field[@name='custom_citation']/value">

        <citationInfo>
            <fullCitation>
                <xsl:value-of select="."/>
            </fullCitation>
        </citationInfo>

    </xsl:template>
    
    <xsl:template match="native-url">
        <xsl:if test="contains(., 'viewcontent')">
            <!--location>
                <address>
                <electronic type="url" target="directDownload">
                    <value>
                        <xsl:value-of select="."/>
                    </value>
                </electronic>
            </address>
            </location-->
            <rights>
                <accessRights type="open"/>
            </rights>
        </xsl:if>
    </xsl:template>
    

    <xsl:template match="field[@name='related_content']" mode="collection">

        <xsl:analyze-string select="value" regex="href=&quot;(http.+?)&quot;">
          <xsl:matching-substring>
            <relatedInfo type="publication">
                <identifier type="uri">
                    <xsl:value-of select="regex-group(1)"/>
                </identifier>
                <relation type="isReferencedBy"/>
            </relatedInfo>
          </xsl:matching-substring>
        </xsl:analyze-string>

    </xsl:template>
    
    <xsl:template match="field[@name='grant_num']" mode="collection">
       <xsl:variable name="funder">
           <xsl:analyze-string select="../field[@name='funding']" regex="(&gt;)(.*)(&lt;)">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(2)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
       </xsl:variable>
        
       <xsl:choose>
            <xsl:when test="
                (lower-case($funder) = 'australian research council') or
                (lower-case($funder) = 'arc')">
                <relatedInfo type="activity">
                    <identifier type="purl">
                        <xsl:value-of select="concat('http://purl.org/au-research/grants/arc/', normalize-space(.))"/>
                    </identifier>
                    <relation type="isOutputOf"/>
                </relatedInfo>
                
            </xsl:when>
            <xsl:when test="
                (lower-case($funder) = 'National Health and Medical Research Council ') or
                (lower-case($funder) = 'nhmrc')">
                <relatedInfo type="activity">
                    <identifier type="purl">
                        <xsl:value-of select="concat('http://purl.org/au-research/grants/nhmrc/', normalize-space(.))"/>
                    </identifier>
                    <relation type="isOutputOf"/>
                </relatedInfo>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="field[@name='related_content']" mode="activity">
        
        <xsl:analyze-string select="value" regex="href=&quot;(http.+?)&quot;">
            <xsl:matching-substring>
                <relatedInfo type="publication">
                    <identifier type="uri">
                        <xsl:value-of select="regex-group(1)"/>
                    </identifier>
                    <relation type="hasOutput"/>
                </relatedInfo>
            </xsl:matching-substring>
        </xsl:analyze-string>
        
    </xsl:template>
    
    <xsl:template match="field[@name='grant_num']" mode="activity">
        <xsl:variable name="funder">
            <xsl:analyze-string select="../field[@name='funding']" regex="(&gt;)(.*)(&lt;)">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(2)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="
                (lower-case($funder) = 'australian research council') or
                (lower-case($funder) = 'arc')">
                <identifier type="purl">
                    <xsl:value-of select="concat('http://purl.org/au-research/grants/arc/', normalize-space(.))"/>
                </identifier>
                
            </xsl:when>
            <xsl:when test="
                (lower-case($funder) = 'National Health and Medical Research Council ') or
                (lower-case($funder) = 'nhmrc')">
                <identifier type="purl">
                    <xsl:value-of select="concat('http://purl.org/au-research/grants/nhmrc/', normalize-space(.))"/>
                </identifier>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    

    <xsl:template match="field[@name='project_links']" mode="activity">

        <xsl:analyze-string select="value" regex="href=&quot;(http.+?)&quot;">
          <xsl:matching-substring>
            <relatedInfo type="website">
                <identifier type="uri">
                    <xsl:value-of select="regex-group(1)"/>
                </identifier>
                <relation type="hasAssociationWith"/>
            </relatedInfo>
          </xsl:matching-substring>
        </xsl:analyze-string>

    </xsl:template>
    
    <xsl:template match="field[@name='project_links']" mode="collection">
        
        <!--xsl:analyze-string select="value" regex="href=&quot;(http.+?)&quot;">
            <xsl:matching-substring>
                <relatedInfo type="website">
                    <identifier type="uri">
                        <xsl:value-of select="regex-group(1)"/>
                    </identifier>
                    <relation type="hasAssociationWith"/>
                </relatedInfo>
            </xsl:matching-substring>
        </xsl:analyze-string-->
        
    </xsl:template>

    <xsl:template match="field[@name='contact']">

        <xsl:for-each select="value">
            <location>
                <address>
                    <electronic type="email">
                        <value>
                            <xsl:value-of select="."/>
                        </value>
                    </electronic>
                </address>
            </location>
        </xsl:for-each>

    </xsl:template>

    <xsl:template match="coverpage-url">
        <location>
            <address>
                <electronic type="url">
                    <value>
                        <xsl:value-of select="."/>
                    </value>
                </electronic>
            </address>
        </location>
    </xsl:template>
    <!--
    <xsl:template match="oai:record" mode="party">
        
        <xsl:for-each select="authors/author">
            
            <xsl:variable name="name" select="normalize-space(.)"/>
            
            <xsl:if test="string-length($name)> 0">
                
                <xsl:variable name="htmlFormatted">
                    <xsl:variable name="html" select="../identifier[contains(text(), '&lt;')]"/>
                    <xsl:if test="string-length($html)> 0">
                        <xsl:value-of select="fn:replace(fn:replace(fn:replace($html, '&lt;br /&gt;' , ''), '&lt;br/&gt;' , ''), '&amp;', '&amp;amp;')"/>
                    </xsl:if>
                </xsl:variable>
                
                <xsl:message select="concat('htmlFormatted: ', $htmlFormatted)"/>
                
                <xsl:variable name="organisation_sequence" select="custom:getOrganisationForName_sequence(normalize-space(.), $htmlFormatted)" as="xs:string*"/>
                
                <xsl:variable name="identifier_sequence" select="custom:getIdentifiersForName_sequence($name, $htmlFormatted)" as="xs:string*"/>
                
                <xsl:variable name="objectType_sequence" as="xs:string*">
                    <xsl:choose>
                        <xsl:when test="contains(., ',')">
                            <xsl:text>party</xsl:text>
                            <xsl:text>person</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>party</xsl:text>
                            <xsl:text>group</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable> 
                
                <xsl:variable name="object" select="$objectType_sequence[1]"/>
                <xsl:variable name="type" select="$objectType_sequence[2]"/>
                
                <xsl:if test="string-length(normalize-space(.))> 0">
                    <registryObject group="{$global_group}">
                        <key>
                            <xsl:value-of select="custom:formatKey(.)"/>
                        </key>
                        <originatingSource>
                            <xsl:value-of select="$global_originatingSource"/>
                        </originatingSource>
                        
                        <xsl:element name="{$object}">
                            <xsl:attribute name="type" select="$type"/>
                            <xsl:if test="count($identifier_sequence)> 0">
                                <xsl:for-each select="distinct-values($identifier_sequence)">
                                    <xsl:if test="string-length(normalize-space(.))> 0">
                                        <xsl:message select="concat('Identifier for ', $name, ': ', .)"/>
                                        <identifier type="{custom:identifierType(.)}">
                                            <xsl:value-of select="."/>
                                        </identifier>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:if>
                            <name type="primary">
                                <namePart>
                                    <xsl:value-of select="$name"/>
                                </namePart>
                            </name>
                            
                            
                            <xsl:for-each select="distinct-values($organisation_sequence)">
                                <xsl:if test="string-length(normalize-space(.))> 0">
                                    <relatedObject>
                                        <key>
                                            <xsl:value-of select="custom:formatKey(.)"/>
                                        </key>
                                        <relation type="isAssociatedWith"/>
                                    </relatedObject>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:element>
                    </registryObject>
                    
                    <xsl:for-each select="distinct-values($organisation_sequence)">
                        <xsl:variable name="organisationName" select="normalize-space(.)"/>
                        
                        <xsl:message select="concat('Organisation for ', $name, ': ', $organisationName)"/>
                        
                        <xsl:if test="string-length($organisationName)> 0">
                            
                            <registryObject group="{$global_group}">
                                <key>
                                    <xsl:value-of select="custom:formatKey(.)"/>
                                </key>
                                <originatingSource>
                                    <xsl:value-of select="$global_originatingSource"/>
                                </originatingSource>
                                
                                <party type="group">
                                    <name type="primary">
                                        <namePart>
                                            <xsl:value-of select="$organisationName"/>
                                        </namePart>
                                    </name>
                                </party>
                            </registryObject>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    -->
    
    <xsl:function name="custom:getKey">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="handleOK" as="xs:boolean"/>
        
        <xsl:choose>
            <xsl:when test="
                (string-length($node//field[@name='identifier']/value)> 0) and
                (boolean(not(contains($node//field[@name='identifier']/value, 'handle.net'))) or
                boolean($handleOK) = true())">
                <xsl:value-of select="$node//field[@name='identifier']/value"/>
            </xsl:when>
            <xsl:when test="string-length($node//articleid)> 0">
                <xsl:value-of select="concat('ecu/articleid/', $node//articleid)"/>
            </xsl:when>
            <xsl:when test="string-length($node//context-key)> 0">
                <xsl:value-of select="concat('ecu/context-key/', $node//context-key)"/>
            </xsl:when>
            <xsl:when test="string-length($node//coverpage-url)> 0">
                <xsl:value-of select="$node//coverpage-url"/>
            </xsl:when>
            <xsl:when test="string-length($node//title)> 0">
                <xsl:value-of select="translate(normalize-space($node//title), ' ', '')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="generate-id($node)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
   
   <xsl:function name="custom:getId_TypeValuePair" as="xs:string*">
       <xsl:param name="name" as="xs:string"/>
       <xsl:choose>
           <xsl:when test="lower-case($name) = 'edith cowan university'">
               <xsl:text>AU-ANL:PEAU</xsl:text>
               <xsl:text>http://nla.gov.au/nla.party-578358</xsl:text>
           </xsl:when>
       </xsl:choose>
   </xsl:function>
    
    <xsl:function name="custom:getIdentifiersForName_sequence" as="xs:string*">
        <xsl:param name="soughtName" as="xs:string"/>
        <xsl:param name="html" as="xs:string"/>
        
        <xsl:if test="string-length($html)> 0">
            <xsl:variable name="unescapedContent" select="saxon:parse(concat('&lt;root&gt;', $html, '&lt;/root&gt;'))" as="document-node()*"/>
            <xsl:if test="count($unescapedContent)> 0">
                <!--xsl:message select="concat('unescapedContent ', $unescapedContent)"/-->
                <xsl:variable name="namePosition_sequence" as="xs:integer*">
                    <xsl:for-each select="$unescapedContent/root/p">
                        <xsl:variable name="personPosition" select="position()" as="xs:integer"/>
                        <xsl:if test="$global_debug">
                            <xsl:for-each select="distinct-values(strong)">
                                <xsl:message select="concat('strong: ', ., ' at pos ', position())"/>
                            </xsl:for-each>
                        </xsl:if>
                        <!-- logic to follow is an attempt to check that we actually have something like a name -->
                        
                        <xsl:variable name="personName">
                            <xsl:choose>
                                <xsl:when test="count(strong) > 1">
                                    <xsl:value-of select="fn:string-join(strong, ' ')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="strong"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        
                        <xsl:if test="$global_debug"><xsl:message select="concat('personName: ', $personName)"/></xsl:if>
                        <xsl:if test="(string-length(normalize-space($personName)) > 2) and
                            (contains(normalize-space($personName), ' ') or contains(normalize-space($personName), ','))">
                            <xsl:value-of select="$personPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                
                <xsl:if test="$global_debug">
                    <xsl:for-each select="$namePosition_sequence">
                        <xsl:message select="concat('$namePosition_sequence entry: ', ., ' at position: ', position())"/>
                    </xsl:for-each>
                </xsl:if>
                
                <xsl:variable name="currentPersonPositionRange_sequence" as="xs:integer*">
                    <xsl:for-each select="$unescapedContent/root/p">
                        <xsl:variable name="currentPPosition" select="position()"  as="xs:integer"/>
                        <xsl:variable name="lastPPosition" select="last()"  as="xs:integer"/>
                        <xsl:variable name="currentName" select="custom:getName(.)"/>
                        <xsl:if test="string-length($currentName)> 0">
                            <xsl:if test="string-length(.)> 0 and (contains(., ' ') or contains(., ','))">
                                
                                <xsl:if test="boolean(custom:nameMatch($soughtName, $currentName)) = true()">
                                    <xsl:if test="$global_debug"><xsl:message select="concat('Match found - ', $soughtName)"/></xsl:if>
                                    
                                    <!-- Return first index in range -->
                                    <xsl:copy-of select="$currentPPosition"/>
                                    <xsl:for-each select="distinct-values($namePosition_sequence)">
                                        <xsl:variable name="iterPersonPosition" select="." as="xs:integer"/>
                                        <xsl:variable name="posInt" select="position()" as="xs:integer"/>
                                        <xsl:if test="$global_debug">
                                            <xsl:message select="concat('iterPersonPosition: ', $iterPersonPosition)"/>
                                            <xsl:message select="concat('count($namePosition_sequence): ', count($namePosition_sequence))"/>
                                            <xsl:message select="concat('$posInt: ', number($posInt))"/>
                                        </xsl:if>
                                        <xsl:if test="number($iterPersonPosition) = number($currentPPosition)">
                                            <!-- Return last index in range -->
                                            <xsl:choose>
                                                <!--xsl:when test="$posInt &lt; (count($namePosition_sequence) - 1)"-->
                                                <xsl:when test="count($namePosition_sequence) > number($posInt)">
                                                    <xsl:if test="$global_debug"><xsl:message select="concat('Returning $namePosition_sequence[number($posInt)+1]: ', $namePosition_sequence[number($posInt)+1])"/></xsl:if>
                                                    <xsl:copy-of select="$namePosition_sequence[number($posInt)+1]"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:if test="$global_debug"><xsl:message select="concat('Returning $lastPPosition + 1: ', $lastPPosition + 1)"/></xsl:if>
                                                    <xsl:copy-of select="$lastPPosition + 1"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:if>
                                    </xsl:for-each>
                                </xsl:if>
                            </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                
                <xsl:if test="count($currentPersonPositionRange_sequence)> 0">
                    <xsl:if test="$global_debug">
                        <xsl:message select="concat('count($currentPersonPositionRange_sequence): ', count($currentPersonPositionRange_sequence))"/>
                        <xsl:message select="concat('$currentPersonPositionRange_sequence[1]: ', $currentPersonPositionRange_sequence[1])"/>
                        <xsl:message select="concat('$currentPersonPositionRange_sequence[2]: ', $currentPersonPositionRange_sequence[2])"/>
                    </xsl:if>
                    
                    <xsl:for-each select="$unescapedContent/root/p">
                        <xsl:variable name="currentPPosition" select="position()"  as="xs:integer"/>
                        <xsl:if test="$global_debug"><xsl:message select="concat('$currentPPosition: ', $currentPPosition)"/></xsl:if>
                        <xsl:if test="($currentPersonPositionRange_sequence[2]> $currentPPosition) and
                            ($currentPPosition >= $currentPersonPositionRange_sequence[1])">
                            <xsl:for-each select="a/@href">
                                <xsl:if test="string-length(normalize-space(.))> 0">
                                    <xsl:if test="$global_debug"><xsl:message select="concat('a/@href: ', .)"/></xsl:if>
                                    <xsl:value-of select="normalize-space(.)"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
            </xsl:if>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="custom:getOrganisationForName_sequence" as="xs:string*">
        <xsl:param name="soughtName" as="xs:string"/>
        <xsl:param name="html" as="node()"/>
        
        <!--xsl:message select="concat('html: ', $html)"/-->
        
        <xsl:if test="string-length($html)> 0">
            <xsl:variable name="unescapedContent" select="saxon:parse(concat('&lt;root&gt;', $html, '&lt;/root&gt;'))" as="document-node()*"/>
            <xsl:if test="count($unescapedContent)> 0">
                <!--xsl:message select="concat('unescapedContent ', $unescapedContent)"/-->
                <xsl:for-each select="$unescapedContent/root/p">
                    <xsl:if test="count(strong)> 0">
                        <xsl:variable name="currentName" select="custom:getName(.)"/>
                        <xsl:if test="string-length($currentName)> 0 and (contains($currentName, ' ') or contains($currentName, ','))">
                            <xsl:if test="boolean(custom:nameMatch($soughtName, $currentName)) = true()">
                                <xsl:message select="concat('Match $currentName ', $currentName)"/>
                                <xsl:variable name="organisation_sequence" select="em" as="xs:string*"/>
                                <xsl:if test="count($organisation_sequence)> 0">
                                    <xsl:if test="count($organisation_sequence)> 0">
                                        <xsl:copy-of select="$organisation_sequence"/>
                                    </xsl:if>
                                </xsl:if>
                            </xsl:if>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="custom:identifierType" as="xs:string">
        <xsl:param name="identifier" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="contains(lower-case($identifier), 'nla.party')">
                <xsl:text>AU-ANL:PEAU</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'scopus')">
                <xsl:text>scopus</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'orcid')">
                <xsl:text>orcid</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'doi')">
                <xsl:text>doi</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>uri</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <xsl:function name="custom:formatKey">
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
        <xsl:value-of select="concat($global_baseURI, '/', $temp)"/>
    </xsl:function>
    
    <xsl:function name="custom:getName">
        <xsl:param name="node" as="node()"/>
        <xsl:variable name="name_sequence" as="xs:string*">
            <xsl:for-each select="$node/strong">
                <xsl:if test="string-length(normalize-space(.))> 0">
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="fn:string-join($name_sequence, ' ')"/>
    </xsl:function>
    
    <xsl:function name="custom:formatName">
        <xsl:param name="name"/>
        <xsl:choose>
            <xsl:when test="contains($name, ', ')">
                <xsl:value-of select="concat(normalize-space(substring-after($name, ',')), ' ', normalize-space(substring-before($name, ',')))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="custom:nameMatch" as="xs:boolean">
        <xsl:param name="name"/>
        <xsl:param name="match"/>
        
        <xsl:variable name="fname" select="tokenize(custom:formatName($name), ' ')[1]"/>
        <xsl:variable name="fnameMatch" select="tokenize(custom:formatName($match), ' ')[1]"/>
        <xsl:variable name="sname" select="tokenize(custom:formatName($name), ' ')[last()]"/>
        <xsl:variable name="snameMatch" select="tokenize(custom:formatName($match), ' ')[last()]"/>
        
        <xsl:choose>
            <xsl:when test="
                (($fname = $fnameMatch) or contains($fname, $fnameMatch) or contains($fnameMatch, $fname)) and 
                ($sname = $snameMatch)">
                <xsl:copy-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template match="node() | text() | @*"/>

</xsl:stylesheet>
