<?xml version="1.0" encoding="utf-8" ?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0/CSD06"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:date="http://exslt.org/dates-and-times" exclude-result-prefixes="date">

<xsl:param name="today">
	<xsl:choose>
		<xsl:when test="function-available('date:date')">
			<xsl:value-of select="substring(date:date(),1,10)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="'2013-12-31'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:param>

<xsl:param name="stylesheet" select="''" />
<xsl:param name="style-type" select="'text/css'" />

<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" />

<xsl:template match="/">
	<xsl:if test="$stylesheet">
		<xsl:processing-instruction name="xml-stylesheet">
			<xsl:text>href="</xsl:text>
			<xsl:value-of select="$stylesheet" />
			<xsl:text>" type="</xsl:text>
			<xsl:value-of select="$style-type" />
			<xsl:text>"</xsl:text>
		</xsl:processing-instruction>
	</xsl:if>
	<akomaNtoso xsi:schemaLocation="http://docs.oasis-open.org/legaldocml/ns/akn/3.0/CSD06 http://akomantoso.googlecode.com/svn/release/trunk/schema/akomantoso30.xsd">
		<xsl:apply-templates />
	</akomaNtoso>
</xsl:template>


<!-- keys -->

<xsl:key name="id" match="*" use="@id" />
<xsl:key name="committee-name" match="committee-name" use="@committee-id" />
<xsl:key name="sponsor" match="*[self::sponsor|self::cosponsor]" use="@name-id" />
<xsl:key name="term" match="term" use="." />
<xsl:key name="external-xref" match="external-xref" use="@parsable-cite" />


<!-- helper templates -->

<xsl:template name="hyphenate-date">
	<xsl:param name="compact" select="@date" />
	<xsl:value-of select="substring($compact,1,4)"/>
	<xsl:text>-</xsl:text>
	<xsl:value-of select="substring($compact,5,2)"/>
	<xsl:text>-</xsl:text>
	<xsl:value-of select="substring($compact,7,2)"/>
</xsl:template>

<xsl:template name="parse-cite">
	<xsl:param name="cite" select="@parsable-cite" />
	<xsl:if test="substring-before($cite,'/') = 'usc'">
		<xsl:text>http://uscode.house.gov/quicksearch/get.plx?title=</xsl:text>
		<xsl:value-of select="substring-before(substring-after($cite,'/'),'/')"/>
		<xsl:text>&amp;section=</xsl:text>
		<xsl:value-of select="substring-after(substring-after($cite,'/'),'/')"/>
	</xsl:if>
</xsl:template>

<xsl:template name="TitleCaseWord">
  <xsl:param name="text"/>
  <xsl:value-of select="translate(substring($text,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" /><xsl:value-of select="translate(substring($text,2,string-length($text)-1),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" />
</xsl:template>

<xsl:template name="TitleCase">
  <xsl:param name="text"/>
  <xsl:choose>
    <xsl:when test="contains($text,' ')">
      <xsl:call-template name="TitleCaseWord">
        <xsl:with-param name="text" select="substring-before($text,' ')"/>
      </xsl:call-template>
      <xsl:text> </xsl:text>
      <xsl:call-template name="TitleCase">
        <xsl:with-param name="text" select="substring-after($text,' ')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="TitleCaseWord">
        <xsl:with-param name="text" select="$text"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="id">
<xsl:param name="node" select="."/>
<xsl:choose>
	<xsl:when test="$node/ancestor::quoted-block | $node/ancestor::amendment-block">
		<xsl:choose>
			<xsl:when test="$node/@id">
				<xsl:value-of select="$node/@id" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="generate-id($node)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:when test="$node/self::title">
		<xsl:text>title</xsl:text>
		<xsl:value-of select="translate($node/enum, '. ()', '')" />
	</xsl:when>
	<xsl:when test="$node/self::subtitle">
		<xsl:call-template name="id"><xsl:with-param name="node" select="$node/.." /></xsl:call-template>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="translate($node/enum, '. ()', '')" />
	</xsl:when>
	<xsl:when test="$node/self::chapter">
		<xsl:call-template name="id"><xsl:with-param name="node" select="$node/.." /></xsl:call-template>
		<xsl:text>-ch</xsl:text>
		<xsl:value-of select="translate($node/enum, '. ()', '')" />
	</xsl:when>
	<xsl:when test="$node/self::part">
		<xsl:call-template name="id"><xsl:with-param name="node" select="$node/.." /></xsl:call-template>
		<xsl:text>-part</xsl:text>
		<xsl:value-of select="translate($node/enum, '. ()', '')" />
	</xsl:when>
	<xsl:when test="$node/self::section">
		<xsl:choose>
			<xsl:when test="$node/@section-type = 'undesignated-section'">
				<xsl:value-of select="$node/@id" />
			</xsl:when>
			<xsl:when test="$node/parent::legis-body/@changed = 'deleted'">
				<xsl:value-of select="$node/@id" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>sec</xsl:text>
				<xsl:value-of select="translate($node/enum, '. ()', '')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:when test="$node/self::subsection">
		<xsl:call-template name="id"><xsl:with-param name="node" select="$node/.." /></xsl:call-template>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="translate($node/enum, '. ()', '')" />
	</xsl:when>
	<xsl:when test="$node/self::paragraph">
		<xsl:call-template name="id"><xsl:with-param name="node" select="$node/.." /></xsl:call-template>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="translate($node/enum, '. ()', '')" />
	</xsl:when>
	<xsl:when test="$node/self::subparagraph | $node/self::clause | $node/self::subclause | $node/self::point">
		<xsl:call-template name="id"><xsl:with-param name="node" select="$node/.." /></xsl:call-template>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="translate($node/enum, '. ()', '')" />
	</xsl:when>
	<xsl:when test="$node/@id">
		<xsl:value-of select="$node/@id" />
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="generate-id($node)" />
	</xsl:otherwise>
