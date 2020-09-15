<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
    xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:bibo="http://purl.org/ontology/bibo/" 
    xmlns:datacite="http://purl.org/spar/datacite/" 
    xmlns:fabio="http://purl.org/spar/fabio/" 
    xmlns:foaf="http://xmlns.com/foaf/0.1/" 
    xmlns:literal="http://www.essepuntato.it/2010/06/literalreification/" 
    xmlns:obo="http://purl.obolibrary.org/obo/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
    xmlns:vcard="http://www.w3.org/2006/vcard/ns#" 
    xmlns:vivo="http://vivoweb.org/ontology/core#"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:local="http://local.here.org"
    xmlns:exslt="http://exslt.org/common"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    exclude-result-prefixes="oai dc bibo datacite fabio foaf literal obo rdf rdfs vcard vivo xs fn local exslt xsi">
   
    <xsl:variable name="categoryCodeList" select="document('api.figshare.com_v2_categories.xml')"/>
    
    <xsl:param name="global_originatingSource" select="'(xslt param required)'"/>
    <xsl:param name="global_baseURI" select="'(xslt param required)'"/>
    <xsl:param name="global_group" select="'(xslt param required)'"/>
    <xsl:param name="global_publisherName" select="'(xslt param required)'"/>
  
    <xsl:output method="xml" version="1.0" omit-xml-declaration="no" indent="yes" encoding="UTF-8"/>
    
       
   <!--xsl:output method="xml" version="1.0" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/-->
    
    <xsl:template match="/">
        <registryObjects xmlns="http://ands.org.au/standards/rif-cs/registryObjects" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/schema/registryObjects.xsd">
            
            <xsl:message select="concat('name(oai:OAI-PMH): ', name(oai:OAI-PMH))"/>
            <!--xsl:apply-templates select="copy-of(oai:OAI-PMH/*/oai:record)"/-->
            <xsl:copy-of select="oai:OAI-PMH/*/oai:record"/>
            
        </registryObjects>
    </xsl:template>
    

    <xsl:template match="oai:OAI-PMH/*/oai:record">
    
    <!-- item_type_1 -->
    <!-- Article type: figure -->
    <!-- item_type_2 -->
    <!-- Article type: media -->
    <!-- item_type_3 -->
    <!-- Article type: dataset -->
    <!-- item_type_4 -->
    <!-- Article type: fileset -->
    <!-- item_type_5 -->
    <!-- Article type: poster -->
    <!-- item_type_6 -->
    <!-- Article type: paper -->
    <!-- item_type_7 -->
    <!-- Article type: presentation -->
    <!-- item_type_8 -->
    <!-- Article type: thesis -->
    <!-- item_type_9 -->
    <!-- Article type: code -->
    <!-- item_type_11 -->
    <!-- Article type: metadata -->
    
    <!-- include figure, media, dataset, fileset and code for now -->
    
      <xsl:if test="
          (count(oai:header/oai:setSpec[text() = 'item_type_1']) > 0) or
          (count(oai:header/oai:setSpec[text() = 'item_type_2']) > 0) or
          (count(oai:header/oai:setSpec[text() = 'item_type_3']) > 0) or
          (count(oai:header/oai:setSpec[text() = 'item_type_4']) > 0) or
          (count(oai:header/oai:setSpec[text() = 'item_type_9']) > 0) or
          (count(oai:header/oai:setSpec[text() = 'item_type_11']) > 0)">
                    
            <xsl:variable name="type">
                <xsl:choose>
                    <!-- figure -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_1']) > 0">
                        <xsl:text>collection</xsl:text>
                    </xsl:when>
                    <!-- media -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_2']) > 0">
                        <xsl:text>collection</xsl:text>
                    </xsl:when>
                    <!-- dataset -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_3']) > 0">
                        <xsl:text>dataset</xsl:text>
                    </xsl:when>
                    <!-- fileset -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_4']) > 0">
                        <xsl:text>collection</xsl:text>
                    </xsl:when>
                    <!-- code -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_9']) > 0">
                        <xsl:text>software</xsl:text>
                    </xsl:when>
                    <!-- metadata -->
                    <xsl:when test="count(oai:header/oai:setSpec[text() = 'item_type_11']) > 0">
                        <xsl:text>collection</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
          
          <xsl:variable name="oaiFigshareIdentifier" select="oai:header/oai:identifier"/>
          <xsl:if test="string-length($oaiFigshareIdentifier)">
            <xsl:apply-templates select="oai:metadata/rdf:RDF" mode="collection">
                <xsl:with-param name="oaiFigshareIdentifier" select="$oaiFigshareIdentifier"/>
                <xsl:with-param name="type" select="$type"/>
            </xsl:apply-templates>
            <!-- xsl:apply-templates select="oai:metadata/rdf:RDF/dc:funding" mode="funding_party"/ -->
            <!-- xsl:apply-templates select="oai:metadata/rdf:RDF" mode="party"/-->
          </xsl:if>
    </xsl:if>
    </xsl:template>
    
