<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
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
			 This xslt transforms output from the WFS marlin database
	     feature type MarlinPersons to ISO XML fragments
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
		<xsl:apply-templates select="app:MarlinPersons"/>
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

	<xsl:template match="app:organisation">
		<xsl:apply-templates select="app:MarlinOrganisations"/>
	</xsl:template>

	<xsl:template match="app:MarlinOrganisations">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="app:MarlinPersons">
		<record uuid="urn:marlin.csiro.au:person:{app:person_id}">

			<xsl:variable name="org">
				<xsl:if test="app:organisation">
					<xsl:apply-templates select="app:organisation"/>
				</xsl:if>
			</xsl:variable>

			<!-- create fragment

			   cit:party/cit:CI_Organisation 

				 with:
				 	 cit:name = organisation name (xlink using organisation_id)
					 cit:contactInfo = organisation CI_Contact (xlink using 
					                                         organisation_id)
				   cit:individual/cit:CI_Individual using 
					         app:surname+app:firstname
									 app:position_name and 
					 				 app:email

				-->


			<!-- cit:party/CI_Organisation -->

			<fragment id="person_organisation" uuid="urn:marlin.csiro.au:person:{app:person_id}_person_organisation" title="{concat(app:surname,', ',app:given_names,'@',$org/app:MarlinOrganisations/app:organisation_name)}">
				<cit:CI_Organisation>

					<!-- cit:name organisation_name -->
					<xsl:choose>
						<xsl:when test="app:organisation_id!='-1'">
					<cit:name xlink:href="local://srv/api/registries/entries/urn:marlin.csiro.au:org:{app:organisation_id}_organisation_name"/>
					<!-- cit:contactInfo organisation_contact_info_mailing_address -->
					<xsl:if test="$org/app:MarlinOrganisations/app:mail_address_1">
						<cit:contactInfo xlink:href="local://srv/api/registries/entries/urn:marlin.csiro.au:org:{app:organisation_id}_contact_info_mailing_address"/>
					</xsl:if>

					<!-- cit:contactInfo organisation_contact_info_street_address -->
					<xsl:if test="$org/app:MarlinOrganisations/app:street_address_1">
						<cit:contactInfo xlink:href="local://srv/api/registries/entries/urn:marlin.csiro.au:org:{app:organisation_id}_contact_info_street_address"/>
					</xsl:if>

						</xsl:when>
						<xsl:otherwise>
					<cit:name gco:nilReason="unknown"/>
						</xsl:otherwise>
					</xsl:choose>

		<!-- cit:individual/cit:CI_Individual -->
		<cit:individual>
			<cit:CI_Individual>
				<!-- cit:name surname, given_names -->
				<cit:name>
					<gco:CharacterString><xsl:value-of select="concat(app:surname,', ',app:given_names)"/></gco:CharacterString>
				</cit:name>

	<xsl:choose>
		<xsl:when test="normalize-space(app:mail_address_1)!=''">

			<cit:contactInfo>
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
									<xsl:with-param name="value" select="app:mail_address_1"/>
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
           				<xsl:with-param name="value" select="''"/>
         				</xsl:call-template>
							</cit:country>
							<cit:electronicMailAddress>
								<xsl:call-template name="doStr">
           				<xsl:with-param name="value" select="app:email"/>
         				</xsl:call-template>
							</cit:electronicMailAddress>
						</cit:CI_Address>
     			</cit:address>
					<!-- add an online resource here if web address given -->
					<xsl:if test="app:web_address">
		 				<cit:onlineResource>
		 					<cit:CI_OnlineResource>
								<cit:linkage>
									<cit:CharacterString><xsl:value-of select="app:web_address"/></cit:CharacterString>
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
			</cit:contactInfo>
		</xsl:when>
		<xsl:when test="normalize-space(app:email)!=''">
			<cit:contactInfo>
				<cit:CI_Contact>
					<cit:address>
						<cit:CI_Address>
							<cit:electronicMailAddress>
								<xsl:call-template name="doStr">
           				<xsl:with-param name="value" select="app:email"/>
         				</xsl:call-template>
							</cit:electronicMailAddress>
						</cit:CI_Address>
     			</cit:address>
				</cit:CI_Contact>
			</cit:contactInfo>
		</xsl:when>
	</xsl:choose>

					<cit:positionName>
						<xsl:call-template name="doStr">
							<xsl:with-param name="value" select="app:position_name"/>
						</xsl:call-template>
					</cit:positionName>
				</cit:CI_Individual>
			</cit:individual>
		</cit:CI_Organisation>
	</fragment>

	</record>
	</xsl:template>


</xsl:stylesheet>