</xsl:choose>
<xsl:if test="string($node/enum) and string($node/preceding-sibling::*[1]/enum) = string($node/enum)"><!-- duplicates -->
	<xsl:text>-bis</xsl:text>
</xsl:if>
</xsl:template>


<!-- basic elements -->

<xsl:template match="text()">
	<xsl:if test="substring(.,1,1) = ' '">
		<xsl:text> </xsl:text>
	</xsl:if>
	<xsl:value-of select="normalize-space()" />
	<xsl:if test="substring(.,string-length(.)) = ' '">
		<xsl:text> </xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template match="linebreak">
	<eol />
</xsl:template>

<xsl:template match="pagebreak">
	<eop />
</xsl:template>

<xsl:template match="italic">
	<i>
		<xsl:apply-templates />
	</i>
</xsl:template>

<xsl:template match="bold">
	<b>
		<xsl:apply-templates />
	</b>
</xsl:template>

<xsl:template match="quote">
	<extractText>
		<xsl:attribute name="startQuote">
			<xsl:choose>
				<xsl:when test="ancestor::quoted-block">
					<xsl:text>&#8216;</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>&#8220;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="endQuote">
			<xsl:choose>
				<xsl:when test="ancestor::quoted-block">
					<xsl:text>&#8217;</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>&#8221;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:apply-templates />
	</extractText>
</xsl:template>

<xsl:template match="term">
	<term currentId="{generate-id()}" refersTo="#{translate(normalize-space(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ ','abcdefghijklmnopqrstuvwxyz')}">
		<xsl:choose>
			<xsl:when test="ancestor::quoted-block"><xsl:text>&#8216;</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>&#8220;</xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="normalize-space()" />
		<xsl:choose>
			<xsl:when test="ancestor::quoted-block"><xsl:text>&#8217;</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>&#8221;</xsl:text></xsl:otherwise>
		</xsl:choose>
	</term>
</xsl:template>

<xsl:template match="internal-xref">
	<ref class="internal">
		<xsl:attribute name="href">
			<xsl:text>#</xsl:text>
	 		<xsl:call-template name="id">
	 			<xsl:with-param name="node" select="key('id', @idref)" />
			</xsl:call-template>
		</xsl:attribute>
		<xsl:attribute name="currentId"><xsl:value-of select="generate-id()" /></xsl:attribute>
		<xsl:apply-templates />
	</ref>
</xsl:template>

<xsl:template match="external-xref">
	<a>
		<xsl:attribute name="href">
			<xsl:call-template name="parse-cite" />
		</xsl:attribute>
		<xsl:apply-templates />
	</a>
</xsl:template>

<xsl:template match="sponsor">
	<docIntroducer refersTo="#{@name-id}">
		<xsl:value-of select="normalize-space()" />
	</docIntroducer>
</xsl:template>

<xsl:template match="cosponsor">
	<docProponent refersTo="#{@name-id}">
		<xsl:value-of select="normalize-space()" />
	</docProponent>
</xsl:template>

<xsl:template match="committee-name">
	<docCommittee refersTo="#{@committee-id}">
		<xsl:value-of select="normalize-space()" />
	</docCommittee>
</xsl:template>

<xsl:template match="proviso">
	<inline name="proviso">
		<xsl:apply-templates />
	</inline>
</xsl:template>

<xsl:template match="short-title">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="enum-in-header">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="header-in-text">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="xm-replace_text">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="text">
	<p>
		<xsl:apply-templates />
	</p>
</xsl:template>

<xsl:template match="quoted-block">
	<xsl:variable name="id">
		<xsl:choose>
			<xsl:when test="@id">
				<xsl:value-of select="@id" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="generate-id()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<p>
		<mod currentId="{$id}-mod">
			<quotedStructure currentId="{$id}">
				<xsl:attribute name="startQuote"><xsl:text>&#8220;</xsl:text></xsl:attribute>
				<xsl:attribute name="endQuote"><xsl:text>&#8221;</xsl:text></xsl:attribute>
				<xsl:apply-templates select="text|chapter|section|subsection|paragraph|subparagraph|clause|subclause|toc" />
				<xsl:if test="quoted-block-continuation-text">
					<block name="continuation" class="{quoted-block-continuation-text/@quoted-block-continuation-text-level}">
						<xsl:apply-templates select="quoted-block-continuation-text/node()" />
					</block>
				</xsl:if>
			</quotedStructure>
		</mod>
		<xsl:if test="after-quoted-block">
			<span class="after"><xsl:value-of select="after-quoted-block" /></span>
		</xsl:if>
	</p>
</xsl:template>


<!-- core hierarchies -->

