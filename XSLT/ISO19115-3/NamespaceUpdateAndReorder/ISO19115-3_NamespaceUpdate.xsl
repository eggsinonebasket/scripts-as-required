<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gmi="http://www.isotc211.org/2005/gmi"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gsr="http://www.isotc211.org/2005/gsr"
                xmlns:gss="http://www.isotc211.org/2005/gss"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:srvold="http://www.isotc211.org/2005/srv"
                xmlns:gfc="http://standards.iso.org/iso/19110/gfc/1.0"
                xmlns:fcc="http://standards.iso.org/iso/19110/fcc/1.0"
                xmlns:cat="http://standards.iso.org/iso/19115/-3/cat/1.0"
                xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
                xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0"
                xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
                xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0"
                xmlns:mac="http://standards.iso.org/iso/19115/-3/mac/1.0"
                xmlns:mas="http://standards.iso.org/iso/19115/-3/mas/1.0"
                xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
                xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0"
                xmlns:mda="http://standards.iso.org/iso/19115/-3/mda/1.0"
                xmlns:mdt="http://standards.iso.org/iso/19115/-3/mdt/1.0"
                xmlns:mex="http://standards.iso.org/iso/19115/-3/mex/1.0"
                xmlns:mic="http://standards.iso.org/iso/19115/-3/mic/1.0"
                xmlns:mil="http://standards.iso.org/iso/19115/-3/mil/1.0"
                xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/1.0"
                xmlns:mds="http://standards.iso.org/iso/19115/-3/mds/1.0"
                xmlns:mmi="http://standards.iso.org/iso/19115/-3/mmi/1.0"
                xmlns:mpc="http://standards.iso.org/iso/19115/-3/mpc/1.0"
                xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/1.0"
                xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
                xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
                xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0"
                xmlns:msr="http://standards.iso.org/iso/19115/-3/msr/1.0"
                xmlns:mai="http://standards.iso.org/iso/19115/-3/mai/1.0"
                xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.1"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0"
                xmlns:gwm="http://standards.iso.org/iso/19115/-3/gwm/1.0"
                xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns="http://standards.iso.org/iso/19115/-3/mdb/1.0"
                exclude-result-prefixes="#all">
  <!-- 
  <xsl:import href="utility/create19115-3Namespaces.xsl"/>

   <xsl:import href="utility/dateTime.xsl"/>
  <xsl:import href="utility/multiLingualCharacterStrings.xsl"/>