<xsl:template match="rdf:RDF" mode="collection">
        <xsl:param name="oaiFigshareIdentifier" as="xs:string"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:variable name="class" select="'collection'"/>
        
        <xsl:message select="concat('mapped type: ', $type)"/>
    
        <xsl:variable name="doiFull" select="*/bibo:doi"/>
        <xsl:variable name="doiLastPart" select="tokenize($doiFull, '/')[count(tokenize($doiFull, '/'))]"/>
    
        
    <xsl:message select="concat('doiLastPart: ', $doiLastPart)"/>
    <xsl:message select="concat('key to use: ', substring(string-join(for $n in fn:reverse(fn:string-to-codepoints($oaiFigshareIdentifier)) return string($n), ''), 0, 50))"/>
    

    <registryObject>
        <xsl:attribute name="group" select="$global_group"/>
        <key>
            <xsl:value-of select="substring(string-join(for $n in fn:reverse(fn:string-to-codepoints($oaiFigshareIdentifier)) return string($n), ''), 0, 50)"/>
        </key>
        <originatingSource>
            <xsl:value-of select="$global_originatingSource"/>
        </originatingSource>
        <xsl:element name="{$class}">
            
            <xsl:attribute name="type" select="$type"/>
         
            <xsl:apply-templates select="*/vivo:dateModified/@rdf:resource[string-length(.) > 0]" mode="collection_date_modified"/>
            
            <xsl:apply-templates select="*/bibo:doi[string-length(.) > 0]" mode="collection_identifier"/>
            
            <xsl:apply-templates select="*/bibo:doi[string-length(.) > 0]" mode="collection_location"/>
            
            <xsl:if test="string-length(*/bibo:doi) = 0">
                <xsl:apply-templates select="*[1]/@rdf:about[(string-length(.) > 0)]" mode="collection_location"/>
            </xsl:if>
            
            <xsl:apply-templates select="*/rdfs:label[string-length(.) > 0]" mode="collection_name"/>
            
            <xsl:apply-templates select="vivo:Authorship/vivo:relates/vcard:Individual/obo:ARG_2000029/foaf:Person[string-length(vivo:orcidId/@rdf:resource) > 0]" mode="collection_relatedInfo_orcid"/>
            
            <xsl:apply-templates select="vivo:Authorship/vivo:relates/vcard:Individual[count(obo:ARG_2000029/foaf:Person/vivo:orcidId/@rdf:resource) = 0]/vcard:hasName" mode="collection_relatedInfo_noOrcid"/>
            
            <!--xsl:apply-templates select="vcard:Name" mode="collection_relatedObject"/-->
           
            <xsl:apply-templates select="*/bibo:freetextKeyword[string-length(.) > 0]" mode="collection_subject"/>
            
            <xsl:apply-templates select="*/dc:rights[string-length(.) > 0]" mode="collection_rights_access"/>
            
            <xsl:apply-templates select="ancestor::oai:record/oai:header/oai:setSpec[contains(., 'category_')]" mode="collection_subject"/>
           
            <xsl:apply-templates select="*/bibo:abstract[string-length(.) > 0]" mode="collection_description_full"/>
           
            <xsl:apply-templates select="*/vivo:datePublished/@rdf:resource[string-length(.) > 0]" mode="collection_dates_issued"/>  
         
            <xsl:apply-templates select="*/vivo:dateCreated/@rdf:resource[string-length(.) > 0]" mode="collection_dates_created"/>  
         
        </xsl:element>
    </registryObject>
    
    </xsl:template>
   
    
    <xsl:template match="@rdf:resource" mode="collection_date_modified">
        <xsl:attribute name="dateModified" select="substring-after(., 'http://openvivo.org/a/date')"/>
    </xsl:template>
       
    <xsl:template match="bibo:doi" mode="collection_identifier">
        <identifier type="doi">
            <xsl:choose>
                <xsl:when test="starts-with(. , '10.')">
                    <xsl:value-of select="concat('http://doi.org/', .)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </identifier>    
    </xsl:template>
    
     <xsl:template match="bibo:doi" mode="collection_location">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:choose>
                            <xsl:when test="starts-with(. , '10.')">
                                <xsl:value-of select="concat('http://doi.org/', .)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="rdfs:label" mode="collection_name">
        <name type="primary">
            <!--xsl:variable name="name" select='replace(.,"&#x00E2;&#x80;&#x99;", "&#8217;")'/-->
            <xsl:variable name="name" select='replace(.,"&#x00E2;&#x80;&#x99;", "&#x2019;")'/>
            <namePart>
                <xsl:value-of select='$name'/>
            </namePart>
        </name>
    </xsl:template>
    
    
    <xsl:template match="@rdf:about" mode="collection_location">
        <location>
            <address>
                <electronic type="url" target="landingPage">
                    <value>
                        <xsl:value-of select="."/>
                    </value>
                </electronic>
            </address>
        </location> 
    </xsl:template>
    
    <xsl:template match="vcard:hasName" mode="collection_relatedInfo_noOrcid">
        
        <!-- value of @rdf:resource will only resolve if it contains a name with a number, 
            so if it's only a number just make a unique identifier for
            this client that obviously does not resolve, to avoid confusion -->
        
        <xsl:message select="concat('@rdf:resource [', @rdf:resource, ']')"/>
        
           
       <!-- extract name part from url - may be just an underscore, so we will test this later with length-->
      <xsl:variable name="nameFromURL">
          <xsl:analyze-string select="substring-after(@rdf:resource, 'authors/')" regex="^[a-zA-ZÀ-ÿ-]*[_+][a-zA-ZÀ-ÿ-]*">
              <xsl:matching-substring>
                  <xsl:value-of select="regex-group(0)"/>
              </xsl:matching-substring>
          </xsl:analyze-string>
      </xsl:variable>
        
        <xsl:message select="concat('nameFromURL ', $nameFromURL)"/>
        
           <xsl:variable name="personID">
                <xsl:analyze-string select="@rdf:resource" regex="[\d]+">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(0)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            
                <relatedInfo type='party'>
                    <xsl:choose>
                        <xsl:when test="string-length($nameFromURL) > 1">
                            <identifier type="url">
                                <xsl:value-of select="substring-before(@rdf:resource, '-name')"/>
                            </identifier>
                        </xsl:when>
                        <xsl:otherwise>
                            <identifier type="local">
                                <xsl:value-of select="$personID"/>
                            </identifier>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:for-each select="ancestor::rdf:RDF/vcard:Name[contains(@rdf:about, $personID)]">
                        <title>
                            <xsl:value-of select="normalize-space(concat(vcard:givenName, ' ', vcard:familyName))"/>
                        </title>
                    </xsl:for-each>
                    <relation type="hasCollector"/>
                </relatedInfo>
    </xsl:template>
    
    <xsl:template match="foaf:Person" mode="collection_relatedInfo_orcid">
        <relatedInfo type='party'>
             <identifier type="{local:getIdentifierType(vivo:orcidId/@rdf:resource)}">
                <xsl:value-of select="vivo:orcidId/@rdf:resource"/>
            </identifier>
             <xsl:if test="string-length(rdfs:label) > 0">   
            <title>
                <xsl:value-of select="rdfs:label"/>
            </title>
            </xsl:if>
            <relation type="hasCollector"/>
        </relatedInfo>
          
        
    </xsl:template>
    
   
    <xsl:template match="bibo:freetextKeyword" mode="collection_subject">
        <subject type="local">
            <xsl:value-of select="."/>
        </subject>
    </xsl:template>
   
    <xsl:template match="dc:rights" mode="collection_rights_access">
        
        <xsl:choose>
            <xsl:when test="contains(upper-case(.), 'CC BY')">
                <xsl:variable name="ccNoNumber" as="xs:string*">
                    <xsl:analyze-string select="." regex="[A-Za-zÀ-ÿ\s-]+">
                        <xsl:matching-substring>
                            <xsl:if test="string-length(regex-group(0)) > 0">
                                <xsl:value-of select="regex-group(0)"/>
                            </xsl:if>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:variable>
                <rights>
                    <licence type="{upper-case(replace(normalize-space($ccNoNumber), ' ', '-'))}">
                        <xsl:value-of select="upper-case(replace(normalize-space(.), ' ', '-'))"/>
                    </licence>
                </rights>   
            </xsl:when>
            <xsl:otherwise>
                <rights>
                    <rightsStatement>
                        <xsl:value-of select="."/>
                    </rightsStatement>
                </rights>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="oai:setSpec" mode="collection_subject">
        <xsl:variable name="categoryId" select="substring-after(., 'category_')" as="xs:string"/>
        <xsl:variable name="mappedValue" select="$categoryCodeList/root/row[id = $categoryId]/title"/>
        <xsl:message select="concat('categoryId [', $categoryId, '] mapped to [', $mappedValue, ']')"/>
            
        <subject type="local">
            <xsl:value-of select="$mappedValue"/>
        </subject>
    </xsl:template>
    
    <xsl:template match="bibo:abstract" mode="collection_description_full">
        <description type="full">
            <xsl:value-of select="."/>
        </description>
    </xsl:template>
    
    <xsl:template match="@rdf:resource" mode="collection_dates_issued">
        <dates type="issued">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="substring-after(., 'http://openvivo.org/a/date')"/>
            </date>
        </dates>
    </xsl:template>  
             
    <xsl:template match="@rdf:resource" mode="collection_dates_created">
        <dates type="created">
            <date type="dateFrom" dateFormat="W3CDTF">
                <xsl:value-of select="substring-after(., 'http://openvivo.org/a/date')"/>
            </date>
        </dates>    
    </xsl:template>
    
    <!--xsl:template match="rdf:RDF" mode="party">
        
        <xsl:for-each select="vcard:Name">
            
            <xsl:variable name="name" select="normalize-space(.)"/>
            
            <xsl:if test="(string-length(@rdf:about) > 0)">
            
                   <xsl:if test="string-length(normalize-space(.)) > 0">
                     <registryObject group="{$global_group}">
                        <key>
                            <xsl:value-of select="custom:registryObjectKeyFromString(local:unifyAuthorURL(@rdf:about))"/>
                        </key> 
                        <originatingSource>
                             <xsl:value-of select="$global_originatingSource"/>
                        </originatingSource>
                        
                         <party>
                            <xsl:attribute name="type" select="'person'"/>
                           
                            <identifier type="uri">
                                <xsl:value-of select="local:unifyAuthorURL(@rdf:about)"/> 
                            </identifier>  
                             
                            <xsl:variable name="currentPersonURL" select="@rdf:about"/>
                            <xsl:for-each select="ancestor::rdf:RDF/vivo:Authorship/vivo:relates/vcard:Individual/obo:ARG_2000029/foaf:Person[contains($currentPersonURL, @rdf:about)]">
                                <xsl:for-each select="vivo:orcidId[string-length(@rdf:resource) > 0]">
                                    <identifier type="orcid">
                                        <xsl:value-of select="@rdf:resource"/>
                                    </identifier>
                                </xsl:for-each>
                            </xsl:for-each>
                             <name type="primary">
                                 <namePart type="given">
                                     <xsl:value-of select="vcard:givenName"/>
                                 </namePart>    
                                 <namePart type="family">
                                     <xsl:value-of select="vcard:familyName"/>
                                 </namePart>
                             </name>
                        </party>
                     </registryObject>
                   </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:template-->
        
        
        <xsl:function name="local:getIdentifierType" as="xs:string">
        <xsl:param name="identifier" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="contains(lower-case($identifier), 'orcid')">
                <xsl:text>orcid</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'purl.org')">
                <xsl:text>purl</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'doi.org')">
                <xsl:text>doi</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'scopus')">
                <xsl:text>scopus</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'handle.net')">
                <xsl:text>handle</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'nla.gov.au')">
                <xsl:text>AU-ANL:PEAU</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'fundref')">
                <xsl:text>fundref</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'http')">
                <xsl:text>url</xsl:text>
            </xsl:when>
            <xsl:when test="contains(lower-case($identifier), 'ftp')">
                <xsl:text>url</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>local</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
   
         
 

</xsl:stylesheet>