<xsl:template name="hierarchy">

	<xsl:param name="ename" select="name()" />
	<xsl:param name="name-attr" select="''" />
	<xsl:param name="class" select="''" />	
	<xsl:param name="period" select="''" />
	<xsl:param name="originalId" select="''" />
	<xsl:param name="alternativeTo" select="''" />
	<xsl:param name="style" select="''" />
	<xsl:param name="title" select="''" />
	<xsl:param name="num-prefix" select="''" />
	<xsl:param name="suppress-heading" select="false()" />
	<xsl:param name="subelements" />

	<xsl:element name="{$ename}">

		<xsl:if test="$name-attr">
			<xsl:attribute name="name"><xsl:value-of select="$name-attr" /></xsl:attribute>
		</xsl:if>

		<xsl:variable name="id">
			<xsl:call-template name="id" />
		</xsl:variable>
		<xsl:attribute name="currentId"><xsl:value-of select="$id" /></xsl:attribute>

		<xsl:if test="$class">
			<xsl:attribute name="class"><xsl:value-of select="$class" /></xsl:attribute>
		</xsl:if>

		<xsl:if test="$period">
			<xsl:attribute name="period"><xsl:value-of select="$period" /></xsl:attribute>
		</xsl:if>

		<xsl:if test="$originalId">
			<xsl:attribute name="originalId"><xsl:value-of select="$originalId" /></xsl:attribute>
		</xsl:if>

		<xsl:if test="$alternativeTo">
			<xsl:attribute name="alternativeTo"><xsl:value-of select="$alternativeTo" /></xsl:attribute>
		</xsl:if>

		<xsl:if test="$style">
			<xsl:attribute name="style"><xsl:value-of select="$style" /></xsl:attribute>
		</xsl:if>

		<xsl:if test="$title">
			<xsl:attribute name="title"><xsl:value-of select="$title" /></xsl:attribute>
		</xsl:if>
	
		<xsl:if test="enum">
			<num>
				<xsl:value-of select="$num-prefix" />
				<xsl:apply-templates select="enum/node()" />
			</num>
		</xsl:if>
		
		<xsl:if test="header and not($suppress-heading)">
			<heading currentId="{concat($id,'-heading')}">
  				<xsl:value-of select="normalize-space(header)" />
			</heading>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="$subelements">
				<xsl:if test="text|toc|table">
					<intro currentId="{$id}-intro">
						<xsl:apply-templates select="text|quoted-block|toc|table" />
					</intro>
				</xsl:if>
 				<xsl:apply-templates select="$subelements" />
				<xsl:if test="name(*[last()]) = 'continuation-text'">
					<wrap currentId="{$id}-wrap" class="{*[last()]/@continuation-text-level}">
						<p>
							<xsl:apply-templates select="*[last()]/node()" />
						</p>
					</wrap>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<content currentId="{$id}-content">
					<xsl:apply-templates select="text|quoted-block|toc|table|list" />
 					<xsl:if test="name(*[last()]) = 'continuation-text'">
						<p>
							<xsl:apply-templates select="*[last()]/node()" />
						</p>
					</xsl:if>
				</content>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:template>

<xsl:template match="division">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="num-prefix" select="'Division '" />
		<xsl:with-param name="subelements" select="title|section" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="title">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="num-prefix" select="'Title '" />
		<xsl:with-param name="subelements" select="subtitle|section" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="subtitle">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="num-prefix" select="'Subtitle '" />
		<xsl:with-param name="subelements" select="part|section" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="chapter">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="num-prefix" select="'Chapter '" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="part">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="num-prefix" select="'Part '" />
		<xsl:with-param name="subelements" select="section" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="section">
	<xsl:param name="period" />
	<xsl:param name="originalId" />
	<xsl:param name="alternativeTo" />
	<xsl:param name="style" />
	<xsl:param name="title" />
	<xsl:param name="suppress-heading" select="false()" />
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="period" select="$period" />
		<xsl:with-param name="originalId" select="$originalId" />
		<xsl:with-param name="alternativeTo" select="$alternativeTo" />
		<xsl:with-param name="style" select="$style" />
		<xsl:with-param name="title" select="$title" />
		<xsl:with-param name="num-prefix">
			<xsl:choose>
				<xsl:when test="@section-type = 'section-one'">
					<xsl:text>Section. </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Sec. </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
		<xsl:with-param name="suppress-heading" select="$suppress-heading" />
		<xsl:with-param name="subelements" select="subsection | paragraph" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="subsection">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="subelements" select="paragraph" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="paragraph">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="subelements" select="subparagraph" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="subparagraph">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="subelements" select="clause" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="clause">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="subelements" select="subclause" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="subclause">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="subelements" select="item" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="subclause/item">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="ename" select="'point'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="appropriations-major">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="ename" select="'hcontainer'" />
		<xsl:with-param name="name-attr" select="'appropriations'" />
		<xsl:with-param name="class" select="'major'" />	
		<xsl:with-param name="subelements" select="appropriations-major | appropriations-intermediate | appropriations-small | section" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="appropriations-intermediate">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="ename" select="'hcontainer'" />
		<xsl:with-param name="name-attr" select="'appropriations'" />
		<xsl:with-param name="class" select="'intermediate'" />	
		<xsl:with-param name="subelements" select="appropriations-small | section" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="appropriations-small">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="ename" select="'hcontainer'" />
		<xsl:with-param name="name-attr" select="'appropriations'" />
		<xsl:with-param name="class" select="'small'" />	
		<xsl:with-param name="subelements" select="paragraph" />
	</xsl:call-template>
</xsl:template>


<!-- tables of contents -->

<xsl:template match="toc">
	<toc currentId="{generate-id()}">
		<xsl:apply-templates select="toc-entry|multi-column-toc-entry" />
	</toc>
</xsl:template>

<xsl:template match="toc-entry">
	<tocItem>
		<xsl:attribute name="href">
			<xsl:text>#</xsl:text>
	 		<xsl:call-template name="id">
	 			<xsl:with-param name="node" select="key('id', @idref)" />
			</xsl:call-template>
		</xsl:attribute>
		<xsl:attribute name="level">
			<xsl:choose>
				<xsl:when test="@level = 'division'"><xsl:text>1</xsl:text></xsl:when>
				<xsl:when test="@level = 'title'"><xsl:text>2</xsl:text></xsl:when>
				<xsl:when test="@level = 'subtitle'"><xsl:text>3</xsl:text></xsl:when>
				<xsl:when test="@level = 'part'"><xsl:text>4</xsl:text></xsl:when>
				<xsl:when test="@level = 'section'"><xsl:text>5</xsl:text></xsl:when>
				<xsl:otherwise><xsl:text>6</xsl:text></xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="class"><xsl:value-of select="@level" /></xsl:attribute>
		<xsl:apply-templates />
	</tocItem>
</xsl:template>

