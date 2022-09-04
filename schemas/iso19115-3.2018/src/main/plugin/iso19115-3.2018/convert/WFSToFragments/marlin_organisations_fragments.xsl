<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
		xmlns:app="http://www.deegree.org/app"
		xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
		xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0"
		xmlns:gml="http://www.opengis.net/gml"
		xmlns:wfs="http://www.opengis.net/wfs"
		xmlns:xlink="http://www.w3.org/1999/xlink"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"		
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

	<!-- 
			 This xslt should transform output from the WFS marlin database
	     feature type MarlinOrganisations
	 -->

	<xsl:template match="wfs:FeatureCollection">
		<xsl:message>Processing <xsl:value-of select="@numberOfFeatures"/></xsl:message>
		<records>
			<xsl:if test="boolean( ./@timeStamp )">
				<xsl:attribute name="timeStamp">
					<xsl:value-of select="./@timeStamp"></xsl:value-of>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="boolean( ./@lockId )">
				<xsl:attribute name="lockId">
					<xsl:value-of select="./@lockId"></xsl:value-of>
				</xsl:attribute>
			</xsl:if>

			<xsl:apply-templates select="gml:featureMember"/>
		</records>
	</xsl:template>

	<xsl:template match="*[@xlink:href]" priority="20">
		<xsl:variable name="linkid" select="substring-after(@xlink:href,'#')"/>
		<xsl:apply-templates select="//*[@gml:id=$linkid]"/>
	</xsl:template>

	<xsl:template match="gml:featureMember">
		<xsl:apply-templates select="app:MarlinOrganisations"/>
	</xsl:template>

	<xsl:template name="doStr">
		<xsl:param name="value"/>
		<xsl:choose>
			<xsl:when test="normalize-space($value)=''">
        <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
				<gco:CharacterString/>
			</xsl:when>
			<xsl:otherwise>
				<gco:CharacterString><xsl:value-of select="$value"/></gco:CharacterString>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="app:MarlinOrganisations">
		<record uuid="urn:marlin.csiro.au:org:{app:organisation_id}">

			<!-- create cit:name and cit:contactInfo so that they can be used in:

			   responsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Organization 
		OR   responsibleParty/cit:CI_Responsibility/cit:party/cit:CI_Individual 
		
						when building datasets and person records
				-->


			<!-- cit:name organisation_name -->

			<fragment id="organisation_name" uuid="urn:marlin.csiro.au:org:{app:organisation_id}_organisation_name" title="name: {app:organisation_name}">
				<gco:CharacterString><xsl:value-of select="app:organisation_name"/></gco:CharacterString>
			</fragment>

			<!-- cit:contactInfo - contact_info - mailing address -->

			<fragment id="contact_info_mailing_address" uuid="urn:marlin.csiro.au:org:{app:organisation_id}_contact_info_mailing_address" title="contact_mailing: {app:organisation_name}">
				<cit:CI_Contact>
					<cit:phone>
						<cit:CI_Telephone>
							<cit:number>
								<xsl:call-template name="doStr">
									<xsl:with-param name="value" select="app:telephone"/>
								</xsl:call-template>
							</cit:number>
              <cit:numberType>
                <cit:CI_TelephoneTypeCode codeList="http://standards.iso.org/iso/19115/resources/Codelist/cat/codelists.xml#CI_RoleCode" codeListValue="voice" />
              </cit:numberType>
						</cit:CI_Telephone>
					</cit:phone>
					<cit:phone>
						<cit:CI_Telephone>
							<cit:number>
								<xsl:call-template name="doStr">
									<xsl:with-param name="value" select="app:facsimile"/>
								</xsl:call-template>
							</cit:number>
              <cit:numberType>
                <cit:CI_TelephoneTypeCode codeList="http://standards.iso.org/iso/19115/resources/Codelist/cat/codelists.xml#CI_RoleCode" codeListValue="facsimile" />
              </cit:numberType>
						</cit:CI_Telephone>
					</cit:phone>
					<cit:address>
						<cit:CI_Address>
							<cit:deliveryPoint>
								<xsl:call-template name="doStr">
									<xsl:with-param name="value" select="normalize-space(concat(app:mail_address_1,' ',app:mail_address_2))"/>
								</xsl:call-template>
							</cit:deliveryPoint>
							<cit:city>
								<xsl:call-template name="doStr">
                  <xsl:with-param name="value" select="app:mail_locality"/>
                </xsl:call-template>
							</cit:city>
							<cit:administrativeArea>
								<xsl:call-template name="doStr">
                  <xsl:with-param name="value" select="app:mail_state"/>
                </xsl:call-template>
							</cit:administrativeArea>
							<cit:postalCode>
								<xsl:call-template name="doStr">
                  <xsl:with-param name="value" select="app:mail_postcode"/>
                </xsl:call-template>
							</cit:postalCode>
							<cit:country>
								<xsl:call-template name="doStr">
                  <xsl:with-param name="value" select="app:country"/>
                </xsl:call-template>
							</cit:country>
							<cit:electronicMailAddress gco:nilReason="missing">
								<gco:CharacterString/>
							</cit:electronicMailAddress>
						</cit:CI_Address>
           </cit:address>
					 <!-- add an online resource here if web address given -->
					 <xsl:if test="app:web_address">
						 <cit:onlineResource>
						 	<cit:CI_OnlineResource>
								<cit:linkage>
									<gco:CharacterString><xsl:value-of select="app:web_address"/></gco:CharacterString>
								</cit:linkage>
								<cit:protocol>
									<gco:CharacterString>WWW:LINK-1.0-http--link</gco:CharacterString>
								</cit:protocol>
								<cit:description>
									<gco:CharacterString>Web address for organisation <xsl:value-of select="app:organisation_name"/></gco:CharacterString>
								</cit:description>
						 	</cit:CI_OnlineResource>
						 </cit:onlineResource>
			 		</xsl:if>
         </cit:CI_Contact>
			</fragment>

			<!-- cit:contactInfo - contact_info - street address -->

			<xsl:if test="app:street_address_1">
			<fragment id="contact_info_street_address" uuid="urn:marlin.csiro.au:org:{app:organisation_id}_contact_info_street_address" title="contact street: {app:organisation_name}">
				<cit:CI_Contact>
					<cit:phone>
						<cit:CI_Telephone>
							<cit:number>
								<xsl:call-template name="doStr">
									<xsl:with-param name="value" select="app:telephone"/>
								</xsl:call-template>
							</cit:number>
              <cit:numberType>
                <cit:CI_TelephoneTypeCode codeList="http://standards.iso.org/iso/19115/resources/Codelist/cat/codelists.xml#CI_RoleCode" codeListValue="voice" />
              </cit:numberType>
						</cit:CI_Telephone>
					</cit:phone>
					<cit:phone>
						<cit:CI_Telephone>
							<cit:number>
								<xsl:call-template name="doStr">
									<xsl:with-param name="value" select="app:facsimile"/>
								</xsl:call-template>
							</cit:number>
              <cit:numberType>
                <cit:CI_TelephoneTypeCode codeList="http://standards.iso.org/iso/19115/resources/Codelist/cat/codelists.xml#CI_RoleCode" codeListValue="facsimile" />
              </cit:numberType>
						</cit:CI_Telephone>
					</cit:phone>
					<cit:address>
						<cit:CI_Address>
							<cit:deliveryPoint>
								<xsl:call-template name="doStr">
									<xsl:with-param name="value" select="normalize-space(concat(app:street_address_1,' ',app:street_address_2,' ',app:street_address_3))"/>
								</xsl:call-template>
							</cit:deliveryPoint>
							<cit:city>
								<xsl:call-template name="doStr">
                  <xsl:with-param name="value" select="normalize-space(concat(app:locality,' ',app:jurisdiction))"/>
                </xsl:call-template>
							</cit:city>
							<cit:administrativeArea>
								<xsl:call-template name="doStr">
                  <xsl:with-param name="value" select="app:state"/>
                </xsl:call-template>
							</cit:administrativeArea>
							<cit:postalCode>
								<xsl:call-template name="doStr">
                  <xsl:with-param name="value" select="app:postcode"/>
                </xsl:call-template>
							</cit:postalCode>
							<cit:country>
								<xsl:call-template name="doStr">
                  <xsl:with-param name="value" select="app:country"/>
                </xsl:call-template>
							</cit:country>
							<cit:electronicMailAddress gco:nilReason="missing">
								<gco:CharacterString/>
							</cit:electronicMailAddress>
						</cit:CI_Address>
           </cit:address>
					 <!-- add an online resource here if web address given -->
					 <xsl:if test="app:web_address">
						 <cit:onlineResource>
						 	<cit:CI_OnlineResource>
								<cit:linkage>
									<gco:CharacterString><xsl:value-of select="app:web_address"/></gco:CharacterString>
								</cit:linkage>
								<cit:protocol>
									<gco:CharacterString>WWW:LINK-1.0-http--link</gco:CharacterString>
								</cit:protocol>
								<cit:description>
									<gco:CharacterString>Web address for organisation <xsl:value-of select="app:organisation_name"/></gco:CharacterString>
								</cit:description>
						 	</cit:CI_OnlineResource>
						 </cit:onlineResource>
			 		</xsl:if>
         </cit:CI_Contact>
			</fragment>
			</xsl:if>

		</record>
	</xsl:template>


</xsl:stylesheet>
