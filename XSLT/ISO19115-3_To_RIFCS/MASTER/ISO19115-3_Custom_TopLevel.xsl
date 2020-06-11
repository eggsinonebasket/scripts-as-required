<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="">
    
    
    <!--Copy this file and rename it as for example ISO19115_1_IMOS_TopLevel.xsl for whichever contributor (IMOS in this case)
        as this file contains processing specific to the contributor of ISO19115-1 (overriding templates of imported xsl files)
       
       Calls ISO19115_1_Common_MiddleFilter.xsl that removes version after namespace so that files with slightly 
       different versions, yet not much difference, can be handled in ISO19115-1_Common_Base.xsl - e.g. whether they have
       http://standards.iso.org/iso/19115/-3/mdb/1.0 or http://standards.iso.org/iso/19115/-3/mdb/2.0 they will
       be transformed by the ISO19115_1_Common_MiddleFilter.xsl to have http://standards.iso.org/iso/19115/-3/mdb and then 
       passed to ISO19115-1_Common_Base.xsl for shared processing.
       
       If you need to handle anything specific to the version, put them in higher levels to handle those
        -   either in this very ISO19115_1_Custom_TopLevel.xsl if specific to contributor, or in the 
            ISO19115_1_Common_MiddleFilter.xsl if it's a 2.0 thing for example, that
            multiple providers may have but that is not handled in ISO19115_1_Common_Base.xsl
    -->
    
    <xsl:import href="ISO19115_1_Common_MiddleFilter.xsl"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">
        <xsl:apply-templates mode="middleFilter"/>
    </xsl:template>
      
</xsl:stylesheet>