<xsl:template match="multi-column-toc-entry">
	<tocItem>
		<xsl:attribute name="href">
			<xsl:text>#</xsl:text>
	 		<xsl:call-template name="id">
	 			<xsl:with-param name="node" select="key('id', @idref)" />
			</xsl:call-template>
		</xsl:attribute>
		<xsl:attribute name="level">
			<xsl:choose>
				<xsl:when test="@level = 'division'"><xsl:text>1</xsl:text></xsl:when>
				<xsl:when test="@level = 'title'"><xsl:text>2</xsl:text></xsl:when>
				<xsl:when test="@level = 'subtitle'"><xsl:text>3</xsl:text></xsl:when>
				<xsl:when test="@level = 'section'"><xsl:text>4</xsl:text></xsl:when>
				<xsl:otherwise><xsl:text>5</xsl:text></xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="class"><xsl:text>multi-column</xsl:text></xsl:attribute>
		<span><xsl:value-of select="toc-enum" /></span>
		<span><xsl:value-of select="level-header" /></span>
		<span><xsl:value-of select="target" /></span>
	</tocItem>
</xsl:template>


<!-- lists -->

<xsl:template match="list">
	<ul class="{@level}" currentId="{generate-id()}">
		<xsl:apply-templates select="list-item" />
	</ul>
</xsl:template>

<xsl:template match="list-item">
	<li>
		<xsl:apply-templates />
	</li>
</xsl:template>


<!-- tables -->

<xsl:template match="table">
	<table currentId="{generate-id()}" class="{@frame}">
		<xsl:choose>
			<xsl:when test="@frame = 'topbot'">
				<caption>
					<xsl:apply-templates select="tgroup/thead/row[1]/entry[1]/node()" />
				</caption>
				<xsl:for-each select="tgroup/thead/row[position() > 1]">
					<tr><xsl:apply-templates select="entry" /></tr>
				</xsl:for-each>
				<xsl:for-each select="tgroup/tbody/row">
					<tr><xsl:apply-templates select="entry" /></tr>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="ttitle">
					<caption>
						<xsl:apply-templates select="ttitle/node()" />
					</caption>
				</xsl:if>
				<xsl:for-each select="*/*/row">
					<tr>
						<xsl:apply-templates select="entry" />
					</tr>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</table>
</xsl:template>

<xsl:template match="thead/row/entry">
	<th>
		<xsl:if test="@namest and @nameend">
			<xsl:attribute name="colspan">
				<xsl:value-of select="number(substring(@nameend,7)) - number(substring(@namest,7))"></xsl:value-of>
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="@align">
			<xsl:attribute name="style">
				<xsl:text>text-align:</xsl:text>
				<xsl:value-of select="@align" />
			</xsl:attribute>
		</xsl:if>
		<p>
			<xsl:apply-templates />
		</p>
	</th>
</xsl:template>

<xsl:template match="tbody/row/entry">
	<td>
		<p>
			<xsl:if test="@align">
				<xsl:attribute name="style">
					<xsl:text>text-align:</xsl:text>
					<xsl:value-of select="@align" />
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates />
		</p>
	</td>
</xsl:template>


<!-- attestations -->

<xsl:template name="attestation" match="attestation">
	<xsl:param name="show-attest" select="true()" />
	<xsl:for-each select="attestation-group">
		<xsl:if test="attestation-date">
			<p>
				<date>
					<xsl:attribute name="date">
						<xsl:call-template name="hyphenate-date">
							<xsl:with-param name="compact" select="attestation-date/@date" />
						</xsl:call-template>
					</xsl:attribute>
					<xsl:value-of select="attestation-date"/>
				</date>
			</p>
		</xsl:if>
	
		<xsl:if test="$show-attest">
			<p>Attest:</p>
		</xsl:if>
	
		<p class="signature">
			<signature>			
				<xsl:if test="attestor != ''">
					<person currentId="{generate-id(attestor)}" refersTo="#{concat('ref',generate-id(attestor))}">
						<xsl:if test="role">
							<xsl:attribute name="as">
								<xsl:text>#</xsl:text>
								<xsl:value-of select="concat('ref',generate-id(role))"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="attestor/@display = 'no'">
							<xsl:attribute name="style">
								<xsl:value-of select="'display:none'" />
							</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="attestor"/>
					</person>
				</xsl:if>
				<xsl:if test="role">
					<role currentId="{generate-id(role)}" refersTo="#{concat('ref',generate-id(role))}">
						<xsl:value-of select="role"/>
					</role>
				</xsl:if>
			</signature>
		</p>
	</xsl:for-each>
</xsl:template>


<!-- meta -->

