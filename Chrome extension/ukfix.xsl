<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:leg="http://www.tso.co.uk/assets/namespace/legislation">

<!-- ERROR_XrefPart -->
<xsl:template match="leg:Title/leg:ERROR_XrefPart">
	<xsl:value-of select="." />
</xsl:template>
<xsl:template match="leg:Text[following-sibling::*[1][self::leg:ERROR_XrefPart | self::leg:ERROR_XrefChapter]]">
	<xsl:copy>
		<xsl:apply-templates select="@*" />
		<xsl:apply-templates />
		<xsl:apply-templates select="following-sibling::*[1]">
			<xsl:with-param name="inside" select="true()" />
		</xsl:apply-templates>
	</xsl:copy>
</xsl:template>
<xsl:template match="leg:ERROR_XrefPart | leg:ERROR_XrefChapter">
	<xsl:param name="inside" select="false()" />
	<xsl:if test="$inside">
		<xsl:apply-templates select="leg:Text/node()" />
		<xsl:apply-templates select="following-sibling::*[1][self::leg:Text]">
			<xsl:with-param name="inside" select="true()" />
		</xsl:apply-templates>
	</xsl:if>
</xsl:template>
<xsl:template match="leg:Text[preceding-sibling::*[1][self::leg:ERROR_XrefPart | self::leg:ERROR_XrefChapter]]">
	<xsl:param name="inside" select="false()" />
	<xsl:if test="$inside">
		<xsl:apply-templates select="node()" />
		<xsl:apply-templates select="following-sibling::*[1][self::leg:ERROR_XrefPart | self::leg:ERROR_XrefChapter]">
			<xsl:with-param name="inside" select="true()" />
		</xsl:apply-templates>
	</xsl:if>
</xsl:template>


<!-- ERROR_Undefined_CenteredHeading -->
<xsl:template match="leg:ERROR_Undefined_CenteredHeading">
	<xsl:apply-templates />
</xsl:template>
<xsl:template match="leg:ERROR_Undefined_CenteredHeading/leg:Text">
	<xsl:apply-templates />
</xsl:template>


<!-- P1para with both P2 and P2para as children; P2paras should be children of preceding P2 -->
<xsl:template match="leg:P1para[leg:P2 and leg:P2para]">
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		<xsl:for-each select="*">
			<xsl:choose>
				<xsl:when test="self::leg:P2 and following-sibling::*[1][self::leg:P2para]">
					<xsl:variable name="this" select="." />
					<xsl:copy>
						<xsl:apply-templates select="@*"/>
						<xsl:apply-templates />
						<xsl:apply-templates select="following-sibling::leg:P2para[preceding-sibling::leg:P2[1] = $this]" />
					</xsl:copy>
				</xsl:when>
				<xsl:when test="self::leg:P2para" />
				<xsl:otherwise>
					<xsl:apply-templates select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:copy>
</xsl:template>

<!-- P1para with only P2paras as children; should be separate P1paras -->
<xsl:template match="leg:P1para[not(leg:P2) and leg:P2para]">
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates select="leg:P2para[1]/node()" />
	</xsl:copy>
	<xsl:for-each select="leg:P2para[position() > 1]">
		<P1para xmlns="http://www.tso.co.uk/assets/namespace/legislation">
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates />
		</P1para>
	</xsl:for-each>
</xsl:template>

