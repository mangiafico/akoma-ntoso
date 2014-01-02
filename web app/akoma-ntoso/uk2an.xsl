<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0/CSD06"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:leg="http://www.tso.co.uk/assets/namespace/legislation"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:date="http://exslt.org/dates-and-times"
	exclude-result-prefixes="leg html math date">

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
<xsl:key name="citation" match="leg:Citation" use="@Number" />


<!-- helper templates -->

<xsl:template name="id">
	<xsl:param name="node" select="." />
	<xsl:choose>
		<xsl:when test="ancestor::leg:BlockAmendment">
			<xsl:value-of select="generate-id($node)" />
		</xsl:when>
		<xsl:when test="$node/self::leg:Schedule">
			<xsl:text>sch</xsl:text>
			<xsl:value-of select="substring-after($node/leg:Number,' ')" />
		</xsl:when>
		<xsl:when test="$node/self::leg:Part">
				<xsl:if test="ancestor::leg:Schedule">
					<xsl:call-template name="id">
					<xsl:with-param name="node" select="ancestor::leg:Schedule" />
				</xsl:call-template>
				<xsl:text>-</xsl:text>
			</xsl:if>
			<xsl:text>part</xsl:text>
			<xsl:value-of select="substring-after($node/leg:Number, ' ')" />
		</xsl:when>
		<xsl:when test="$node/self::leg:Chapter">
			<xsl:if test="ancestor::leg:Part">
				<xsl:call-template name="id">
					<xsl:with-param name="node" select="ancestor::leg:Part" />
				</xsl:call-template>
				<xsl:text>-</xsl:text>
			</xsl:if>
			<xsl:text>ch</xsl:text>
			<xsl:value-of select="substring-after($node/leg:Number, ' ')" />
		</xsl:when>
		<xsl:when test="$node/self::leg:Pblock">
			<xsl:choose>
				<xsl:when test="parent::leg:Body">
					<xsl:text>part</xsl:text>
					<xsl:value-of select="position()" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="id">
						<xsl:with-param name="node" select=".." />
					</xsl:call-template>
					<xsl:text>.</xsl:text>
					<xsl:value-of select="position()" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$node/self::leg:P1group">
			<xsl:choose>
				<xsl:when test="$node/@id">
					<xsl:value-of select="$node/@id" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="generate-id($node)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$node/self::leg:P1">
			<xsl:if test="ancestor::leg:Schedule">
				<xsl:call-template name="id">
					<xsl:with-param name="node" select="ancestor::leg:Schedule" />
				</xsl:call-template>
				<xsl:text>-</xsl:text>
			</xsl:if>
			<xsl:text>sec</xsl:text>
			<xsl:value-of select="$node/leg:Pnumber" />
		</xsl:when>
		<xsl:when test="$node/self::leg:P2">
			<xsl:call-template name="id">
				<xsl:with-param name="node" select="$node/../.." />
			</xsl:call-template>
			<xsl:text>.</xsl:text>
			<xsl:value-of select="$node/leg:Pnumber" />
		</xsl:when>
		<xsl:when test="$node/self::leg:P3">
			<xsl:call-template name="id">
				<xsl:with-param name="node" select="$node/ancestor::*[self::leg:P1 or self::leg:P2][1]" />
			</xsl:call-template>
			<xsl:text>.</xsl:text>
			<xsl:value-of select="$node/leg:Pnumber" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="generate-id($node)" />
		</xsl:otherwise>
	</xsl:choose>
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

<xsl:template match="processing-instruction()">
	<xsl:choose>
		<xsl:when test="name() = 'new-line'">
			<eol />
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:Emphasis">
	<i>
		<xsl:apply-templates />
	</i>
</xsl:template>

<xsl:template match="leg:Strong">
	<b>
		<xsl:apply-templates />
	</b>
</xsl:template>

<xsl:template match="leg:SmallCaps">
	<span style="font-variant:small-caps">
		<xsl:apply-templates />
	</span>
</xsl:template>

<xsl:template match="leg:Inferior">
	<sub>
		<xsl:apply-templates />
	</sub>
</xsl:template>