<xsl:template name="meta-identify">
<xsl:param name="doc-type" select="'bill'" />
<xsl:param name="chamber" select="'house'" />
<xsl:param name="work-date" />
<xsl:param name="num" />
<xsl:param name="prescriptive" select="true()" />
<xsl:param name="expr-date" select="''" />
<xsl:param name="expr-date-type" select="'generation'" />
<xsl:param name="expr-author-id" select="$chamber" />
<identification source="#mangiafico">
	<FRBRWork>
		<FRBRthis value="/us/{$doc-type}/{$chamber}/{$work-date}/{$num}/main" />
		<FRBRuri value="/us/{$doc-type}/{$chamber}/{$work-date}/{$num}" />
		<FRBRdate date="{$work-date}" name="generation" />
		<FRBRauthor href="#{$chamber}" as="#author" />
		<FRBRcountry value="US" />
		<FRBRnumber value="{$num}" />
		<FRBRprescriptive>
			<xsl:attribute name="value">
				<xsl:choose>
					<xsl:when test="$prescriptive"><xsl:text>true</xsl:text></xsl:when>
					<xsl:otherwise><xsl:text>false</xsl:text></xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</FRBRprescriptive>
		<FRBRauthoritative value="true" />
	</FRBRWork>
	<FRBRExpression>
		<FRBRthis value="/us/{$doc-type}/{$chamber}/{$work-date}/{$num}/eng@{$expr-date}/main" />
		<FRBRuri value="/us/{$doc-type}/{$chamber}/{$work-date}/{$num}/eng@{$expr-date}" />
		<FRBRdate>
			<xsl:attribute name="date">
				<xsl:choose>
					<xsl:when test="$expr-date"><xsl:value-of select="$expr-date" /></xsl:when>
					<xsl:otherwise><xsl:value-of select="$work-date" /></xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="name"><xsl:value-of select="$expr-date-type" /></xsl:attribute>
		</FRBRdate>
		<FRBRauthor href="#{$expr-author-id}" as="#author" />
		<FRBRlanguage language="eng" />
	</FRBRExpression>
	<FRBRManifestation>
		<FRBRthis value="/us/{$doc-type}/{$chamber}/{$work-date}/{$num}/eng@{$expr-date}/main.xml" />
		<FRBRuri value="/us/{$doc-type}/{$chamber}/{$work-date}/{$num}/eng@{$expr-date}.akn" />
		<FRBRdate>
			<xsl:attribute name="date"><xsl:value-of select="$today" /></xsl:attribute>
			<xsl:attribute name="name"><xsl:text>generation</xsl:text></xsl:attribute>
		</FRBRdate>
		<FRBRauthor href="#mangiafico" />
		<FRBRformat value="xml" />
	</FRBRManifestation>
</identification>
</xsl:template>

<xsl:template name="meta-lifecycle">
<xsl:if test="form/action[action-date] | //attestation-group[attestation-date]">
	<lifecycle source="#mangiafico">
		<xsl:for-each select="form/action[action-date]">
			<eventRef currentId="ref{generate-id()}">
				<xsl:attribute name="date">
					<xsl:call-template name="hyphenate-date">
						<xsl:with-param name="compact" select="action-date/@date" />
					</xsl:call-template>
				</xsl:attribute>
				<xsl:attribute name="type">
					<xsl:choose>
						<xsl:when test="position() = 1">
							<xsl:text>generation</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>amendment</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="source"><xsl:text>#mangiafico</xsl:text></xsl:attribute>
			</eventRef>
		</xsl:for-each>
		<xsl:for-each select="//attestation-group[attestation-date]">
			<eventRef currentId="ref{generate-id()}">
				<xsl:attribute name="date">
					<xsl:call-template name="hyphenate-date">
		 				<xsl:with-param name="compact" select="attestation-date/@date" />
					</xsl:call-template>
				</xsl:attribute>
				<xsl:attribute name="type"><xsl:text>generation</xsl:text></xsl:attribute>
				<xsl:attribute name="source"><xsl:text>#mangiafico</xsl:text></xsl:attribute>
			</eventRef>
		</xsl:for-each>
	</lifecycle>
</xsl:if>
</xsl:template>

<xsl:template name="meta-references">
	<TLCOrganization currentId="house" href="/ontology/organization/us/us.House" showAs="United States House of Representatives" />
	<TLCOrganization currentId="senate" href="/ontology/organization/us/us.Senate" showAs="United States Senate" />
	<xsl:for-each select="/bill//committee-name[generate-id()=generate-id(key('committee-name', @committee-id)[1])]">
		<TLCOrganization currentId="{@committee-id}" href="/ontology/organization/us/us.{translate(.,' .','')}" showAs="{.}" />
	</xsl:for-each>
	<xsl:for-each select="/bill//*[self::sponsor|self::cosponsor][generate-id()=generate-id(key('sponsor', @name-id)[1])]">
		<xsl:variable name="without-prefix" select="substring-after(., ' ')" />
		<xsl:variable name="without-state">
			<xsl:choose>
				<xsl:when test="contains($without-prefix, ' ')">
					<xsl:value-of select="substring-before($without-prefix, ' ')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$without-prefix" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<TLCPerson currentId="{@name-id}" href="/ontology/persons/us.{translate($without-state,' .','')}" showAs="{.}" />
	</xsl:for-each>
	<xsl:for-each select="//attestor[text()]">
		<TLCPerson currentId="ref{generate-id()}">
			<xsl:attribute name="href">
				<xsl:text>ontology/persons/us.</xsl:text>
				<xsl:value-of select="translate(.,' .','')" />
			</xsl:attribute>
			<xsl:attribute name="showAs"><xsl:value-of select="."/></xsl:attribute>
		</TLCPerson>
	</xsl:for-each>
	<TLCPerson currentId="mangiafico" href="/ontology/persons/us.Mangiafico" showAs="Jim Mangiafico" />
	<xsl:if test="//attestor">
		<TLCRole currentId="attestor" href="/ontology/role/us.attestor" showAs="Attestor"/>
	</xsl:if>
	<xsl:for-each select="attestation/attestation-group/role">
		<TLCRole currentId="ref{generate-id()}">
			<xsl:attribute name="href">
				<xsl:text>ontology/role/us.</xsl:text>
				<xsl:value-of select="translate(.,' .','')" />
			</xsl:attribute>
			<xsl:attribute name="showAs"><xsl:value-of select="."/></xsl:attribute>
		</TLCRole>
	</xsl:for-each>
	<TLCRole currentId="author" href="/ontology/role/author" showAs="Author"/>
	<xsl:if test="count(//legis-body) > 1">
		<TLCConcept currentId="originalLanguage" href="/ontology/concepts/un/originalLanguage" showAs="Original Language"/>
		<TLCConcept currentId="currentLanguage" href="/ontology/concepts/un/currentLanguage" showAs="Current Language"/>
	</xsl:if>
</xsl:template>