<!-- P1para with both P2 and P3 as children; P3s should be children of preceding P2 -->
<xsl:template match="leg:P1para[leg:P2 and not(leg:P2para) and leg:P3]">
	<xsl:copy>
		<xsl:apply-templates select="@*" />
		<xsl:for-each select="*">
			<xsl:variable name="this" select="." />
			<xsl:choose>
				<xsl:when test="self::leg:P2 and following-sibling::*[1][self::leg:P3]">
					<xsl:copy>
						<xsl:apply-templates select="@*"/>
						<xsl:apply-templates select="*[position() &lt; last()]" />
						<xsl:for-each select="*[last()]">
							<xsl:copy>
								<xsl:apply-templates select="@*"/>
								<xsl:apply-templates/>
								<xsl:apply-templates select="$this/following-sibling::leg:P3[preceding-sibling::leg:P2[1] = $this] | $this/following-sibling::leg:Text[preceding-sibling::leg:P2[1] = $this]" />
							</xsl:copy>
						</xsl:for-each>
					</xsl:copy>
				</xsl:when>
				<xsl:when test="self::leg:P3 or self::leg:Text" />
				<xsl:otherwise>
					<xsl:apply-templates select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:copy>
</xsl:template>

<!-- P1para with children that don’t belong; should be children of a new P2para, a child of their preceding P2. -->
<xsl:template match="leg:P1para[leg:P2 and not(leg:P2para) and not(leg:P3)]">
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		<xsl:for-each select="*">
			<xsl:variable name="this" select="." />
			<xsl:choose>
				<xsl:when test="self::leg:P2 and following-sibling::leg:P2">
					<xsl:copy>
						<xsl:apply-templates select="@*"/>
						<xsl:apply-templates />
						<xsl:variable name="children" select="following-sibling::*[not(self::leg:P2)][preceding-sibling::leg:P2[1] = $this]" />
						<xsl:if test="$children">
							<P2para xmlns="http://www.tso.co.uk/assets/namespace/legislation">
								<xsl:for-each select="$children">
									<xsl:apply-templates select="." />
								</xsl:for-each>
							</P2para>
						</xsl:if>
					</xsl:copy>
				</xsl:when>
				<xsl:when test="not(self::leg:P2) and following-sibling::leg:P2" />
				<xsl:otherwise>
					<xsl:apply-templates select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:copy>
</xsl:template>

<!-- BlockAmendment siblings of P3 should be children of new P3para under preceding P3 -->
<xsl:template match="leg:P2para[leg:P3 and leg:BlockAmendment]">
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		<xsl:for-each select="*">
			<xsl:variable name="this" select="." />
			<xsl:choose>
				<xsl:when test="self::leg:P3">
					<xsl:copy>
						<xsl:apply-templates select="@*"/>
						<xsl:apply-templates />
						<xsl:for-each select="following-sibling::leg:BlockAmendment[preceding-sibling::leg:P3[1] = $this]">
							<P3para xmlns="http://www.tso.co.uk/assets/namespace/legislation">
								<xsl:apply-templates select="." />
							</P3para>
						</xsl:for-each>
					</xsl:copy>
				</xsl:when>
				<xsl:when test="self::leg:BlockAmendment or self::leg:AppendText" />
				<xsl:otherwise>
					<xsl:apply-templates select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:copy>
</xsl:template>

<!-- BlockAmendment siblings of P4 should be children of new P4para under preceding P4 -->
<xsl:template match="leg:P3para[leg:P4 and leg:BlockAmendment]">
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		<xsl:for-each select="*">
			<xsl:variable name="this" select="." />
			<xsl:choose>
				<xsl:when test="self::leg:P4">
					<xsl:copy>
						<xsl:apply-templates select="@*"/>
						<xsl:apply-templates />
						<xsl:for-each select="following-sibling::leg:BlockAmendment[preceding-sibling::leg:P4[1] = $this]">
							<P4para xmlns="http://www.tso.co.uk/assets/namespace/legislation">
								<xsl:apply-templates select="." />
							</P4para>
						</xsl:for-each>
					</xsl:copy>
				</xsl:when>
				<xsl:when test="self::leg:BlockAmendment or self::leg:AppendText" />
				<xsl:otherwise>
					<xsl:apply-templates select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:copy>
</xsl:template>

<xsl:template match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates select="@*" />
		<xsl:apply-templates />
	</xsl:copy>
</xsl:template>	

</xsl:stylesheet>
