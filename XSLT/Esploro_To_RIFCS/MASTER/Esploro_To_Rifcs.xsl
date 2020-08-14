<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://www.loc.gov/MARC21/slim">
    

    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'Southern Cross University'"/>
    <xsl:param name="global_baseURI" select="'epubs.scu.edu.au'"/>
    <xsl:param name="global_group" select="'Southern Cross University'"/>
    <xsl:param name="global_publisherName" select="'Southern Cross University'"/>
    
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
            <xsl:apply-templates select="//oai:record/oai:metadata/*:record/*:data" mode="collection"/>
            <!-- xsl:apply-templates select="//oai:record/oai:metadata/*:document-export/*:documents/*:document" mode="activity"/-->
            <xsl:apply-templates select="//oai:record/oai:metadata/*:record/*:data" mode="party"/>
        </registryObjects>
    </xsl:template>
  
    <xsl:template match="data" mode="collection">
       
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <key>
                <xsl:value-of select="custom:registryObjectKeyFromString(concat(title, articleid, context-key))"/>
            </key>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            <xsl:element name="collection">
                
                <xsl:attribute name="type" select="'dataset'"/>
             
                <xsl:apply-templates select="@todo[string-length(.) > 0]" mode="collection_date_modified"/>
                
                <xsl:apply-templates select="../../../oai:header/oai:datestamp[string-length(.) > 0]" mode="collection_date_accessioned"/>
                
                <xsl:apply-templates select="identifier.other[string-length(.) > 0]" mode="collection_identifier"/>
                
                <xsl:apply-templates select="identifier.doi[string-length(.) > 0]" mode="collection_identifier_doi"/>
                
                <xsl:apply-templates select="title[string-length(.) > 0]" mode="collection_name"/>
                
                <xsl:choose>
                    <xsl:when test="string-length(identifier.doi) > 0">
                        <xsl:apply-templates select="identifier.doi[string-length(.) > 0]" mode="collection_location_doi"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="originalRepository/coverpage-url[string-length(.) > 0]" mode="collection_location"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                
                <xsl:if test="string-length(coverpage-url) = 0">
                    <xsl:apply-templates select="submission-path[(string-length(.) > 0)]" mode="collection_location"/>
                </xsl:if>
                
        <xsl:apply-templates select="authors/author[(string-length(fname) > 0) or (string-length(lname) > 0)]" mode="collection_relatedObject_individual"/>
               
                <xsl:apply-templates select="authors/author[(string-length(organization) > 0)]" mode="collection_relatedObject_organization"/>
               
                <xsl:apply-templates select="keywords/keyword[string-length(.) > 0]" mode="collection_subject"/>
                
                <xsl:apply-templates select="fields/field[@name='for'][string-length(.) > 0]" mode="collection_subject_for"/>
               
                <xsl:apply-templates select="description.abstract[string-length(.) > 0]" mode="collection_description_full"/>
                
                <xsl:apply-templates select="fields/field[@name='geolocate'][string-length(.) > 0]" mode="collection_coverage_spatial_text"/>
               
                <xsl:apply-templates select="." mode="collection_coverage_spatial_point"/>
               
                <xsl:apply-templates select="fields/field[@name='orcid_id'][string-length(.) > 0]" mode="collection_relatedInfo"/>
                
                <xsl:apply-templates select="fields/field[contains(@name, 'grant_num')][string-length(.) > 0]" mode="collection_relatedInfo"/>
                
                <xsl:apply-templates select="fields/field[@name='access'][string-length(.) > 0]" mode="collection_rights_statement"/>
                
                <xsl:apply-templates select="fields/field[@name='access'][string-length(.) > 0]" mode="collection_rights_access"/>
                
                
                <xsl:apply-templates select="submission-date[string-length(.) > 0]" mode="collection_dates_submitted"/> 
                
                <xsl:apply-templates select="fields/field[@name='embargo_date'][string-length(.) > 0]" mode="collection_dates_available"/>
                
                <xsl:apply-templates select="fields/field[@name='publication_date'][string-length(.) > 0]" mode="collection_dates_issued"/>  
             
            </xsl:element>
        </registryObject>
    </xsl:template>
   
    
     <xsl:template match="@todo" mode="collection_date_modified">
        <xsl:attribute name="dateModified" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="oai:datestamp" mode="collection_date_accessioned">
        <xsl:attribute name="dateAccessioned" select="normalize-space(.)"/>
    </xsl:template>
       
    <xsl:template match="identifier.other" mode="collection_identifier">
        <identifier type="{custom:getIdentifierType(.)}">
            <xsl:choose>
                <xsl:when test="starts-with(. , '10.')">
                    <xsl:value-of select="concat('http://doi.org/', .)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </identifier>    
    </xsl:template>
    
    <!--xsl:template match="identifier.doi" mode="collection_identifier_doi">
        <xsl:for-each select="value">
            <xsl:analyze-string select="." regex="(&quot;http).+?(&quot;)">
                <xsl:matching-substring>
                    <identifier type="{custom:getIdentifierType(regex-group(0))}">
                        <xsl:value-of select="translate(translate(regex-group(0), '&quot;', ''), '&lt;', '')"/>
                    </identifier>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:for-each>
    </xsl:template-->
    
    <xsl:template match="identifier.doi" mode="collection_identifier_doi">
        <identifier type="doi">
            <xsl:value-of select="concat('http://doi.org/', .)"/>
        </identifier>
    </xsl:template>
    
     <xsl:template match="coverpage-url" mode="collection_location">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:choose>
                            <xsl:when test="starts-with(. , '10.')">
                                <xsl:value-of select="concat('http://doi.org/', .)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="identifier.doi" mode="collection_location_doi">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:choose>
                            <xsl:when test="starts-with(. , '10.')">
                                <xsl:value-of select="concat('http://doi.org/', .)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="submission-path" mode="collection_location">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="concat($global_baseURI, normalize-space(.))"/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="title" mode="collection_name">
        <name type="primary">
            <namePart>
                <xsl:value-of select="normalize-space(.)"/>
            </namePart>
        </name>
    </xsl:template>
    
   <xsl:template match="author" mode="collection_relatedObject_individual">
        <xsl:if test="(string-length(fname) > 0) or (string-length(lname) > 0)">
            <relatedObject>
                <key>
                    <xsl:value-of select="custom:registryObjectKeyFromString(concat(fname, lname))"/> 
                </key>
                <relation type="hasCollector"/>
            </relatedObject>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="author" mode="collection_relatedObject_organization">
        <relatedObject>
            <key>
                <xsl:value-of select="custom:registryObjectKeyFromString(organization)"/> 
            </key>
            <relation type="hasAssociationWith"/>
        </relatedObject>
        </xsl:template>
    
    <xsl:template match="keyword" mode="collection_subject">
        <subject type="local">
            <xsl:value-of select="normalize-space(.)"/>
        </subject>
    </xsl:template>
    
    <xsl:template match="field[@name='for']" mode="collection_subject_for">
        <xsl:for-each select="value">
            <xsl:variable name="code">
                <xsl:analyze-string select="normalize-space(.)" regex="[0-9]">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(0)"/>       
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:if test="string-length($code) > 0">
                <subject type="anzsrc-for">
                    <xsl:value-of select="$code"/>
                </subject>
            </xsl:if>
        </xsl:for-each>
   </xsl:template>
   
   <xsl:template match="field[@name='geolocate']" mode="collection_coverage_spatial_text">
        <coverage>
            <spatial type="text">
                <xsl:value-of select="normalize-space(.)"/>
            </spatial>
        </coverage>
   </xsl:template>
   
   <xsl:template match="data" mode="collection_coverage_spatial_point">
      <xsl:if test="(string-length(fields/field[@name='latitude']) > 0) and (string-length(fields/field[@name='longitude']) > 0)">
            <coverage>
                <spatial type="kmlPolyCoords">
                    <xsl:value-of select="concat(normalize-space(fields/field[@name='longitude']), ',', normalize-space(fields/field[@name='latitude']))"/>
                </spatial>
            </coverage>
        </xsl:if>
   </xsl:template>
   
   <xsl:template match="field[@name='orcid_id']" mode="collection_relatedInfo">
        <relatedInfo type="party">
            <identifier type='orcid'>
                <xsl:value-of select="normalize-space(.)"/>
            </identifier>
        </relatedInfo>
   </xsl:template>
   
   <xsl:template match="field[contains(@name, 'grant_num')]" mode="collection_relatedInfo">
       <relatedInfo type="activity">
           <xsl:choose>
                <xsl:when test="contains(., '/')">
                    <identifier type="{substring-before(normalize-space(.),'/')}">
                         <xsl:value-of select="substring-after(normalize-space(.),'/')"/>
                     </identifier>
                     <relation type="isOutputOf"/>
                 </xsl:when>
                 <xsl:otherwise>
                     <identifier type="global">
                         <xsl:value-of select="normalize-space(.)"/>
                     </identifier>
                     <relation type="isOutputOf"/>
                 </xsl:otherwise>
            </xsl:choose>
       </relatedInfo>
   </xsl:template>
  
   <xsl:template match="field[@name='access']" mode="collection_rights_access">
        <rights>
            <accessRights>
                <xsl:choose>
                    <xsl:when test="contains(lower-case(.), 'open access')">
                        <xsl:attribute name="type" select="'open'"/>
                    </xsl:when>
                    <xsl:when test="contains(lower-case(.), 'mediated')">
                        <xsl:attribute name="type" select="'conditional'"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="string-length(../field[@name='comments'])">
                    <xsl:value-of select="normalize-space(../field[@name='comments'])"/>
                </xsl:if>
            </accessRights>
        </rights>
    </xsl:template>
    
    <xsl:template match="field[@name='access']" mode="collection_rights_statement">
        <rights>
            <rightsStatement>
                <xsl:value-of select="normalize-space(.)"/>
            </rightsStatement>
        </rights>
    </xsl:template>
    
    <xsl:template match="description.abstract" mode="collection_description_full">
        <description type="full">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <xsl:template match="submission-date" mode="collection_dates_submitted">
        <dates type="submitted">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="normalize-space(.)"/>
            </date>
        </dates>
    </xsl:template>  
    
    <xsl:template match="field[@name='embargo_date']" mode="collection_dates_available">
        <dates type="available">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="normalize-space(.)"/>
            </date>
        </dates>    
    </xsl:template>
    
    <xsl:template match="field[@name='publication_date']" mode="collection_dates_issued">
        <dates type="issued">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="normalize-space(.)"/>
            </date>
        </dates>
    </xsl:template>  
             
     <xsl:template match="data" mode="party">
     
        <xsl:apply-templates select="authors/author[(string-length(fname) > 0) or (string-length(lname) > 0)]" mode="party_individual"/>
        <xsl:apply-templates select="authors/author[(string-length(institution) > 0)]" mode="party_institution"/>
        <xsl:apply-templates select="authors/author[(string-length(organization) > 0)]" mode="party_organization"/>
        
    </xsl:template>
    
    <xsl:template match="author" mode="party_individual">
       
            <registryObject>
                 <xsl:attribute name="group"><xsl:value-of select="$global_group"/></xsl:attribute>
                 <key>
                      <xsl:value-of select="custom:registryObjectKeyFromString(concat(fname, lname))"/>
                 </key>
                 <originatingSource><xsl:value-of select="$global_originatingSource"/></originatingSource>
                 <party>
                     
                     <xsl:attribute name="type" select="'person'"/>
                     
                     <name type="primary">
                         <xsl:if test="string-length(fname)> 0">
                             <namePart type="given">
                                 <xsl:value-of select="fname"/>
                             </namePart> 
                         </xsl:if>
                         <xsl:if test="string-length(lname)> 0">
                             <namePart type="family">
                                 <xsl:value-of select="lname"/>
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
                           <relatedObject>
                               <key>
                                    <xsl:value-of select="custom:registryObjectKeyFromString(institution)"/>
                               </key>
                               <relation type="isMemberOf"/>
                           </relatedObject>
                     </xsl:if>
                     
                     <!--xsl:for-each select="ancestor::data/fields/field[@name='grantid']">
                        <xsl:if test="string-length(normalize-space(.)) > 0">
                            <relatedInfo type="activity">
                                <identifier type="purl">
                                    <xsl:value-of select="normalize-space(.)"/>
                                </identifier>
                                <relation type="isParticipantIn"/>
                            </relatedInfo>
                        </xsl:if>
                     </xsl:for-each-->
                    
                 </party>
             </registryObject>
    </xsl:template>
             
             
    <xsl:template match="author" mode="party_organization">
       
             <registryObject>
                 <xsl:attribute name="group"><xsl:value-of select="$global_group"/></xsl:attribute>
                 <key>
                     <xsl:value-of select="custom:registryObjectKeyFromString(organization)"/>
                 </key>
                 <originatingSource><xsl:value-of select="$global_originatingSource"/></originatingSource>
                 <party>
                     
                     <xsl:attribute name="type" select="'group'"/>
                     
                     <name type="primary">
                        <namePart>
                            <xsl:value-of select="organization"/>
                        </namePart>
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
                 </party>
             </registryObject>
    </xsl:template>
    
    <xsl:template match="author" mode="party_institution">
       
             <registryObject>
                 <xsl:attribute name="group"><xsl:value-of select="$global_group"/></xsl:attribute>
                 <key>
                    <xsl:value-of select="custom:registryObjectKeyFromString(institution)"/>
                 </key>
                 <originatingSource><xsl:value-of select="$global_originatingSource"/></originatingSource>
                 <party>
                     
                     <xsl:attribute name="type" select="'group'"/>
                     
                     <name type="primary">
                        <namePart>
                            <xsl:value-of select="institution"/>
                        </namePart>
                     </name>
                     
                 </party>
             </registryObject>
    </xsl:template>
      
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
   
    

</xsl:stylesheet>
    