<xsl:template match="leg:InternalLink">
	<ref class="internal">
		<xsl:attribute name="href">
			<xsl:text>#</xsl:text>
	 		<xsl:call-template name="id">
	 			<xsl:with-param name="node" select="key('id', @Ref)" />
			</xsl:call-template>
		</xsl:attribute>
		<xsl:attribute name="currentId"><xsl:value-of select="generate-id()" /></xsl:attribute>
		<xsl:apply-templates />
	</ref>
</xsl:template>

<xsl:template match="leg:Citation">
	<ref href="#{@id}">
		<xsl:attribute name="href">
			<xsl:text>/</xsl:text>
			<xsl:choose>
				<xsl:when test="@Class = 'UnitedKingdomPublicGeneralAct'">
					<xsl:text>uk</xsl:text>
				</xsl:when>
				<xsl:when test="@Class = 'ScottishAct'">
					<xsl:text>uk/scotland</xsl:text>
				</xsl:when>
				<xsl:when test="@Class = 'EuropeanCommission'">
					<xsl:text>eu</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>uk</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>/bill/</xsl:text>
			<xsl:value-of select="@Year" />
			<xsl:text>/</xsl:text>
			<xsl:choose>
				<xsl:when test="contains(@Number, ' ')">
					<xsl:value-of select="number(substring-before(@Number,' '))" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="number(@Number)" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>/main</xsl:text>
		</xsl:attribute>
		<xsl:attribute name="currentId">
			<xsl:value-of select="generate-id()" />
		</xsl:attribute>
		<xsl:apply-templates />
	</ref>
</xsl:template>

<xsl:template match="leg:Text">
	<xsl:choose>
		<xsl:when test="count(*) = 1 and leg:Formula">
			<xsl:apply-templates select="leg:Formula" />
		</xsl:when>
		<xsl:otherwise>
			<p>
				<xsl:apply-templates />
			</p>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:CoverTitle">
	<p class="center title">
		<xsl:apply-templates />
	</p>
</xsl:template>

<xsl:template match="leg:Para | leg:CoverPara">
	<xsl:apply-templates select="leg:Text | leg:UnorderedList | leg:OrderedList | leg:Formula" />
</xsl:template>

<xsl:template match="leg:FragmentTitle">
<p class="fragment-title">
	<xsl:apply-templates select="leg:Title/*" />
</p>
</xsl:template>

<xsl:template match="leg:BlockAmendment">
	<p>
		<mod currentId="{generate-id()}-mod">
			<quotedStructure currentId="{generate-id()}">
				<xsl:if test="@Format = 'double'">
					<xsl:attribute name="startQuote"><xsl:text>&#8220;</xsl:text></xsl:attribute>
					<xsl:attribute name="endQuote"><xsl:text>&#8221;</xsl:text></xsl:attribute>			
				</xsl:if>
				<xsl:apply-templates select="leg:*" />
			</quotedStructure>
		</mod>
		<xsl:if test="following-sibling::*[1][self::leg:AppendText]">
			<span class="append"><xsl:value-of select="following-sibling::*[1]" /></span>		
		</xsl:if>
	</p>
</xsl:template>


<!-- core hierarchies -->

