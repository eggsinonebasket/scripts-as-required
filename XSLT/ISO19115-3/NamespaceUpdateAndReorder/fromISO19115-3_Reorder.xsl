<xsl:stylesheet version="2.0"
                xmlns:mdb="https://schemas.isotc211.org/19115/-1/mdb/1.3"
                xmlns:xsi="https://www.w3.org/2001/XMLSchema-instance"
                xmlns:cit="https://schemas.isotc211.org/19115/-1/cit/1.3"
                xmlns:gex="https://schemas.isotc211.org/19115/-1/gex/1.3"
                xmlns:lan="https://schemas.isotc211.org/19115/-1/lan/1.3"
                xmlns:mas="https://schemas.isotc211.org/19115/-1/mas/1.3"
                xmlns:mcc="https://schemas.isotc211.org/19115/-1/mcc/1.3"
                xmlns:mco="https://schemas.isotc211.org/19115/-1/mco/1.3"
                xmlns:mda="https://schemas.isotc211.org/19115/-1/mda/1.3"
                xmlns:mex="https://schemas.isotc211.org/19115/-1/mex/1.3"
                xmlns:mmi="https://schemas.isotc211.org/19115/-1/mmi/1.3"
                xmlns:mpc="https://schemas.isotc211.org/19115/-1/mpc/1.3"
                xmlns:mrc="https://schemas.isotc211.org/19115/-1/mrc/1.3"
                xmlns:mrd="https://schemas.isotc211.org/19115/-1/mrd/1.3"
                xmlns:mri="https://schemas.isotc211.org/19115/-1/mri/1.3"
                xmlns:mrl="https://schemas.isotc211.org/19115/-1/mrl/1.3"
                xmlns:mrs="https://schemas.isotc211.org/19115/-1/mrs/1.3"
                xmlns:msr="https://schemas.isotc211.org/19115/-1/msr/1.3"
                xmlns:srv="https://schemas.isotc211.org/19115/-1/srv/1.3"
                xmlns:mac="https://schemas.isotc211.org/19115/-2/mac/2.1"
                xmlns:cat="https://schemas.isotc211.org/19115/-3/cat/1.0"
                xmlns:gco="https://schemas.isotc211.org/19103/-/gco/1.1"
                xmlns:gcx="https://schemas.isotc211.org/19103/-/gcx/1.1"
                xmlns:gfc="https://schemas.isotc211.org/19110/-/gfc/1.0"
                xmlns:fcc="https://schemas.isotc211.org/19110/-/fcc/1.0"
                xmlns:mdq="https://schemas.isotc211.org/19157/-2/mdq/1.1"
                xmlns:gwm="https://schemas.isotc211.org/19136/-/gwm/1.1"
                xmlns:gml="https://www.opengis.net/gml/3.2"
                xmlns:xlink="http://www.w3.org/1999/xlink"
  
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gcoold="http://www.isotc211.org/2005/gco"
                xmlns:gmi="http://www.isotc211.org/2005/gmi"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gsr="http://www.isotc211.org/2005/gsr"
                xmlns:gss="http://www.isotc211.org/2005/gss"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:srvold="http://www.isotc211.org/2005/srv"
                xmlns:gml30="http://www.opengis.net/gml"
                xmlns:mdt="http://standards.iso.org/iso/19115/-3/mdt/1.0"
                xmlns:mic="http://standards.iso.org/iso/19115/-3/mic/1.0"
                xmlns:mil="http://standards.iso.org/iso/19115/-3/mil/1.0"
                xmlns:mds="http://standards.iso.org/iso/19115/-3/mds/1.0"
                xmlns:mai="http://standards.iso.org/iso/19115/-3/mai/1.0"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                exclude-result-prefixes="#all">

  <xsl:import href="ISO19115-3_NamespaceUpdate.xsl"/>
  
  <xsl:output method="xml" version="1.1" indent="yes" omit-xml-declaration="no" undeclare-prefixes="yes"/>

  <xsl:strip-space elements="*"/>

  <xsl:variable name="stylesheetVersion" select="'0.1'"/>
  
  <xsl:template match="/">
    <xsl:variable name="allOutputXML" as="node()*">
      <xsl:copy>
        <xsl:apply-templates select="node()|@*"/>
      </xsl:copy>
    </xsl:variable>
    <xsl:apply-templates select="$allOutputXML//mdb:MD_Metadata" mode="reorder"/>
  </xsl:template>
  
  <xsl:template match="mdb:MD_Metadata" mode="reorder">
    
    <xsl:element name="mdb:{local-name()}" namespace="https://schemas.isotc211.org/19115/-1/mdb/1.3" >
      <xsl:namespace name="mdb" select="'https://schemas.isotc211.org/19115/-1/mdb/1.3'"/>
      <xsl:namespace name="xsi" select="'https://www.w3.org/2001/XMLSchema-instance'"/>
      <xsl:namespace name="cit" select="'https://schemas.isotc211.org/19115/-1/cit/1.3'"/>
      <xsl:namespace name="gex" select="'https://schemas.isotc211.org/19115/-1/gex/1.3'"/>
      <xsl:namespace name="lan" select="'https://schemas.isotc211.org/19115/-1/lan/1.3'"/>
      <xsl:namespace name="mas" select="'https://schemas.isotc211.org/19115/-1/mas/1.3'"/>
      <xsl:namespace name="mcc" select="'https://schemas.isotc211.org/19115/-1/mcc/1.3'"/>
      <xsl:namespace name="mco" select="'https://schemas.isotc211.org/19115/-1/mco/1.3'"/>
      <xsl:namespace name="mda" select="'https://schemas.isotc211.org/19115/-1/mda/1.3'"/>
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
      <xsl:namespace name="mac" select="'https://schemas.isotc211.org/19115/-2/mac/2.1'"/>
      <xsl:namespace name="cat" select="'https://schemas.isotc211.org/19115/-3/cat/1.0'"/>
      <xsl:namespace name="gco" select="'https://schemas.isotc211.org/19103/-/gco/1.1'"/>
      <xsl:namespace name="gcx" select="'https://schemas.isotc211.org/19103/-/gcx/1.1'"/>
      <xsl:namespace name="gfc" select="'https://schemas.isotc211.org/19110/-/gfc/1.0'"/>
      <xsl:namespace name="fcc" select="'https://schemas.isotc211.org/19110/-/fcc/1.0'"/>
      <xsl:namespace name="mdq" select="'https://schemas.isotc211.org/19157/-2/mdq/1.1'"/>
      <xsl:namespace name="gwm" select="'https://schemas.isotc211.org/19136/-/gwm/1.1'"/>
      <xsl:namespace name="gml" select="'https://www.opengis.net/gml/3.2'"/>
      <xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/>
      <xsl:apply-templates select="mdb:metadataIdentifier" mode="reorder"/>
      <xsl:apply-templates select="mdb:defaultLocale" mode="reorder"/>
      <xsl:apply-templates select="mdb:parentMetadata" mode="reorder"/>
      <xsl:apply-templates select="mdb:contact" mode="reorder"/>
      <xsl:apply-templates select="mdb:dateInfo" mode="reorder"/>
      <xsl:apply-templates select="mdb:identificationInfo" mode="reorder"/>
      <xsl:apply-templates select="mdb:distributionInfo" mode="reorder"/>
      <xsl:apply-templates select="mdb:resourceLineage" mode="reorder"/>
      <xsl:apply-templates select="mdb:metadataScope" mode="reorder"/>
      <xsl:apply-templates select="mdb:metadataConstraints" mode="reorder"/>
      
     
    </xsl:element>
    
  </xsl:template>
   
  <xsl:template match="mdb:metadataIdentifier" mode="reorder">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="mdb:defaultLocale" mode="reorder">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="mdb:parentMetadata" mode="reorder">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="mdb:contact" mode="reorder">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="mdb:dateInfo" mode="reorder">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="mdb:identificationInfo" mode="reorder">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="mdb:distributionInfo" mode="reorder">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="mdb:resourceLineage" mode="reorder">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="mdb:metadataScope" mode="reorder">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="mdb:metadataConstraints" mode="reorder">
    <xsl:copy-of select="."/>
  </xsl:template>
  
</xsl:stylesheet>
