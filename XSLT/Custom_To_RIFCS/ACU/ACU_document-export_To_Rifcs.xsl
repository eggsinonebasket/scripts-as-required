<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    

    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'Australian Catholic University'"/>
    <xsl:param name="global_baseURI" select="'researchbank.acu.edu.au'"/>
    <xsl:param name="global_group" select="'Australian Catholic University'"/>
    <xsl:param name="global_publisherName" select="'Australian Catholic University'"/>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
            <xsl:apply-templates select="//oai:record/oai:metadata/*:document-export/*:documents/*:document" mode="collection"/>
            <!-- xsl:apply-templates select="//oai:record/oai:metadata/*:document-export/*:documents/*:document" mode="activity"/-->
            <xsl:apply-templates select="//oai:record/oai:metadata/*:document-export/*:documents/*:document" mode="party"/>
        </registryObjects>
    </xsl:template>
  
    <xsl:template match="document" mode="collection">
       
        <xsl:variable name="key" select="concat($global_baseURI, ':', fn:generate-id(.))"/>
       
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <key>
                <xsl:value-of select="$key"/>
            </key>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            <xsl:element name="collection">
                
                <xsl:attribute name="type" select="'dataset'"/>
             
                <xsl:apply-templates select="@todo[string-length(.) > 0]" mode="collection_date_modified"/>
                
                <xsl:apply-templates select="../../../../oai:header/oai:datestamp[string-length(.) > 0]" mode="collection_date_accessioned"/>
                
                <xsl:apply-templates select="../../../../oai:header/oai:identifier[string-length(.) > 0]" mode="collection_identifier"/>
                
                <xsl:apply-templates select="fields/field[@name='doi'][string-length(.) > 0]" mode="collection_identifier_doi"/>
                
                <xsl:apply-templates select="coverpage-url[string-length(.) > 0]" mode="collection_location"/>
                
                <xsl:if test="string-length(coverpage-url) = 0">
                    <xsl:apply-templates select="submission-path[(string-length(.) > 0)]" mode="collection_location"/>
                </xsl:if>
                
                <xsl:apply-templates select="title[string-length(.) > 0]" mode="collection_name"/>
                
                <xsl:apply-templates select="authors/author[(string-length(fname) > 0) or (string-length(lname) > 0)]" mode="collection_relatedObject_individual"/>
               
                <xsl:apply-templates select="authors/author[(string-length(organization) > 0)]" mode="collection_relatedObject_organization"/>
               
                <xsl:apply-templates select="keywords/keyword[string-length(.) > 0]" mode="collection_subject"/>
                
                <xsl:apply-templates select="fields/field[@name='orcid_id'][string-length(.) > 0]" mode="collection_relatedInfo"/>
                
                <xsl:apply-templates select="fields/field[@name='grantid'][string-length(.) > 0]" mode="collection_relatedInfo"/>
                
                <xsl:apply-templates select="fields/field[@name='access'][string-length(.) > 0]" mode="collection_rights_access"/>
                
                <xsl:apply-templates select="fields/field[@name='comments'][string-length(.) > 0]" mode="collection_rights_statement"/>
                
                <xsl:apply-templates select="abstract[string-length(.) > 0]" mode="collection_description_full"/>
               
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
       
    <xsl:template match="oai:identifier" mode="collection_identifier">
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
    
    <xsl:template match="field[@name='doi']" mode="collection_identifier_doi">
         <xsl:for-each select="value">
            <xsl:analyze-string select="." regex="(&quot;http).+?(&quot;)">
                <xsl:matching-substring>
                    <identifier type="{custom:getIdentifierType(regex-group(0))}">
                        <xsl:value-of select="translate(translate(regex-group(0), '&quot;', ''), '&lt;', '')"/>
                    </identifier>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:for-each>
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
        <xsl:variable name="nameFormatted" select="concat(fname, ' ', lname)"/>
            
        <relatedObject>
            <key>
                <xsl:value-of select="custom:formatKey($nameFormatted)"/> 
            </key>
            <relation type="hasCollector"/>
        </relatedObject>
    </xsl:template>
    
    <xsl:template match="author" mode="collection_relatedObject_organization">
        <relatedObject>
            <key>
                <xsl:value-of select="custom:formatKey(custom:formatName(organization))"/> 
            </key>
            <relation type="hasCollector"/>
        </relatedObject>
        </xsl:template>
    
    <xsl:template match="keyword" mode="collection_subject">
        <subject type="local">
            <xsl:value-of select="normalize-space(.)"/>
        </subject>
    </xsl:template>
   
   <xsl:template match="field[@name='orcid_id']" mode="collection_relatedInfo">
        <relatedInfo type="party">
            <identifier type='orcid'>
                <xsl:value-of select="normalize-space(.)"/>
            </identifier>
        </relatedInfo>
   </xsl:template>
   
   <xsl:template match="field[@name='grantid']" mode="collection_relatedInfo">
        <relatedInfo type="activity">
            <identifier type='purl'>
                <xsl:value-of select="normalize-space(.)"/>
            </identifier>
            <relation type="isOutputOf"/>
        </relatedInfo>
   </xsl:template>
   
   <xsl:template match="field[@name='access']" mode="collection_rights_access">
        
        <rights>
            <accessRights>
                <xsl:if test="contains(lower-case(.), 'open access')">
                    <xsl:attribute name="type" select="'open'"/>
                </xsl:if>
                <xsl:value-of select="normalize-space(.)"/>
            </accessRights>
               
        </rights>
    </xsl:template>
    
    <xsl:template match="field[@name='comments']" mode="collection_rights_statement">
        <rights>
            <rightsStatement>
                <xsl:value-of select="normalize-space(.)"/>
            </rightsStatement>
        </rights>
    </xsl:template>
    
    <xsl:template match="abstract" mode="collection_description_full">
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
             
     <xsl:template match="document" mode="party">
     
        <xsl:apply-templates select="authors/author[(string-length(fname) > 0) or (string-length(lname) > 0)]" mode="party_individual"/>
        <xsl:apply-templates select="authors/author[(string-length(institution) > 0)]" mode="party_institution"/>
        <xsl:apply-templates select="authors/author[(string-length(organization) > 0)]" mode="party_organization"/>
        
    </xsl:template>
    
    <xsl:template match="author" mode="party_individual">
       
            <xsl:variable name="firstName" select="fname"/>
            <xsl:variable name="lastName" select="lname"/>
            
            <xsl:variable name="nameFormatted" select="concat($firstName, ' ', $lastName)"/>
            
            <registryObject>
                 <xsl:attribute name="group"><xsl:value-of select="$global_group"/></xsl:attribute>
                 <key>
                     <xsl:value-of select="custom:formatKey($nameFormatted)"/>
                 </key>
                 <originatingSource><xsl:value-of select="$global_originatingSource"/></originatingSource>
                 <party>
                     
                     <xsl:attribute name="type" select="'person'"/>
                     
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
                           <relatedObject>
                               <key>
                                    <xsl:value-of select="custom:formatKey(custom:formatName(institution))"/> 
                               </key>
                               <relation type="isMemberOf"/>
                           </relatedObject>
                     </xsl:if>
                     
                     <xsl:for-each select="ancestor::document/fields/field[@name='grantid']">
                        <xsl:if test="string-length(normalize-space(.)) > 0">
                            <relatedInfo type="activity">
                                <identifier type="purl">
                                    <xsl:value-of select="normalize-space(.)"/>
                                </identifier>
                                <relation type="isParticipantIn"/>
                            </relatedInfo>
                        </xsl:if>
                     </xsl:for-each>
                    
                 </party>
             </registryObject>
    </xsl:template>
             
             
    <xsl:template match="author" mode="party_organization">
       
             <registryObject>
                 <xsl:attribute name="group"><xsl:value-of select="$global_group"/></xsl:attribute>
                 <key>
                     <xsl:value-of select="custom:formatKey(organization)"/>
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
                     <xsl:value-of select="custom:formatKey(institution)"/>
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
    