<xsl:template name="meta-proprietary">
	<xsl:if test="/bill/metadata/dublinCore/*">
		<proprietary source="#mangiafico" xmlns:dc="http://purl.org/dc/elements/1.1/">
			<xsl:for-each select="/bill/metadata/dublinCore/*">
			<xsl:copy-of select="."/>
			</xsl:for-each>
		</proprietary>
	</xsl:if>
</xsl:template>


<!-- Resolution -->

<xsl:template match="/resolution">
	<bill name="concurrent resolution">
	
		<meta>
		
			<xsl:variable name="work-date">
				<xsl:call-template name="hyphenate-date">
					<xsl:with-param name="compact" select="//attestation[attestation-group/attestation-date][last()]/attestation-group/attestation-date/@date" />
				</xsl:call-template>
			</xsl:variable>
	
			<xsl:call-template name="meta-identify">
				<xsl:with-param name="doc-type" select="'resolution/concurrent'" />
				<xsl:with-param name="work-date" select="$work-date" />
				<xsl:with-param name="num" select="substring-after(form/legis-num, 'H. CON. RES. ')" />
				<xsl:with-param name="prescriptive" select="false()" />
			</xsl:call-template>
		
			<publication
				date="{$work-date}"
				name="H. CON. RES."
				number="{substring-after(form/legis-num, 'H. CON. RES. ')}"
				showAs="{form/legis-num}" />
		
			<xsl:call-template name="meta-lifecycle" />
		
			<references source="#mangiafico">
				<xsl:call-template name="meta-references" />
			</references>
	
		</meta>
	
		<coverPage>
		
			<p style="display:none">
				<docStage><xsl:value-of select="@resolution-stage" /></docStage>
			</p>
	
			<p class="congress">
				<legislature><xsl:value-of select="form/congress" /></legislature>
				<br />
				<session><xsl:value-of select="form/session" /></session>
			</p>
	
			<p><docNumber><xsl:value-of select="form/legis-num"/></docNumber></p>
	
			<p>
				<xsl:if test="form/current-chamber/@display = 'no'">
					<xsl:attribute name="style"><xsl:text>display:none</xsl:text></xsl:attribute>
				</xsl:if>
				<inline name="chamber"><xsl:value-of select="form/current-chamber"/></inline>
			</p>
			
			<block name="Horizontal Rule" />
		
		</coverPage>
		
		<preface>
	
			<p><docType><xsl:value-of select="form/legis-type"/></docType></p>
			
			<p>
				<xsl:if test="form/official-title/@display = 'no'">
					<xsl:attribute name="style"><xsl:text>display:none</xsl:text></xsl:attribute>
				</xsl:if>
				<docTitle>
					<xsl:value-of select="form/official-title"/>
				</docTitle>
			</p>
	
			<p style="display:none">
				<docDate>
					<xsl:attribute name="date">
						<xsl:call-template name="hyphenate-date">
							<xsl:with-param name="compact" select="//attestation-date[1]/@date" />
						</xsl:call-template>
					</xsl:attribute>
				</docDate>
			</p>
	
			<formula name="resolution" currentId="{resolution-body/section[1]/@id}">
				<p>
					<i><xsl:text>Resolved by the House of Representatives (the Senate concurring), </xsl:text></i>
					<xsl:apply-templates select="resolution-body/section[1]/text/node()" />
				</p>
			</formula>
	
		</preface>
	
		<body>
			<xsl:apply-templates select="resolution-body/section[position() > 1]" />
		</body>
	
		<conclusions>
			<xsl:apply-templates select="attestation" />
		</conclusions>
	
	</bill>
</xsl:template>


<!-- Enrolled bill -->

<xsl:template match="/bill[@bill-stage = 'Enrolled-Bill']">
	<bill name="enrolled">

		<meta>
	
			<xsl:variable name="date">
				<xsl:call-template name="hyphenate-date">
					<xsl:with-param name="compact" select="form/enrolled-dateline/@date" />
				</xsl:call-template>
			</xsl:variable>
	
			<xsl:variable name="num">
				<xsl:value-of select="substring-after(form/legis-num, 'H. R. ')" />
			</xsl:variable>
			
			<xsl:call-template name="meta-identify">
				<xsl:with-param name="work-date" select="$date" />
				<xsl:with-param name="num" select="$num" />
				<xsl:with-param name="expr-author-id" select="'congress'" />
			</xsl:call-template>			
			
			<publication date="{$date}" name="H. R." number="{$num}" showAs="{form/legis-num}" />
			
			<references source="#mangiafico">
				<TLCOrganization currentId="congress" href="/ontology/organization/us/us.Congress" showAs="United States Congress" />
				<xsl:call-template name="meta-references" />
			</references>
	
		</meta>
		
		<coverPage>
			<p style="display:none"><docStage><xsl:value-of select="@bill-stage" /></docStage></p>
			<p class="number"><docNumber><xsl:value-of select="form/legis-num"/></docNumber></p>
			<p><legislature>
				<xsl:value-of select="substring-before(form/congress, ' of the United States')"/>
				<br />
				<xsl:text>of the</xsl:text>
				<br />
				<xsl:text>United States of America</xsl:text>
			</legislature></p>
			<p><session><xsl:value-of select="form/session" /></session></p>
			<p class="date">
				<xsl:value-of select="substring-before(form/enrolled-dateline,',')" />
				<xsl:text>,</xsl:text>
				<br />
				<docDate>
					<xsl:attribute name="date">
						<xsl:call-template name="hyphenate-date">
							<xsl:with-param name="compact" select="form/enrolled-dateline/@date" />
						</xsl:call-template>
					</xsl:attribute>
					<xsl:value-of select="substring-after(form/enrolled-dateline,', ')" />
				</docDate>
			</p>
		</coverPage>
	
		<preface>
	
			<p><docType>
				<xsl:call-template name="TitleCase">
					<xsl:with-param name="text" select="form/legis-type" />
				</xsl:call-template>
			</docType></p>
	
			<p class="title"><docTitle><xsl:value-of select="form/official-title"/></docTitle></p>
	
			<xsl:if test="not(legis-body/@display-enacting-clause = 'no-display-enacting-clause')">
				<formula name="enacting clause" currentId="{generate-id(legis-body)}">
					<p>
						<i><xsl:text>Be it enacted by the Senate and House of Representatives of the United States of America in Congress assembled,</xsl:text></i>
					</p>
				</formula>
			</xsl:if>
	
		</preface>
	
		<body>	
			<xsl:apply-templates select="legis-body/section | legis-body/division" />
		</body>
		
		<conclusions>
			<xsl:apply-templates select="attestation">
				<xsl:with-param name="show-attest" select="false()" />
			</xsl:apply-templates>
		</conclusions>

	</bill>