<xsl:template name="hierarchy">

	<xsl:param name="ename" />
	<xsl:param name="hcontainer-name" select="''" />
	<xsl:param name="num" select="leg:Number" />
	<xsl:param name="heading" select="leg:Title" />
	<xsl:param name="root" select="." />

	<xsl:variable name="id">
		<xsl:call-template name="id" />
	</xsl:variable>

	<xsl:element name="{$ename}">

		<xsl:if test="$ename = 'hcontainer'">
			<xsl:attribute name="name"><xsl:value-of select="$hcontainer-name" /></xsl:attribute>
		</xsl:if>

		<xsl:attribute name="currentId"><xsl:value-of select="$id" /></xsl:attribute>
		
		<xsl:if test="$num">
			<num><xsl:value-of select="$num" /></num>
		</xsl:if>
		
		<xsl:if test="$heading">
			<heading currentId="{$id}-heading">
				<xsl:apply-templates select="$heading/node()" />
			</heading>
		</xsl:if>
		
		<xsl:variable name="sub" select="$root/leg:Part | $root/leg:Chapter | $root/leg:Pblock | $root/leg:P1group | $root/leg:P1 | $root/leg:P2 | $root/leg:P3 | $root/leg:P4 | $root/leg:P5" />
				
		<xsl:choose>

			<xsl:when test="count($sub) = 0">
				<content currentId="{$id}-content">
					<xsl:apply-templates select="$root/leg:Text | $root/leg:BlockAmendment | $root/leg:Formula | $root/leg:Tabular | $root/leg:UnorderedList | $root/leg:OrderedList" />
				</content>
			</xsl:when>

			<xsl:otherwise>
			
				<xsl:variable name="own1" select="$root[1]/leg:Text | $root[1]/leg:BlockAmendment | $root[1]/leg:Formula | $root[1]/leg:Tabular | $root[1]/leg:UnorderedList | $root[1]/leg:OrderedList" />
 
   				<xsl:variable name="pre" select="
 					$own1[following-sibling::leg:Part[1] = $sub[1]] | 
					$own1[following-sibling::leg:Chapter[1] = $sub[1]] | 
					$own1[following-sibling::leg:Pblock[1] = $sub[1]] | 
					$own1[following-sibling::leg:P1group[1] = $sub[1]] |
					$own1[following-sibling::leg:P1[1] = $sub[1]] |
					$own1[following-sibling::leg:P2[1] = $sub[1]] |
					$own1[following-sibling::leg:P3[1] = $sub[1]] |
					$own1[following-sibling::leg:P4[1] = $sub[1]] |
					$own1[following-sibling::leg:P5[1] = $sub[1]]" />
 	
				<xsl:variable name="post" select="
 					$own1[preceding-sibling::leg:Part[1] = $sub[last()]] | 
 					$own1[preceding-sibling::leg:Chapter[1] = $sub[last()]] | 
 					$own1[preceding-sibling::leg:Pblock[1] = $sub[last()]] | 
 					$own1[preceding-sibling::leg:P1group[1] = $sub[last()]] | 
 					$own1[preceding-sibling::leg:P1[1] = $sub[last()]] | 
 					$own1[preceding-sibling::leg:P2[1] = $sub[last()]] | 
 					$own1[preceding-sibling::leg:P3[1] = $sub[last()]] | 
 					$own1[preceding-sibling::leg:P4[1] = $sub[last()]] | 
 					$own1[preceding-sibling::leg:P5[1] = $sub[last()]] | 
					$root[position() > 1]/leg:Text |
					$root[position() > 1]/leg:BlockAmendment |
					$root[position() > 1]/leg:Formula |
					$root[position() > 1]/leg:Tabular |
					$root[position() > 1]/leg:UnorderedList |
					$root[position() > 1]/leg:OrderedList" />

				<xsl:if test="$pre">
					<intro currentId="{$id}-intro">
						<xsl:apply-templates select="$pre" />
					</intro>
				</xsl:if>

				<xsl:apply-templates select="$sub" />

				<xsl:if test="$post">
					<wrap currentId="{$id}-wrap">
						<xsl:apply-templates select="$post" />
					</wrap>
				</xsl:if>

			</xsl:otherwise>
		</xsl:choose>

	</xsl:element>
</xsl:template>

<xsl:template match="leg:Part">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="ename" select="'part'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="leg:Chapter">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="ename" select="'chapter'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="leg:Pblock">
	<xsl:choose>
		<xsl:when test="parent::leg:Chapter">
			<xsl:call-template name="hierarchy">
				<xsl:with-param name="ename" select="'subchapter'" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="hierarchy">
				<xsl:with-param name="ename" select="'part'" />
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:ScheduleBody/leg:P1group">
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="ename" select="'part'" />
	</xsl:call-template>
