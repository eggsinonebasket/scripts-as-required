<xsl:stylesheet version="2.0"
                xmlns:mdb="https://schemas.isotc211.org/19115/-1/mdb/1.3"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
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

  
  
  <xsl:output method="xml" version="1.1" indent="yes" omit-xml-declaration="no" undeclare-prefixes="yes"/>

  <xsl:strip-space elements="*"/>

  <xsl:template match="/">
    <xsl:apply-templates select="//mdb:MD_Metadata" mode="reorder"/>
  </xsl:template>
  
  <xsl:template match="mdb:MD_Metadata" mode="reorder">
    
    <xsl:copy copy-namespaces="yes">
      <xsl:apply-templates select="mdb:metadataIdentifier" mode="reorder"/>
      <xsl:apply-templates select="mdb:defaultLocale" mode="reorder"/>
      <xsl:apply-templates select="mdb:parentMetadata" mode="reorder"/>
      <xsl:apply-templates select="mdb:contact" mode="reorder"/>
      <xsl:apply-templates select="mdb:dateInfo" mode="reorder"/>
      <xsl:apply-templates select="mdb:identificationInfo" mode="reorder"/>
      <xsl:apply-templates select="mdb:distributionInfo" mode="reorder"/>
      <xsl:apply-templates select="mdb:metadataConstraints" mode="reorder"/>
      <xsl:apply-templates select="mdb:resourceLineage" mode="reorder"/>
      <xsl:apply-templates select="mdb:metadataScope" mode="reorder"/>
    </xsl:copy>
  </xsl:template>
    
   
  <xsl:template match="mdb:metadataIdentifier" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mdb:defaultLocale" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mdb:parentMetadata" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mdb:contact" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mdb:dateInfo" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mdb:identificationInfo" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mri:MD_DataIdentification" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="srv:SV_ServiceIdentification" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="mri:citation" mode="reorder"/>
      <xsl:apply-templates select="mri:abstract" mode="reorder"/>
      <xsl:apply-templates select="srv:serviceType" mode="reorder"/>
      <xsl:apply-templates select="srv:coupledResource/srv:SV_CoupledResource" mode="reorder"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mri:citation" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mri:abstract" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="srv:serviceType" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="srv:SV_CoupledResource" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="srv:scopedName" mode="reorder"/>
      <xsl:apply-templates select="srv:resourceReference" mode="reorder"/>
      <xsl:apply-templates select="srv:resource" mode="reorder"/>
      <xsl:apply-templates select="srv:operation" mode="reorder"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="srv:scopedName" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="srv:resourceReference" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="srv:resource" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="srv:operation" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mdb:distributionInfo" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mdb:metadataConstraints" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mdb:resourceLineage" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mdb:metadataScope" mode="reorder">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
 
  
</xsl:stylesheet>