</xsl:template>


<!-- Amendment -->

<xsl:template match="/amendment-doc[@amend-type = 'engrossed-amendment']">
<amendment name="engrossed">		
	
	<xsl:variable name="work-date">
		<xsl:call-template name="hyphenate-date">
			<xsl:with-param name="compact" select="engrossed-amendment-form/action/action-date/@date" />
		</xsl:call-template>
 	</xsl:variable>

	<xsl:variable name="session-date" select="substring($work-date,1,4)" />

	<xsl:variable name="num">
 		<xsl:value-of select="substring-after(engrossed-amendment-form/legis-num, 'H.R. ')" />
	</xsl:variable>	

	<meta>
		<xsl:call-template name="meta-identify">
			<xsl:with-param name="doc-type" select="'amendment'" />
			<xsl:with-param name="chamber" select="'senate'" />
			<xsl:with-param name="work-date" select="$work-date" />
			<xsl:with-param name="num" select="$num" />
		</xsl:call-template>
		
		<xsl:variable name="pub" select="engrossed-amendment-form/legis-num" />
		<publication date="{$work-date}" name="H.R." number="{substring-after($pub, 'H.R. ')}" showAs="{concat($pub, ' Engrossed Amendment Senate (EAS)')}" />
		
		<xsl:call-template name="meta-lifecycle" />

 		<references source="#mangiafico">
 			<xsl:call-template name="meta-references" />
		</references>
	</meta>

	<coverPage>

		<p style="display:none"><legislature><xsl:value-of select="engrossed-amendment-form/congress" /></legislature></p>
		<p style="display:none"><session><xsl:value-of select="engrossed-amendment-form/session" /></session></p>
		<p style="display:none"><docNumber><xsl:value-of select="engrossed-amendment-form/legis-num" /></docNumber></p>

		<p style="text-align:center">
			<inline name="chamber">
					<xsl:value-of select="normalize-space(engrossed-amendment-form/current-chamber)"/>
			</inline>
		</p>

		<p style="text-align:right">
			<docDate date="{$work-date}">
				<xsl:value-of select="engrossed-amendment-form/action/action-date"/>
			</docDate>
		</p>
	</coverPage>

	<preface>

		<formula name="resolution" currentId="{generate-id(engrossed-amendment-body/section[@section-type='resolved'])}">

			<p>
				<i>Resolved, </i>
				<xsl:apply-templates select="engrossed-amendment-body/section[@section-type='resolved']/text/node()" />
			</p>

			<p><docType><xsl:value-of select="engrossed-amendment-form/legis-type"/></docType></p>

		</formula>

	</preface>
	
	<amendmentBody class="{@style}">

		<xsl:apply-templates select="engrossed-amendment-body/amendment" />

		<xsl:if test="title-amends">
			<amendmentContent>
				<p>
					<xsl:apply-templates select="title-amends/official-title-amendment/node()" />
				</p>
			</amendmentContent>
		</xsl:if>

	</amendmentBody>
	
	<conclusions>
		<xsl:apply-templates select="attestation" />
	</conclusions>
	
</amendment>
</xsl:template>

<xsl:template match="/amendment-doc/engrossed-amendment-body/amendment">

	<amendmentContent>
	
		<p>
			<span>
				<xsl:value-of select="normalize-space(amendment-instruction/text)" />
			</span>
		</p>
	
		<xsl:for-each select="amendment-block">
			<p>
 				<xsl:if test="@reported-display-style = 'italic'">
					<xsl:attribute name="style">
						<xsl:text>font-style:italic</xsl:text>
					</xsl:attribute>
				</xsl:if>
				<mod currentId="{generate-id()}">
					<quotedStructure currentId="{generate-id()}q" startQuote="" endQuote="">
 						<xsl:if test="*[1][self::continuation-text]">
							<xsl:element name="{*[1]/@continuation-text-level}">
								<xsl:attribute name="currentId"><xsl:value-of select="generate-id(*[1])"></xsl:value-of></xsl:attribute>
								<xsl:attribute name="class"><xsl:text>continuation</xsl:text></xsl:attribute>
								<content currentId="{generate-id(*[1])}-content">
									<p><xsl:value-of select="normalize-space(*[1])" /></p>
								</content>
							</xsl:element>
						</xsl:if>
						<xsl:for-each select="appropriations-major">
							<hcontainer name="appropriations" currentId="{@id}" class="major">
								<heading currentId="{@id}-heading">
									<xsl:value-of select="normalize-space(header)" />
								</heading>
								<xsl:for-each select="title">
									<title currentId="{@id}">
										<num><xsl:text>Title </xsl:text><xsl:value-of select="enum" /></num>
										<xsl:apply-templates select="appropriations-major|appropriations-intermediate|appropriations-small" />
									</title>
								</xsl:for-each>
							</hcontainer>
						</xsl:for-each>
					</quotedStructure>
				</mod>
			</p>
		</xsl:for-each>
	</amendmentContent>	

</xsl:template>


<!-- Bill reported in the House-->