</xsl:template>
<xsl:template match="leg:P1group">
	<xsl:variable name="p1s" select="leg:P1" />
	<xsl:choose>
		<xsl:when test="count($p1s) = 1">
			<xsl:apply-templates select="$p1s">
				<xsl:with-param name="heading" select="leg:Title" />
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="$p1s" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="P">
	<xsl:param name="ename" />
	<xsl:param name="heading" select="leg:Title" />
	<xsl:param name="para" />
	<xsl:call-template name="hierarchy">
		<xsl:with-param name="ename" select="$ename" />
		<xsl:with-param name="num" select="leg:Pnumber" />
		<xsl:with-param name="heading" select="$heading" />
		<xsl:with-param name="root" select="$para" />
	</xsl:call-template>
</xsl:template>
 
<xsl:template match="leg:P1">
	<xsl:param name="heading" select="leg:Title" />
	<xsl:call-template name="P">
		<xsl:with-param name="ename" select="'section'" />
		<xsl:with-param name="heading" select="$heading" />
		<xsl:with-param name="para" select="leg:P1para" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="leg:BlockAmendment/leg:P1para">
	<xsl:apply-templates select="leg:Text | leg:P2" />
</xsl:template>

<xsl:template match="leg:P2">
	<xsl:call-template name="P">
		<xsl:with-param name="ename" select="'subsection'" />
		<xsl:with-param name="para" select="leg:P2para" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="leg:P1para/leg:P2para">
	<xsl:apply-templates select="leg:Text | leg:P3 | leg:UnorderedList | leg:Tabular" />
</xsl:template>
<xsl:template match="leg:BlockAmendment/leg:P2para">
	<xsl:apply-templates select="leg:Text | leg:P3" />
</xsl:template>

<xsl:template match="leg:P3">
	<xsl:call-template name="P">
		<xsl:with-param name="ename" select="'paragraph'" />
		<xsl:with-param name="para" select="leg:P3para" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="leg:P4">
	<xsl:call-template name="P">
		<xsl:with-param name="ename" select="'subparagraph'" />
		<xsl:with-param name="para" select="leg:P4para" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="leg:P5">
	<xsl:call-template name="P">
		<xsl:with-param name="ename" select="'clause'" />
		<xsl:with-param name="para" select="leg:P5para" />
	</xsl:call-template>
</xsl:template>


<!-- tables of contents -->

<xsl:template name="contents" match="leg:Contents">
	<xsl:apply-templates select="Rubric/leg:Text" />
	<xsl:if test="leg:ContentsTitle">
		<p class="center contents"><xsl:apply-templates select="leg:ContentsTitle/node()" /></p>
	</xsl:if>
	<toc currentId="{generate-id()}" class="body">
		<xsl:apply-templates select="leg:ContentsPart | leg:ContentsChapter | leg:ContentsPblock | leg:ContentsItem" />
	</toc>
	<xsl:apply-templates select="leg:ContentsSchedules" />
</xsl:template>

<xsl:template match="leg:ContentsPart | leg:ContentsChapter | leg:ContentsPblock">
	<xsl:param name="level" select="0" />
	<xsl:for-each select="leg:ContentsNumber | leg:ContentsTitle">
		<tocItem href="#" level="{$level}" class="part">
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="parent::leg:ContentsPart"><xsl:text>part</xsl:text></xsl:when>
					<xsl:when test="parent::leg:ContentsChapter"><xsl:text>chapter</xsl:text></xsl:when>
					<xsl:when test="parent::leg:ContentsPblock"><xsl:text>heading</xsl:text></xsl:when>
				</xsl:choose>
			</xsl:attribute>
			<xsl:value-of select="." />
		</tocItem>
	</xsl:for-each>
	<xsl:apply-templates select="leg:ContentsChapter | leg:ContentsPblock | leg:ContentsItem">
		<xsl:with-param name="level" select="$level + 1" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="leg:ContentsItem">
	<xsl:param name="level" select="0" />
	<tocItem>
		<xsl:attribute name="href">
			<xsl:text>#</xsl:text>
			<xsl:call-template name="id">
				<xsl:with-param name="node" select="key('id', @ContentRef)" />
			</xsl:call-template>
		</xsl:attribute>
		<xsl:attribute name="level"><xsl:value-of select="$level" /></xsl:attribute>
		<xsl:attribute name="class"><xsl:text>section</xsl:text></xsl:attribute>
		<inline name="tocNum"><xsl:value-of select="leg:ContentsNumber" /></inline>
		<inline name="tocHeading"><xsl:value-of select="leg:ContentsTitle" /></inline>
	</tocItem>
