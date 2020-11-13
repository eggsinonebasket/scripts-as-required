<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:custom="http://custom.nowhere.yet"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:esploroFunc="http://esploro.no.fixed.address"
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects"
    xpath-default-namespace="http://www.loc.gov/MARC21/slim">
   
    <xsl:import href="CustomFunctions.xsl"/>
    
    <xsl:param name="global_originatingSource" select="'{override required}'"/>
    <xsl:param name="global_baseURI" select="'{override required}'"/>
    <xsl:param name="global_group" select="'{override required}'"/>
    <xsl:param name="global_publisherName" select="'{override required}'"/>
    <xsl:param name="global_acronym" select="'{override required}'"/>
    
    
   <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
            <xsl:apply-templates select="//oai:record/oai:metadata/*:record/*:data" mode="collection"/>
            <xsl:apply-templates select="//oai:record/oai:metadata/*:record/*:data" mode="party"/>
            <xsl:apply-templates select="//oai:record/oai:metadata/*:record/*:data/*:fundingreferenceList/*:fundingreference" mode="activity"/>
        </registryObjects>
    </xsl:template>
  
    <xsl:template match="data" mode="collection">
       
        <registryObject>
            <xsl:attribute name="group" select="$global_group"/>
            <key>
                <!--xsl:value-of select="custom:registryObjectKeyFromString(concat(title, articleid, context-key))"/-->
                <xsl:value-of select="concat($global_acronym, custom:registryObjectKeyFromString(ancestor::oai:record/oai:header/oai:identifier))"/>
            </key>
            <originatingSource>
                <xsl:value-of select="$global_originatingSource"/>
            </originatingSource>
            <xsl:element name="collection">
                
                <xsl:attribute name="type" select="'dataset'"/>
             
                <xsl:apply-templates select="@todo[string-length(.) > 0]" mode="collection_date_modified"/>
                
                <xsl:apply-templates select="../../../oai:header/oai:datestamp[string-length(.) > 0]" mode="collection_date_accessioned"/>
                
                <xsl:apply-templates select="../../../oai:header/oai:identifier[string-length(.) > 0]" mode="collection_identifier"/>
                
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
                
                <xsl:apply-templates select="creators/creator[(string-length(givenname) > 0) or (string-length(familyname) > 0)]" mode="collection_relatedObject_individual"/>
               
                <xsl:apply-templates select="creators/creator[(string-length(organization) > 0)]" mode="collection_relatedObject_organization"/>
               
                <xsl:apply-templates select="contributors/contributor[(string-length(givenname) > 0) or (string-length(familyname) > 0)]" mode="collection_relatedObject_individual"/>
                
                <xsl:apply-templates select="contributors/contributor[(string-length(organization) > 0)]" mode="collection_relatedObject_organization"/>
                
                <xsl:apply-templates select="keywords[string-length(.) > 0]" mode="collection_subject"/>
                
                <xsl:apply-templates select="subject.anzfor[string-length(.) > 0]" mode="collection_subject_anzsrc_for"/>
                
                <xsl:apply-templates select="description.abstract[string-length(.) > 0]" mode="collection_description_full"/>
                
                <xsl:apply-templates select="description.other[string-length(.) > 0]" mode="collection_description_full"/>
                
                <xsl:apply-templates select="geoLocation/geoLocationPoints/geoLocationPoint[string-length(.) > 0]" mode="collection_coverage_spatial_point"/>
                
                <xsl:apply-templates select="geoLocation/geoLocationAddress/geoLocationAddres[string-length(.) > 0]" mode="collection_coverage_spatial_text"/>
                
                <xsl:apply-templates select="description.other[string-length(.) > 0]" mode="collection_description_full"/>
                
                <xsl:apply-templates select="fundingreferenceList/fundingreference[string-length(.) > 0]" mode="collection_relatedInfo"/>
                
                <xsl:apply-templates select="relationships/relationship[string-length(.) > 0]" mode="collection_relatedInfo"/>
                
                <xsl:apply-templates select="copyright[string-length(.) > 0]" mode="collection_rights_statement"/>
                
                <xsl:apply-templates select="license[string-length(.) > 0]" mode="collection_rights_license"/>
                
                <xsl:apply-templates select="rightsList/rights/rights[string-length(.) > 0]" mode="collection_rights_access"/>
                
                <xsl:apply-templates select="date.submitted[string-length(.) > 0]" mode="collection_dates_submitted"/> 
                
                <xsl:apply-templates select="date.available[string-length(.) > 0]" mode="collection_dates_available"/>
                
                <xsl:apply-templates select="date.published[string-length(.) > 0]" mode="collection_dates_issued"/>  
             
                <xsl:apply-templates select="date.collected[string-length(.) > 0]" mode="collection_dates_collected"/>  
                
                <xsl:apply-templates select="." mode="collection_citation"/>  
                
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
    
    <xsl:template match="oai:identifier" mode="collection_identifier">
        <identifier type="scu">
            <!--xsl:choose>
                <xsl:when test="contains(.,'oai:alma.61SCU_INST:')">
                    <xsl:value-of select="substring-after(., 'oai:alma.61SCU_INST:')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:otherwise>
            </xsl:choose-->
            <xsl:choose>
                <xsl:when test="contains(.,'oai:alma.61SCU_INST:')">
                    <xsl:value-of select="substring-after(., 'oai:alma.61SCU_INST:')"/>
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
            <xsl:value-of select="normalize-space(.)"/>
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
    
   <xsl:template match="*" mode="collection_relatedObject_individual">
        <xsl:if test="(string-length(givenname) > 0) or (string-length(familyname) > 0)">
            <relatedObject>
                <key>
                    <xsl:value-of select="custom:registryObjectKeyFromString(concat(givenname, familyname))"/> 
                </key>
                <relation type="{esploroFunc:relation(role)}"/>
            </relatedObject>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*" mode="collection_relatedObject_organization">
        <relatedObject>
            <key>
                <xsl:value-of select="custom:registryObjectKeyFromString(organization)"/> 
            </key>
            <relation type="hasAssociationWith"/>
        </relatedObject>
        </xsl:template>
    
    <xsl:template match="keywords" mode="collection_subject">
        <subject type="local">
            <xsl:value-of select="normalize-space(.)"/>
        </subject>
    </xsl:template>
    
    <xsl:template match="subject.anzfor" mode="collection_subject_anzsrc_for">
        <subject type="anzsrc-for">
            <xsl:value-of select="normalize-space(code)"/>
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
   
    <xsl:template match="geoLocationAddres" mode="collection_coverage_spatial_text">
        <coverage>
            <spatial type="text">
                <xsl:value-of select="normalize-space(displayString)"/>
            </spatial>
        </coverage>
   </xsl:template>
   
    <xsl:template match="geoLocationPoint" mode="collection_coverage_spatial_point">
        <xsl:if test="(string-length(longitude) > 0) and (string-length(latitude) > 0)">
            <coverage>
                <spatial type="kmlPolyCoords">
                    <xsl:value-of select="concat(normalize-space(longitude), ',', normalize-space(latitude))"/>
                </spatial>
                <spatial type="text">
                    <xsl:value-of select="normalize-space(displayString)"/>
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
   
    <xsl:template match="fundingreference" mode="collection_relatedInfo">
       <relatedInfo type="activity">
             <identifier>
                 <xsl:attribute name="type">
                     <xsl:choose>
                         <xsl:when test="contains(fundername, 'Australian Research Council') or (contains(fundername, 'ARC'))">
                             <xsl:text>arc</xsl:text>
                         </xsl:when>
                         <xsl:otherwise>
                             <xsl:text>local</xsl:text>
                         </xsl:otherwise>
                     </xsl:choose>
                 </xsl:attribute>
                 <xsl:value-of select="normalize-space(awardnumber)"/>
             </identifier>
            <title>
                <xsl:value-of select="concat(fundername, ' - ', normalize-space(awardtitle))"/>
            </title>
             <relation type="isOutputOf"/>
        </relatedInfo>
   </xsl:template>
    
    <xsl:template match="relationship" mode="collection_relatedInfo">
        <xsl:if test="(count(relatedidentifiers/relatedidentifier/relatedIdentifer[string-length() > 0]) > 0) or
            (count(relatedurl[string-length() > 0]) > 0)">
         <relatedInfo type="reuseInformation">
             <title>
                 <xsl:value-of select="relationtitle"/>
             </title>
             <xsl:choose>
                 <xsl:when test="count(relatedidentifiers/relatedidentifier/relatedIdentifer[string-length() > 0]) > 0">
                     <xsl:for-each select="relatedidentifiers/relatedidentifier">
                         <identifier type="{relatedIdentiferType}">
                             <xsl:value-of select="normalize-space(relatedIdentifer)"/>
                         </identifier>
                     </xsl:for-each>
                 </xsl:when>
                 <xsl:when test="count(relatedurl[string-length() > 0]) > 0">
                     <identifier type="uri">
                         <xsl:value-of select="normalize-space(relatedurl)"/>
                     </identifier>
                 </xsl:when>
                 <xsl:otherwise>
                     <!-- ought not ever get here due to test at beginning of template -->
                 </xsl:otherwise>
             </xsl:choose>
             <relation type="{relationtype}"/>
         </relatedInfo>
        </xsl:if>
    </xsl:template>
  
    <xsl:template match="rights" mode="collection_rights_access">
        <rights>
            <accessRights>
                <xsl:choose>
                    <xsl:when test="(lower-case(.) = 'open')">
                        <xsl:attribute name="type" select="'open'"/>
                    </xsl:when>
                    <xsl:when test="contains(lower-case(.), 'embargo')">
                        <xsl:attribute name="type" select="'restricted'"/>
                    </xsl:when>
                </xsl:choose>
                </accessRights>
        </rights>
    </xsl:template>
    
    <xsl:template match="license" mode="collection_rights_license">
        
        <rights>
            <licence>
                <xsl:choose>
                    <xsl:when test="contains(.,'CC')">
                        <xsl:variable name="ccNoNumber" as="xs:string*">
                            <xsl:analyze-string select="." regex="[A-Za-zÀ-ÿ\s-]+">
                                <xsl:matching-substring>
                                    <xsl:if test="string-length(regex-group(0)) > 0">
                                        <xsl:variable name="license" select="fn:normalize-space(regex-group(0))"/>
                                        
                                        <xsl:choose>
                                            <xsl:when test="fn:ends-with(upper-case($license), ' V')">
                                                <xsl:value-of select="substring($license, 0, string-length($license) - 1)"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$license"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:if>
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:variable>
                        <xsl:attribute name="type">
                            <xsl:value-of select="replace($ccNoNumber, ' ', '-')"/>
                        </xsl:attribute>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="type">
                            <xsl:value-of select="normalize-space(.)"/>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                
                    <xsl:variable name="ccNoNumber" as="xs:string*">
                        <xsl:analyze-string select="." regex="[A-Za-zÀ-ÿ\s-]+">
                            <xsl:matching-substring>
                                <xsl:if test="string-length(regex-group(0)) > 0">
                                    <xsl:value-of select="regex-group(0)"/>
                                </xsl:if>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:variable>
                <xsl:value-of select="normalize-space(license)"/>
            </licence>
        </rights>
    </xsl:template>
    
    <xsl:template match="copyright" mode="collection_rights_statement">
        <rights>
            <rightsStatement>
                <xsl:value-of select="normalize-space(.)"/>
            </rightsStatement>
        </rights>
    </xsl:template>
    
    <xsl:template match="*" mode="collection_description_full">
        <description type="full">
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    <xsl:template match="date.submitted" mode="collection_dates_submitted">
        <dates type="submitted">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="normalize-space(.)"/>
            </date>
        </dates>
    </xsl:template>  
    
    <xsl:template match="date.available" mode="collection_dates_available">
        <dates type="available">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="normalize-space(.)"/>
            </date>
        </dates>    
    </xsl:template>
    
    <xsl:template match="date.collected" mode="collection_dates_collected">
        <dates type="created">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="normalize-space(.)"/>
            </date>
        </dates>    
    </xsl:template>
    
    <xsl:template match="date.published" mode="collection_dates_issued">
        <dates type="issued">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="normalize-space(.)"/>
            </date>
        </dates>
    </xsl:template>  
             
     <xsl:template match="data" mode="party">
     
        <xsl:apply-templates select="creators/creator[(string-length(givenname) > 0) or (string-length(familyname) > 0)]" mode="party_individual"/>
        <xsl:apply-templates select="creators/creator[(string-length(institution) > 0)]" mode="party_institution"/>
        <xsl:apply-templates select="creators/creator[(string-length(organization) > 0)]" mode="party_organization"/>
       
        <xsl:apply-templates select="contributors/contributor[(string-length(givenname) > 0) or (string-length(familyname) > 0)]" mode="party_individual"/>
        <xsl:apply-templates select="contributors/contributor[(string-length(institution) > 0)]" mode="party_institution"/>
        <xsl:apply-templates select="contributors/contributor[(string-length(organization) > 0)]" mode="party_organization"/>
         
    </xsl:template>
    
    <xsl:template match="*" mode="party_individual">
       
            <registryObject>
                 <xsl:attribute name="group"><xsl:value-of select="$global_group"/></xsl:attribute>
                 <key>
                      <xsl:value-of select="custom:registryObjectKeyFromString(concat(givenname, familyname))"/>
                 </key>
                 <originatingSource><xsl:value-of select="$global_originatingSource"/></originatingSource>
                 <party>
                     
                     <xsl:attribute name="type" select="'person'"/>
                     
                     <xsl:if test="string-length(identifier.orcid) > 0 ">
                         <identifier type="orcid">
                             <xsl:choose>
                                 <xsl:when test="starts-with(identifier.orcid, 'http')">
                                     <xsl:value-of select="identifier.orcid"/>
                                 </xsl:when>
                                 <xsl:otherwise>
                                     <xsl:value-of select="concat('https://orcid.org/', identifier.orcid)"/>
                                 </xsl:otherwise>
                             </xsl:choose>
                         </identifier>
                     </xsl:if>
                     
                     <xsl:if test="string-length(identifier.scopus) > 0 ">
                         <identifier type="scopus">
                             <xsl:choose>
                                 <xsl:when test="starts-with(identifier.scopus, 'http')">
                                     <xsl:value-of select="identifier.scopus"/>
                                 </xsl:when>
                                 <xsl:otherwise>
                                     <xsl:value-of select="concat('https://www.scopus.com/authid/detail.uri?authorId=', identifier.scopus)"/>
                                 </xsl:otherwise>
                             </xsl:choose>
                         </identifier>
                     </xsl:if>
                     
                     <name type="primary">
                         <xsl:if test="string-length(givenname)> 0">
                             <namePart type="given">
                                 <xsl:value-of select="givenname"/>
                             </namePart> 
                         </xsl:if>
                         <xsl:if test="string-length(familyname)> 0">
                             <namePart type="family">
                                 <xsl:value-of select="familyname"/>
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
                     
                     <xsl:if test="string-length(organization) > 0">
                         <relatedObject>
                             <key>
                                 <xsl:value-of select="custom:registryObjectKeyFromString(organization)"/>
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
             
             
    <xsl:template match="*" mode="party_organization">
       
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
    
    <xsl:template match="*" mode="party_institution">
       
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
    
    <xsl:template match="data" mode="collection_citation">
        <xsl:if test="count(./*[starts-with(local-name(), 'identifier')]) > 0">
            <xsl:message select="'Identifier found'"/>
       
         <citationInfo>
             <citationMetadata>
                 <identifier>
               
                     <xsl:choose>
                         <xsl:when test="string-length(identifier.doi) > 0">
                             <xsl:attribute name="type">
                                 <xsl:value-of select="'doi'"/>
                             </xsl:attribute>
                             <xsl:value-of select="identifier.doi"/>
                         </xsl:when>
                         <xsl:when test="string-length(identifier.other) > 0">
                             <xsl:choose>
                                 <xsl:when test="contains(identifier.other, 'http')">
                                     <xsl:attribute name="type">
                                         <xsl:value-of select="uri"/>
                                     </xsl:attribute>
                                 </xsl:when>
                                 <xsl:otherwise>
                                     <xsl:attribute name="type">
                                         <xsl:value-of select="uri"/>
                                     </xsl:attribute>
                                 </xsl:otherwise>
                             </xsl:choose>
                             <xsl:value-of select="identifier.other"/>
                         </xsl:when>
                     </xsl:choose>
                 
                 </identifier>
                 
                 <xsl:variable name="maxOrder" as="xs:double" select="fn:max(creators/creator/order)"/>
                 
                 <xsl:for-each select ="creators/creator">
                     <contributor seq='{order}'>
                         <namePart type="family">
                             <xsl:value-of select="familyname"/>
                         </namePart>
                         <namePart type="given">
                             <xsl:value-of select="givenname"/>
                         </namePart>
                     </contributor>
                 </xsl:for-each>
                 
                 <xsl:for-each select="contributors/contributor">
                     <xsl:if test="(string-length(familyname) > 0) or (string-length(organization) > 0)">
                         <contributor seq='{$maxOrder + order}'>
                             <xsl:choose>
                                 <xsl:when test="string-length(familyname) > 0">
                                     <namePart type="family">
                                         <xsl:value-of select="familyname"/>
                                     </namePart>
                                     <namePart type="given">
                                         <xsl:value-of select="givenname"/>
                                     </namePart>
                                 </xsl:when>
                                 <xsl:when test="string-length(organization) > 0">
                                     <namePart type="family">
                                         <xsl:value-of select="organization"/>
                                     </namePart>
                                 </xsl:when>
                             </xsl:choose>
                           </contributor>
                     </xsl:if>
                 </xsl:for-each> 
                
                 <title>
                     <xsl:value-of select="title"/>
                 </title>
                 <!--version></version-->
                 <publisher>
                     <xsl:value-of select="publisher"/>
                 </publisher>
                 <date type="publicationDate">
                     <xsl:value-of select="date.published"/>
                 </date>
             </citationMetadata>
         </citationInfo>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="fundingreference" mode="activity">
        
        <xsl:if test="string-length(normalize-space(.)) > 0">
            
            <registryObject group="{$global_group}">
                <key>
                    <xsl:value-of select="custom:registryObjectKeyFromString(.)"/>
                </key>
                <originatingSource>
                    <xsl:value-of select="$global_originatingSource"/>
                </originatingSource>
                
                <activity type="grant">
                    <name type="primary">
                        <namePart>
                            <xsl:value-of select="normalize-space(awardtitle)"/>
                        </namePart>
                    </name>
                    <identifier>
                        <xsl:attribute name="type">
                            <xsl:choose>
                                <xsl:when test="contains(fundername, 'Australian Research Council') or (contains(fundername, 'ARC'))">
                                    <xsl:text>arc</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>local</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="normalize-space(awardnumber)"/>
                    </identifier>
                </activity>
            </registryObject>
        </xsl:if>
        
    </xsl:template>
      
    <xsl:function name="esploroFunc:formatKey">
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
   
   
    <xsl:function name="esploroFunc:relation">
        <xsl:param name="role"/>
        <xsl:choose>
            <xsl:when test="$role = 'Data Collector'">
                <xsl:text>hasCollector</xsl:text>
            </xsl:when>
            <xsl:when test="$role = 'Chief Investigator'">
                <xsl:text>hasPrincipalInvestigator</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>hasAssociationWith</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    

</xsl:stylesheet>
    