<xsl:template match="/bill[@bill-stage = 'Reported-in-House']">
	<bill name="reported">
	
		<xsl:choose>
			<xsl:when test="count(legis-body) = 1">
				<xsl:attribute name="contains"><xsl:text>originalVersion</xsl:text></xsl:attribute>
			</xsl:when>
			<xsl:when test="count(legis-body) > 1">
				<xsl:attribute name="contains"><xsl:text>multipleVersions</xsl:text></xsl:attribute>
			</xsl:when>
			<xsl:otherwise />
		</xsl:choose>	
	
		<xsl:variable name="work-date">
			<xsl:call-template name="hyphenate-date">
				<xsl:with-param name="compact" select="form/action[action-date][1]/action-date/@date" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="expr-date">
			<xsl:call-template name="hyphenate-date">
				<xsl:with-param name="compact" select="form/action[action-date][last()]/action-date/@date" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="num">
	 		<xsl:value-of select="substring-after(form/legis-num, 'H. R. ')" />
		</xsl:variable>
	
		<meta>
		
			<xsl:call-template name="meta-identify">
				<xsl:with-param name="work-date" select="$work-date" />
				<xsl:with-param name="num" select="$num" />
				<xsl:with-param name="expr-date" select="$expr-date" />
				<xsl:with-param name="expr-date-type" select="'amendment'" />
				<xsl:with-param name="expr-author-id" select="form//committee-name[last()]/@committee-id" />
			</xsl:call-template>
	
			<publication date="{$expr-date}" name="H. R." number="{$num}" showAs="{form/legis-num}" />
	
			<xsl:call-template name="meta-lifecycle" />
			
			<temporalData source="#mangiafico">
				<temporalGroup currentId="time1">
					<timeInterval refersTo="#originalLanguage" start="#{concat('ref',generate-id(form/action[action-date][1]))}" end="#{concat('ref',generate-id(form/action[action-date][last()]))}"/>
				</temporalGroup>
				<temporalGroup currentId="time2">
					<timeInterval refersTo="#currentLanguage" start="#{concat('ref',generate-id(form/action[action-date][last()]))}"/>
				</temporalGroup>
			</temporalData>
	
			<references source="#mangiafico">
				<xsl:call-template name="meta-references" />
			</references>
	
			<xsl:call-template name="meta-proprietary" />
	
		</meta>
		
		<coverPage>
			<p style="display:none"><docStage><xsl:value-of select="@bill-stage" /></docStage></p>
			<p class="calendar"><inline name="calendar"><xsl:value-of select="form/calendar"/></inline></p>
	
			<p class="congress">
				<legislature><xsl:value-of select="form/congress" /></legislature>
				<br />
				<session><xsl:value-of select="form/session" /></session>
			</p>
	
			<p><docNumber><xsl:value-of select="form/legis-num"/></docNumber></p>
	
			<p><relatedDocument href="/us/report/house/113-30/main"><xsl:value-of select="form/associated-doc"/></relatedDocument></p>
			
			<p class="title"><docTitle><xsl:value-of select="/bill/form/official-title"/></docTitle></p>
			
			<block name="Horizontal Rule" />
					
			<p><inline name="chamber"><xsl:value-of select="form/current-chamber"/></inline></p>
		
			<xsl:for-each select="form/action[action-date]">
				<container name="action" currentId="{generate-id()}">
					<p>
						<date>
							<xsl:attribute name="date">
								<xsl:call-template name="hyphenate-date">
									<xsl:with-param name="compact" select="action-date/@date" />
								</xsl:call-template>
							</xsl:attribute>
							<xsl:value-of select="action-date"/>
						</date>
					</p>
					<p class="description">
						<event refersTo="{concat('ref',generate-id())}" currentId="{generate-id(action-desc)}">
							<xsl:apply-templates select="action-desc/node()" />
						</event>
					</p>
					<xsl:if test="action-instruction">
						<p class="instruction">
							<xsl:text>[</xsl:text>
							<xsl:value-of select="action-instruction"/>
							<xsl:text>]</xsl:text>
						</p>
					</xsl:if>
				</container>
			</xsl:for-each>
			
			<block name="Horizontal Rule" />
		
		</coverPage>
	
		<preface>
	
			<p><docType><xsl:value-of select="/bill/form/legis-type"/></docType></p>
			
			<p class="title">
				<docTitle><xsl:value-of select="/bill/form/official-title"/></docTitle>
				<eop />
			</p>
		
			<formula name="enacting clause" currentId="{generate-id(legis-body)}">
				<p>
					<i><xsl:text>Be it enacted by the Senate and House of Representatives of the United States of America in Congress assembled,</xsl:text></i>
				</p>
			</formula>
	
		</preface>		
	
		<body>
			<xsl:choose>
				<xsl:when test="count(legis-body) = 1">
					<xsl:apply-templates select="legis-body/section" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="legis-body[1]/section">
						<xsl:apply-templates select=".">
							<xsl:with-param name="period" select="'#time1'" />
							<xsl:with-param name="originalId">
								<xsl:text>sec</xsl:text>
								<xsl:value-of select="translate(enum, '. ()', '')" />
							</xsl:with-param>
							<xsl:with-param name="style" select="'text-decoration:line-through'" />
						</xsl:apply-templates>
					</xsl:for-each>
					<xsl:for-each select="legis-body[2]/section">
						<xsl:variable name="pos" select="position()" />
						<xsl:apply-templates select=".">
							<xsl:with-param name="period" select="'#time2'" />
							<xsl:with-param name="alternativeTo" select="parent::*/preceding-sibling::*[1]/section[$pos]/@id" />
							<xsl:with-param name="style" select="'font-style:italic'" />
						</xsl:apply-templates>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</body>
	
	</bill>
</xsl:template>

</xsl:stylesheet>