</xsl:template>

<xsl:template match="leg:ContentsSchedules">
	<block name="Horizontal Rule" class="short" />
	<toc currentId="{generate-id()}" class="schedules">
		<xsl:apply-templates select="leg:ContentsSchedule" />
	</toc>
</xsl:template>

<xsl:template match="leg:ContentsSchedule">
	<tocItem>
		<xsl:attribute name="href">
			<xsl:text>#</xsl:text>
			<xsl:call-template name="id">
				<xsl:with-param name="node" select="key('id', @ContentRef)" />
			</xsl:call-template>
		</xsl:attribute>
		<xsl:attribute name="level"><xsl:text>0</xsl:text></xsl:attribute>
		<xsl:attribute name="class"><xsl:text>schedule</xsl:text></xsl:attribute>
		<xsl:value-of select="leg:ContentsNumber" />
		<xsl:text> &#8212; </xsl:text>
		<xsl:value-of select="leg:ContentsTitle" />
	</tocItem>
	<xsl:for-each select="leg:ContentsPart">
		<tocItem href="" level="1" class="part">
			<xsl:value-of select="leg:ContentsNumber" />
			<xsl:text> &#8212; </xsl:text>
			<xsl:value-of select="leg:ContentsTitle" />
		</tocItem>
	</xsl:for-each>
</xsl:template>


<!-- lists -->

<xsl:template match="leg:UnorderedList[leg:ListItem/leg:Para/leg:Formula]">
	<blockList currentId="{generate-id()}">
		<xsl:for-each select="leg:ListItem">
			<item currentId="{generate-id()}">
				<xsl:apply-templates select="leg:Para" />
			</item>
		</xsl:for-each>
	</blockList>
</xsl:template>

<xsl:template match="leg:UnorderedList">
	<ul currentId="{generate-id()}">
		<xsl:apply-templates select="leg:ListItem" />
	</ul>
</xsl:template>

<xsl:template match="leg:OrderedList">
	<ol currentId="{generate-id()}">
		<xsl:apply-templates select="leg:ListItem" />
	</ol>
</xsl:template>

<xsl:template match="leg:ListItem">
	<li>
		<xsl:apply-templates select="leg:Para" />
	</li>
</xsl:template>


<!-- tables -->

<xsl:template match="leg:Tabular">
	<table currentId="{generate-id()}">
		<caption>
			<xsl:apply-templates select="leg:Title/node() | html:caption/node()" />
		</caption>
		<xsl:apply-templates select="html:table//html:tr" />
	</table>
</xsl:template>

<xsl:template match="html:tr">
	<tr>
		<xsl:apply-templates select="html:th | html:td" />
	</tr>
</xsl:template>

<xsl:template match="html:th">
	<th>
		<xsl:if test="@colspan">
			<xsl:attribute name="colspan"><xsl:value-of select="@colspan" /></xsl:attribute>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="leg:Text">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<p><xsl:apply-templates /></p>
			</xsl:otherwise>
		</xsl:choose>
	</th>
</xsl:template>

<xsl:template match="html:td">
	<td>
		<p><xsl:apply-templates /></p>
	</td>
</xsl:template>


<!-- math -->

<xsl:template match="leg:Formula">
<foreign xmlns:math="http://www.w3.org/1998/Math/MathML">
	<xsl:apply-templates select="math:*" />
</foreign>
<xsl:apply-templates select="leg:Where" />
</xsl:template>

<xsl:template match="leg:MathElement">
<xsl:apply-templates select="math:*" />
</xsl:template>

<xsl:template match="math:*">
<xsl:copy use-attribute-sets="mathvariant">
	<xsl:apply-templates select="* | node()" />
</xsl:copy>
</xsl:template>

<xsl:template match="leg:Where">
<xsl:apply-templates />
</xsl:template>


<!-- schedules -->

