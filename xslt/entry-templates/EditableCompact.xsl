<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tc="http://periapsis.org/tellico/"
                exclude-result-prefixes="tc"
                version="1.0">

<!--
  Compact entry template with direct field editing.
  It imports Tellico's native Compact template and only overrides the
  entry body, keeping the standard compact appearance and image layout.
-->
<xsl:import href="Compact.xsl"/>

<xsl:template match="tc:entry">
 <xsl:variable name="entry" select="."/>

 <!-- Preserve the native Compact image block -->
 <div id="images">
  <xsl:for-each select="../tc:fields/tc:field[@type=10]">
   <xsl:variable name="image" select="$entry/*[local-name(.) = current()/@name]"/>
   <xsl:if test="$image">
    <div class="img-shadow">
     <a>
      <xsl:attribute name="href">
       <xsl:choose>
        <xsl:when test="$entry/tc:amazon">
         <xsl:value-of select="$entry/tc:amazon"/>
        </xsl:when>
        <xsl:otherwise>
         <xsl:call-template name="image-link">
          <xsl:with-param name="image" select="key('imagesById', $image)"/>
          <xsl:with-param name="dir" select="$imgdir"/>
         </xsl:call-template>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:attribute>
      <img alt="">
       <xsl:attribute name="src">
        <xsl:call-template name="image-link">
         <xsl:with-param name="image" select="key('imagesById', $image)"/>
         <xsl:with-param name="dir" select="$imgdir"/>
        </xsl:call-template>
       </xsl:attribute>
       <xsl:call-template name="image-size">
        <xsl:with-param name="limit-width" select="150"/>
        <xsl:with-param name="limit-height" select="200"/>
        <xsl:with-param name="image" select="key('imagesById', $image)"/>
       </xsl:call-template>
      </img>
     </a>
    </div>
    <br/>
   </xsl:if>
  </xsl:for-each>
 </div>

 <div id="content">
  <table>
   <tbody>
    <xsl:for-each select="../tc:fields/tc:field[@type!=10 and not(contains($skip-list, concat(',',@name,',')))]">
     <xsl:variable name="field" select="."/>
     <xsl:variable name="has-value"
                   select="$entry/*[local-name(.) = $field/@name] or
                           $entry//*[local-name(.) = $field/@name and starts-with(local-name(..), $field/@name)]"/>

     <!-- Table fields stay display-only. Empty simple fields remain visible so
          they can receive a value without opening the full entry editor. -->
     <xsl:if test="@type != 8 or $has-value">
      <tr>
       <th class="fieldName">
        <xsl:value-of select="@title"/>
        <xsl:text>:</xsl:text>
       </th>

       <td class="fieldValue">
        <xsl:choose>
         <!-- Table fields remain read-only in this first version -->
         <xsl:when test="@type = 8">
          <xsl:choose>
           <xsl:when test="$field/tc:prop[@name = 'columns'] &gt; 1">
            <table>
             <tbody>
              <xsl:for-each select="$entry//*[local-name(.) = $field/@name]">
               <tr>
                <xsl:for-each select="tc:column">
                 <xsl:choose>
                  <xsl:when test="position() = 1">
                   <td class="column1">
                    <xsl:value-of select="."/>
                    <xsl:text>&#160;</xsl:text>
                   </td>
                  </xsl:when>
                  <xsl:otherwise>
                   <td class="column2">
                    <xsl:value-of select="."/>
                    <xsl:text>&#160;</xsl:text>
                   </td>
                  </xsl:otherwise>
                 </xsl:choose>
                </xsl:for-each>
               </tr>
              </xsl:for-each>
             </tbody>
            </table>
           </xsl:when>
           <xsl:otherwise>
            <ul>
             <xsl:for-each select="$entry//*[local-name(.) = $field/@name]">
              <li><xsl:value-of select="."/></li>
             </xsl:for-each>
            </ul>
           </xsl:otherwise>
          </xsl:choose>
         </xsl:when>

         <!-- All other fields become a tc: action handled inside EntryView -->
         <xsl:otherwise>
          <a style="color: inherit; text-decoration: none; cursor: text; border-bottom: 1px dotted currentColor;">
           <xsl:attribute name="href">
            <xsl:text>tc:edit_field?field=</xsl:text>
            <xsl:value-of select="@name"/>
           </xsl:attribute>
           <xsl:attribute name="title">Click to edit</xsl:attribute>

           <xsl:choose>
            <xsl:when test="not($has-value)">
             <span style="opacity: 0.55;">&#8212;</span>
            </xsl:when>
            <xsl:when test="@type = 2">
             <xsl:value-of select="$entry/*[local-name(.) = $field/@name]" disable-output-escaping="yes"/>
            </xsl:when>
            <!-- Avoid nested links for URL fields -->
            <xsl:when test="@type = 7">
             <xsl:value-of select="$entry/*[local-name(.) = $field/@name]"/>
            </xsl:when>
            <xsl:otherwise>
             <xsl:call-template name="simple-field-value">
              <xsl:with-param name="entry" select="$entry"/>
              <xsl:with-param name="field" select="$field/@name"/>
             </xsl:call-template>
            </xsl:otherwise>
           </xsl:choose>
          </a>
         </xsl:otherwise>
        </xsl:choose>
       </td>
      </tr>
     </xsl:if>
    </xsl:for-each>
   </tbody>
  </table>

  <!-- Preserve loan information from the native Compact template -->
  <xsl:for-each select="key('loansByEntry', tc:id)">
   <table>
    <tr>
     <th class="fieldName"><i18n>Borrower</i18n></th>
     <td class="fieldValue"><xsl:value-of select="../@name"/></td>
    </tr>
    <tr>
     <th class="fieldName"><i18n>Loan Date</i18n></th>
     <td class="fieldValue"><xsl:value-of select="@loanDate"/></td>
    </tr>
    <tr>
     <th class="fieldName"><i18n>Due Date</i18n></th>
     <td class="fieldValue"><xsl:value-of select="@dueDate"/></td>
    </tr>
    <tr>
     <th class="fieldName"><i18n>Note</i18n></th>
     <td class="fieldValue"><xsl:value-of select="."/></td>
    </tr>
   </table>
  </xsl:for-each>
 </div>
</xsl:template>

</xsl:stylesheet>