-->
  <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
    <xd:desc>
      <xd:p>
        <xd:b>Created on:</xd:b>March 8, 2014 </xd:p>
      <xd:p>Translates from ISO 19139 for ISO 19115 and ISO 19139-2 for 19115-2 to ISO 19139-1 for ISO 19115-1</xd:p>
      <xd:p>
        <xd:b>Version June 13, 2014</xd:b>
        <xd:ul>
          <xd:li>Converged the 19115-2 transform into 19115-1 namespaces</xd:li>
        </xd:ul>
      </xd:p>
      <xd:p>
        <xd:b>Version August 7, 2014</xd:b>
        <xd:ul>
          <xd:li>Changed namespace dates to 2014-07-11</xd:li>
          <xd:li>Fixed DistributedComputingPlatform element</xd:li>
        </xd:ul>
      </xd:p>
      <xd:p>
        <xd:b>Version August 15, 2014</xd:b>
        <xd:ul>
          <xd:li>Add multilingual metadata support by converting gmd:locale and copying gmd:PT_FreeText and element attributes (eg. gco:nilReason, xsi:type) for gmd:CharacterString elements (Author:
            fx.prunayre@gmail.com).</xd:li>
        </xd:ul>
      </xd:p>
      <xd:p>
        <xd:b>Version September 4, 2014</xd:b>
        <xd:ul>
          <xd:li>Added transform for MD_FeatureCatalogueDescription (problem identified by Tobias Spears</xd:li>
        </xd:ul>
      </xd:p>
      <xd:p>
        <xd:b>Version February 5, 2015</xd:b>
        <xd:ul>
          <xd:li>Update to 2014-12-25 version</xd:li>
        </xd:ul>
      </xd:p>
      <xd:p><xd:b>Author:</xd:b>thabermann@hdfgroup.org</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:output method="xml" version="1.1" indent="yes" omit-xml-declaration="no" undeclare-prefixes="yes"/>

  <xsl:strip-space elements="*"/>

  <xsl:variable name="stylesheetVersion" select="'0.1'"/>
  
  <xsl:template match="/">
    <xsl:for-each select="//mdb:MD_Metadata">
      <xsl:apply-templates select="." mode="namespaceUpdate"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mdb:MD_Metadata" mode="namespaceUpdate">
      <xsl:element name="mdb:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mdb/1.3" >
        <xsl:namespace name="cat" select="'https://schemas.isotc211.org/19115/-3/cat/1.0'"/>
        <xsl:namespace name="cit" select="'https://schemas.isotc211.org/19115/-1/cit/1.3'"/>
        <xsl:namespace name="fcc" select="'https://schemas.isotc211.org/19110/-/fcc/1.0'"/>
        <xsl:namespace name="gco" select="'https://schemas.isotc211.org/19103/-/gco/1.1'"/>
        <xsl:namespace name="gcx" select="'https://schemas.isotc211.org/19103/-/gcx/1.1'"/>
        <xsl:namespace name="gex" select="'https://schemas.isotc211.org/19115/-1/gex/1.3'"/>
        <xsl:namespace name="gfc" select="'https://schemas.isotc211.org/19110/-/gfc/1.0'"/>
        <xsl:namespace name="gml" select="'https://www.opengis.net/gml/3.2'"/>
        <xsl:namespace name="gwm" select="'https://schemas.isotc211.org/19136/-/gwm/1.1'"/>
        <xsl:namespace name="lan" select="'https://schemas.isotc211.org/19115/-1/lan/1.3'"/>
        <xsl:namespace name="mac" select="'https://schemas.isotc211.org/19115/-2/mac/2.1'"/>
        <xsl:namespace name="mas" select="'https://schemas.isotc211.org/19115/-1/mas/1.3'"/>
        <xsl:namespace name="mcc" select="'https://schemas.isotc211.org/19115/-1/mcc/1.3'"/>
        <xsl:namespace name="mco" select="'https://schemas.isotc211.org/19115/-1/mco/1.3'"/>
        <xsl:namespace name="mda" select="'https://schemas.isotc211.org/19115/-1/mda/1.3'"/>
        <xsl:namespace name="mdb" select="'https://schemas.isotc211.org/19115/-1/mdb/1.3'"/>
        <xsl:namespace name="mdq" select="'https://schemas.isotc211.org/19157/-2/mdq/1.1'"/>
        <xsl:namespace name="mex" select="'https://schemas.isotc211.org/19115/-1/mex/1.3'"/>
        <xsl:namespace name="mmi" select="'https://schemas.isotc211.org/19115/-1/mmi/1.3'"/>
        <xsl:namespace name="mpc" select="'https://schemas.isotc211.org/19115/-1/mpc/1.3'"/>
        <xsl:namespace name="mrc" select="'https://schemas.isotc211.org/19115/-1/mrc/1.3'"/>
        <xsl:namespace name="mrd" select="'https://schemas.isotc211.org/19115/-1/mrd/1.3'"/>
        <xsl:namespace name="mri" select="'https://schemas.isotc211.org/19115/-1/mri/1.3'"/>
        <xsl:namespace name="mrl" select="'https://schemas.isotc211.org/19115/-1/mrl/1.3'"/>
        <xsl:namespace name="mrs" select="'https://schemas.isotc211.org/19115/-1/mrs/1.3'"/>
        <xsl:namespace name="msr" select="'https://schemas.isotc211.org/19115/-1/msr/1.3'"/>
        <xsl:namespace name="srv" select="'https://schemas.isotc211.org/19115/-1/srv/1.3'"/>
        <xsl:namespace name="xlink" select="'https://www.w3.org/1999/xlink'"/>
        <xsl:namespace name="xsi" select="'https://www.w3.org/2001/XMLSchema-instance'"/>
        
        <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="node()|@*">
    <xsl:copy copy-namespaces="no" inherit-namespaces="no">
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="cat:*">
    <xsl:element name="cat:{local-name()}" namespace="https://schemas.isotc211.org/19115/-3/cat/1.0" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@cat:*">
    <xsl:attribute name="cat:{local-name()}" namespace="https://schemas.isotc211.org/19115/-3/cat/1.0" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="cit:*">
    <xsl:element name="cit:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/cit/1.3" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@cit:*">
    <xsl:attribute name="cit:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/cit/1.3" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="fcc:*">
    <xsl:element name="fcc:{local-name()}" namespace="https://schemas.isotc211.org/19110/-/fcc/1.0" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@fcc:*">
    <xsl:attribute name="fcc:{local-name()}" namespace="https://schemas.isotc211.org/19110/-/fcc/1.0" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="gco:*">
    <xsl:element name="gco:{local-name()}" namespace="https://schemas.isotc211.org/19103/-/gco/1.1" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
 <xsl:template match="@gco:*">
    <xsl:attribute name="gco:{local-name()}" namespace="https://schemas.isotc211.org/19103/-/gco/1.1" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="gcx:*">
    <xsl:element name="gcx:{local-name()}" namespace="https://schemas.isotc211.org/19136/-/gcx/1.1" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@gcx:*">
    <xsl:attribute name="gcx:{local-name()}" namespace="https://schemas.isotc211.org/19136/-/gcx/1.1" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="gex:*">
    <xsl:element name="gex:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/gex/1.3" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@gex:*">
    <xsl:attribute name="gex:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/gex/1.3" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="gfc:*">
    <xsl:element name="gfc:{local-name()}" namespace="https://schemas.isotc211.org/19110/-/gfc/1.0" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@gfc:*">
    <xsl:attribute name="gfc:{local-name()}" namespace="https://schemas.isotc211.org/19110/-/gfc/1.0" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="gml:*">
    <!--xsl:element name="gml:{local-name()}" namespace="http://www.opengis.net/gml/3.2" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element-->
    <xsl:copy copy-namespaces="no" inherit-namespaces="no">
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@gml:*">
    <xsl:attribute name="gml:{local-name()}" namespace="http://www.opengis.net/gml/3.2" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="gwm:*">
    <xsl:element name="gwm:{local-name()}" namespace="https://schemas.isotc211.org/19136/-/gwm/1.1" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@gwm:*">
    <xsl:attribute name="gwm:{local-name()}" namespace="https://schemas.isotc211.org/19136/-/gwm/1.1" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="lan:*">
    <xsl:element name="lan:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/lan/1.3" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@lan:*">
    <xsl:attribute name="lan:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/lan/1.3" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="mac:*">
    <xsl:element name="mac:{local-name()}" namespace="https://schemas.isotc211.org/19115/-2/mac/2.1" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@mac:*">
    <xsl:attribute name="mac:{local-name()}" namespace="https://schemas.isotc211.org/19115/-2/mac/2.1" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- xmlns:mai="http://standards.iso.org/iso/19115/-3/mai/1.0" -->
  
  <!--    xmlns:mic="http://standards.iso.org/iso/19115/-3/mic/1.0"-->
  
  <!--  xmlns:mil="http://standards.iso.org/iso/19115/-3/mil/1.0" -->
  
  <xsl:template match="mas:*">
    <xsl:element name="mas:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mas/1.3" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@mas:*">
    <xsl:attribute name="mas:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mas/1.3" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="mcc:*">
    <xsl:element name="mcc:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mcc/1.3" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@mcc:*">
    <xsl:attribute name="mcc:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mcc/1.3" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <!--   xmlns:mds="http://standards.iso.org/iso/19115/-3/mds/1.0" -->
  
  <xsl:template match="mco:*">
    <xsl:element name="mco:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mco/1.3" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@mco:*">
    <xsl:attribute name="mco:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mco/1.3" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="mda:*">
    <xsl:element name="mda:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mda/1.3" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@mda:*">
    <xsl:attribute name="mda:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mda/1.3" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <!--xsl:template match="mdb:*[not(local-name() ='MD_Metadata')]">
    <xsl:element name="mdb:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mdb/1.3" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template-->
  
  <xsl:template match="mdb:*">
    <xsl:element name="mdb:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mdb/1.3" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@mdb:*">
    <xsl:attribute name="mdb:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mdb/1.3" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="mdq:*">
    <xsl:element name="mdq:{local-name()}" namespace="https://schemas.isotc211.org/19157/-2/mdq/1.1" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@mdq:*">
    <xsl:attribute name="mdq:{local-name()}" namespace="https://schemas.isotc211.org/19157/-2/mdq/1.1" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <!--xmlns:mdt="http://standards.iso.org/iso/19115/-3/mdt/1.0"-->
  
  <xsl:template match="mex:*">
    <xsl:element name="mex:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mex/1.3" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@mex:*">
    <xsl:attribute name="mex:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mex/1.3" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="mmi:*">
    <xsl:element name="mmi:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mmi/1.3" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@mmi:*">
    <xsl:attribute name="mmi:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mmi/1.3" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="mpc:*">
    <xsl:element name="mpc:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mpc/1.3" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@mpc:*">
    <xsl:attribute name="mpc:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mpc/1.3" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="mrc:*">
    <xsl:element name="mrc:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mrc/1.3" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@mrc:*">
    <xsl:attribute name="mrc:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mrc/1.3" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="mrd:*">
    <xsl:element name="mrd:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mrd/1.3" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@mrd:*">
    <xsl:attribute name="mrd:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mrd/1.3" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="mri:*">
    <xsl:element name="mri:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mri/1.3" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@mri:*">
    <xsl:attribute name="mri:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mri/1.3" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="mrl:*">
    <xsl:element name="mrl:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mrl/1.3" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@mrl:*">
    <xsl:attribute name="mrl:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mrl/1.3" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="mrs:*">
    <xsl:element name="mrs:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mrs/1.3" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@mrs:*">
    <xsl:attribute name="mrs:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mrs/1.3" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="srv:*">
    <xsl:element name="srv:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/srv/1.3" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@srv:*">
    <xsl:attribute name="srv:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/srv/1.3" >
      <xsl:value-of select="."/>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="xsi:*">
    <xsl:element name="srv:{local-name()}" namespace="https://www.w3.org/2001/XMLSchema-instance" >
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@xsi:*">
    <xsl:attribute name="xsi:{local-name()}" namespace="https://www.w3.org/2001/XMLSchema-instance" >
      <xsl:choose>
        <xsl:when test="local-name() = 'schemaLocation'">
          <xsl:value-of select="'https://schemas.isotc211.org/19115/-1/mdb/1.3 https://schemas.isotc211.org/19115/-1/mdb/1.3/mdb.xsd'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
      
      <xsl:apply-templates select="node()|@*"/>
    </xsl:attribute>
  </xsl:template>
  
  
</xsl:stylesheet>