<xsl:template match="leg:Schedules">
<hcontainer name="schedules" currentId="{generate-id()}">
	<heading currentId="{generate-id()}-heading">
		<xsl:apply-templates select="leg:Title/node()" />
	</heading>
	<xsl:apply-templates select="leg:Schedule" />			
</hcontainer>
</xsl:template>

<xsl:template match="leg:Schedule">
<xsl:call-template name="hierarchy">
	<xsl:with-param name="ename" select="'hcontainer'" />
	<xsl:with-param name="hcontainer-name" select="'schedule'" />
	<xsl:with-param name="heading" select="leg:TitleBlock/leg:Title" />
	<xsl:with-param name="root" select="leg:ScheduleBody" />
</xsl:call-template>
</xsl:template>


<!-- meta -->

<xsl:template name="meta">

	<xsl:param name="work-date" />
	<xsl:param name="num" />

	<meta>
		<identification source="#mangiafico">
			<FRBRWork>
				<FRBRthis value="/uk/bill/{$work-date}/{$num}/main" />
				<FRBRuri value="/uk/bill/{$work-date}/{$num}" />
				<FRBRdate date="{$work-date}" name="generation" />
				<FRBRauthor href="#commons" as="#author" />
				<FRBRcountry value="UK" />
				<FRBRnumber value="{$num}" />
				<FRBRprescriptive value="false" />
				<FRBRauthoritative value="true" />
			</FRBRWork>
			<FRBRExpression>
				<FRBRthis value="/uk/bill/{$work-date}/{$num}/eng@/main" />
				<FRBRuri value="/uk/bill/{$work-date}/{$num}/eng@" />
				<FRBRdate date="{$work-date}" name="generation" />
				<FRBRauthor href="#commons" as="#author" />
				<FRBRlanguage language="eng" />
			</FRBRExpression>
			<FRBRManifestation>
				<FRBRthis value="/uk/bill/{$work-date}/{$num}/eng@/main.xml" />
				<FRBRuri value="/uk/bill/{$work-date}/{$num}/eng@.akn" />
				<FRBRdate>
					<xsl:attribute name="date"><xsl:value-of select="$today" /></xsl:attribute>
					<xsl:attribute name="name"><xsl:text>generation</xsl:text></xsl:attribute>
				</FRBRdate>
				<FRBRauthor href="#mangiafico" />
				<FRBRformat value="xml" />
			</FRBRManifestation>
		</identification>

		<references source="#mangiafico">
			<TLCOrganization currentId="commons" href="/ontology/organization/uk/uk.HouseOfCommons" showAs="Commons of the United Kingdom in Parliament" />
			<TLCRole currentId="author" href="/ontology/role/author" showAs="Author"/>
			<TLCPerson currentId="mangiafico" href="/ontology/persons/us.Mangiafico" showAs="Jim Mangiafico" />
		</references>

		<proprietary source="#mangiafico" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:ukm="http://www.tso.co.uk/assets/namespace/metadata">
			<xsl:for-each select="/leg:Legislation/ukm:Metadata/dc:*">
				<xsl:copy><xsl:value-of select="." /></xsl:copy>
			</xsl:for-each>
			<xsl:for-each select="/leg:Legislation//ukm:*[@Value]">
				<xsl:copy><xsl:copy-of select="@Value" /></xsl:copy>
			</xsl:for-each>
		</proprietary>
	</meta>

</xsl:template>


<!-- bills -->

<xsl:template name="bill-name" xmlns:ukm="http://www.tso.co.uk/assets/namespace/metadata" xmlns:dc="http://purl.org/dc/elements/1.1/">
	<xsl:value-of select="substring-before(ukm:Metadata/dc:title, ' Bill')" />
</xsl:template>

<xsl:template name="bill-date" xmlns:ukm="http://www.tso.co.uk/assets/namespace/metadata" xmlns:dc="http://purl.org/dc/elements/1.1/">
	<xsl:variable name="dc-date" select="ukm:Metadata/dc:date" />
	<xsl:value-of select="substring-after(substring-after($dc-date, '/'), '/')" />
	<xsl:text>-</xsl:text>
	<xsl:variable name="month" select="substring-before(substring-after($dc-date, '/'), '/')" />
	<xsl:if test="string-length($month) = 1"><xsl:text>0</xsl:text></xsl:if>
	<xsl:value-of select="$month" />
	<xsl:text>-</xsl:text>
	<xsl:variable name="day" select="substring-before($dc-date, '/')" />
	<xsl:if test="string-length($day) = 1"><xsl:text>0</xsl:text></xsl:if>
	<xsl:value-of select="$day" />
</xsl:template>

<xsl:template name="bill-num" xmlns:ukm="http://www.tso.co.uk/assets/namespace/metadata">
	<xsl:value-of select="substring-after(ukm:Metadata/ukm:BillMetadata/ukm:Number/@Value, ' ')" />
</xsl:template>

<xsl:template name="doctype" xmlns:ukm="http://www.tso.co.uk/assets/namespace/metadata" xmlns:dc="http://purl.org/dc/elements/1.1/">
	<xsl:value-of select="ukm:Metadata/dc:title" />
</xsl:template>


<xsl:template match="/leg:Legislation">
	<bill>
	
		<xsl:attribute name="name">
			<xsl:call-template name="bill-name" />
		</xsl:attribute>
	
		<xsl:call-template name="meta">
			<xsl:with-param name="work-date">
				<xsl:call-template name="bill-date" />
			</xsl:with-param>
			<xsl:with-param name="num">
				<xsl:call-template name="bill-num" />
			</xsl:with-param>
		</xsl:call-template>
	
		<coverPage>
		
			<p class="center">
				<shortTitle>
					<xsl:call-template name="doctype" />
				</shortTitle>
			</p>
			
			<block name="Horizontal Rule" class="double" />
						
			<xsl:apply-templates select="leg:Cover/*" />
			
			<xsl:if test="contains(leg:Primary/leg:PrimaryPrelims/leg:Title,'AS AMENDED IN PUBLIC BILL COMMITTEE')">
				<p class="center"><xsl:text>[AS AMENDED IN PUBLIC BILL COMMITTEE]</xsl:text></p>
			</xsl:if>
		
			<xsl:apply-templates select="leg:Contents" />
			
		</coverPage>		
	
		<preface>
			<p class="center" style="text-transform:uppercase"><xsl:value-of select="normalize-space(leg:Primary/leg:PrimaryPrelims/leg:Title/text()[1])" /></p>	
			<p class="center">
				<docType>
					<xsl:value-of select="normalize-space(leg:Primary/leg:PrimaryPrelims/leg:Title/text()[2])" />
				</docType>
			</p>	
			<p class="center" style="text-transform:uppercase"><xsl:value-of select="normalize-space(leg:Primary/leg:PrimaryPrelims/leg:Title/text()[3])" /></p>	
			<p class="center" style="text-transform:uppercase"><xsl:value-of select="normalize-space(leg:Primary/leg:PrimaryPrelims/leg:Title/text()[4])" /></p>	
				
			<longTitle currentId="{generate-id(leg:Primary/leg:PrimaryPrelims/leg:LongTitle)}">
				<xsl:apply-templates select="leg:Primary/leg:PrimaryPrelims/leg:LongTitle/leg:Para" />
			</longTitle>
		</preface>
		
		<preamble>
			<xsl:apply-templates select="leg:Primary/leg:PrimaryPrelims/leg:PrimaryPreamble/leg:IntroductoryText/leg:P/leg:Text" />
			<formula name="EnactingText" currentId="{generate-id(leg:Primary/leg:PrimaryPrelims/leg:PrimaryPreamble/leg:EnactingText)}">
				<xsl:apply-templates select="leg:Primary/leg:PrimaryPrelims/leg:PrimaryPreamble/leg:EnactingText/leg:Para" />
			</formula>
		</preamble>
	
		<body>
			<xsl:apply-templates select="leg:Primary/leg:Body/leg:*" />
			<xsl:apply-templates select="leg:Primary/leg:Schedules" />			
		</body>
	
	</bill>
</xsl:template>
	
</xsl:stylesheet>
