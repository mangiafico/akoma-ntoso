<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template name="month-num">
	<xsl:param name="text" />
	<xsl:choose>
		<xsl:when test="$text = 'January'">
			<xsl:text>01</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'February'">
			<xsl:text>02</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'March'">
			<xsl:text>03</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'April'">
			<xsl:text>04</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'May'">
			<xsl:text>05</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'June'">
			<xsl:text>06</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'July'">
			<xsl:text>07</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'August'">
			<xsl:text>08</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'September'">
			<xsl:text>09</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'October'">
			<xsl:text>10</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'November'">
			<xsl:text>11</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'December'">
			<xsl:text>12</xsl:text>
		</xsl:when>
		<xsl:otherwise />
	</xsl:choose>
</xsl:template>

<xsl:template name="tens">
	<xsl:param name="text" />
	<xsl:choose>
		<xsl:when test="$text = 'twenty'">
			<xsl:text>2</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'thirty'">
			<xsl:text>3</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'forty'">
			<xsl:text>4</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'fifty'">
			<xsl:text>5</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'sixty'">
			<xsl:text>6</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'seventy'">
			<xsl:text>7</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'eighty'">
			<xsl:text>8</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'ninty'">
			<xsl:text>9</xsl:text>
		</xsl:when>
		<xsl:otherwise />
	</xsl:choose>
</xsl:template>

<xsl:template name="ones">
	<xsl:param name="text" />
	<xsl:choose>
		<xsl:when test="$text = 'one'">
			<xsl:text>1</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'two'">
			<xsl:text>2</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'three'">
			<xsl:text>3</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'four'">
			<xsl:text>4</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'five'">
			<xsl:text>5</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'six'">
			<xsl:text>6</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'seven'">
			<xsl:text>7</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'eight'">
			<xsl:text>8</xsl:text>
		</xsl:when>
		<xsl:when test="$text = 'nine'">
			<xsl:text>9</xsl:text>
		</xsl:when>
		<xsl:otherwise />
	</xsl:choose>
</xsl:template>

<xsl:template name="parse-old-fashioned-date">
	<xsl:param name="text" />
	<!-- assumes text begins with a weekday -->
	<xsl:variable name="date-str" select="substring-after($text,', the ')" />
	
	<xsl:variable name="year-str" select="substring-after($date-str, ', ')" />
	<xsl:variable name="century" select="substring-before($year-str, ' and ')" />
	<xsl:choose>
		<xsl:when test="$century = 'nineteen hundred'">
			<xsl:text>19</xsl:text>
		</xsl:when>
		<xsl:when test="$century = 'two thousand'">
			<xsl:text>20</xsl:text>
		</xsl:when>
		<xsl:when test="$century = 'twenty-one hundred'">
			<xsl:text>21</xsl:text>
		</xsl:when>
		<xsl:otherwise />
	</xsl:choose>
	<xsl:variable name="decade" select="substring-after($year-str, ' and ')" />
	<xsl:choose>
		<xsl:when test="$decade = 'ten'">
			<xsl:text>10</xsl:text>
		</xsl:when>
		<xsl:when test="$decade = 'eleven'">
			<xsl:text>11</xsl:text>
		</xsl:when>
		<xsl:when test="$decade = 'twelve'">
			<xsl:text>12</xsl:text>
		</xsl:when>
		<xsl:when test="$decade = 'thirteen'">
			<xsl:text>13</xsl:text>
		</xsl:when>
		<xsl:when test="$decade = 'fourteen'">
			<xsl:text>14</xsl:text>
		</xsl:when>
		<xsl:when test="$decade = 'fifteen'">
			<xsl:text>15</xsl:text>
		</xsl:when>
		<xsl:when test="$decade = 'sixteen'">
			<xsl:text>16</xsl:text>
		</xsl:when>
		<xsl:when test="$decade = 'seventeen'">
			<xsl:text>17</xsl:text>
		</xsl:when>
		<xsl:when test="$decade = 'eighteen'">
			<xsl:text>18</xsl:text>
		</xsl:when>
		<xsl:when test="$decade = 'nineteen'">
			<xsl:text>19</xsl:text>
		</xsl:when>
		<xsl:when test="contains($decade, '-')">
			<xsl:call-template name="tens">
				<xsl:with-param name="text" select="substring-before($decade, '-')" />
			</xsl:call-template>
			<xsl:call-template name="ones">
				<xsl:with-param name="text" select="substring-after($decade, '-')" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="tens">
				<xsl:call-template name="tens">
					<xsl:with-param name="text" select="$decade" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="ones">
				<xsl:call-template name="ones">
					<xsl:with-param name="text" select="$decade" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$tens">
					<xsl:value-of select="$tens" />
					<xsl:text>0</xsl:text>
				</xsl:when>
				<xsl:when test="$ones">
					<xsl:text>0</xsl:text>
					<xsl:value-of select="$ones" />
				</xsl:when>
				<xsl:otherwise />
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>

	<xsl:call-template name="month-num">
		<xsl:with-param name="text" select="substring-before(substring-after($date-str, 'day of '), ',')" />
	</xsl:call-template>

	<xsl:variable name="day-str" select="substring-before($date-str, ' day')" />
	<xsl:choose>
		<xsl:when test="$day-str = 'first'">
			<xsl:text>01</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'second'">
			<xsl:text>02</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'third'">
			<xsl:text>03</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'fourth'">
			<xsl:text>04</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'fifth'">
			<xsl:text>05</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'sixth'">
			<xsl:text>06</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'seventh'">
			<xsl:text>07</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'eighth'">
			<xsl:text>08</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'ninth'">
			<xsl:text>09</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'tenth'">
			<xsl:text>10</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'eleventh'">
			<xsl:text>11</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'twelveth'">
			<xsl:text>12</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'thirteenth'">
			<xsl:text>13</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'fourteenth'">
			<xsl:text>14</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'fifteenth'">
			<xsl:text>15</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'sixteenth'">
			<xsl:text>16</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'seventeenth'">
			<xsl:text>17</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'eighteenth'">
			<xsl:text>18</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'nineteenth'">
			<xsl:text>19</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'twentieth'">
			<xsl:text>20</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'twenty-first'">
			<xsl:text>21</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'twenty-second'">
			<xsl:text>22</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'twenty-third'">
			<xsl:text>23</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'twenty-fourth'">
			<xsl:text>24</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'twenty-fifth'">
			<xsl:text>25</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'twenty-sixth'">
			<xsl:text>26</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'twenty-seventh'">
			<xsl:text>27</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'twenty-eighth'">
			<xsl:text>28</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'twenty-ninth'">
			<xsl:text>29</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'thirtieth'">
			<xsl:text>30</xsl:text>
		</xsl:when>
		<xsl:when test="$day-str = 'thirty-first'">
			<xsl:text>31</xsl:text>
		</xsl:when>
		<xsl:otherwise />
	</xsl:choose>

</xsl:template>

<xsl:template name="parse-date">
	<xsl:param name="text" />
	<xsl:value-of select="substring-after($text, ', ')" />
	<xsl:call-template name="month-num">
		<xsl:with-param name="text" select="substring-before($text, ' ')" />
	</xsl:call-template>
	<xsl:value-of select="substring-before(substring-after($text, ' '), ',')" />
</xsl:template>


<xsl:template match="engrossed-amendment-form/action/action-date">
	<xsl:copy>
		<xsl:apply-templates select="@*" />
		<xsl:attribute name="date">
			<xsl:call-template name="parse-date">
				<xsl:with-param name="text" select="translate(string(.), '.', '')" />
			</xsl:call-template>
		</xsl:attribute>
		<xsl:apply-templates />
	</xsl:copy>
</xsl:template>


<xsl:template match="enrolled-dateline">
	<xsl:copy>
		<xsl:apply-templates select="@*" />
		<xsl:attribute name="date">
			<xsl:call-template name="parse-old-fashioned-date">
				<xsl:with-param name="text" select="substring-after(string(.),' on ')" />
			</xsl:call-template>
		</xsl:attribute>
		<xsl:apply-templates />
	</xsl:copy>
</xsl:template>


<xsl:template name="next-sibling-index">
	<xsl:param name="elements" />
	<xsl:param name="older-sibling-level" select="0" />
	<xsl:param name="older-sibling-name" select="''" />
	<xsl:param name="older-sibling-has-content" select="false()" />
	<xsl:param name="absolute-position" select="1" />
	<xsl:choose>
		<xsl:when test="count($elements) = 0"><xsl:value-of select="0" /></xsl:when>
 		<xsl:when test="$absolute-position = 1">
			<xsl:call-template name="next-sibling-index">
				<xsl:with-param name="elements" select="$elements[position() &gt; 1]" />
				<xsl:with-param name="older-sibling-level" select="0" />
				<xsl:with-param name="older-sibling-name" select="name($elements[1])" />
				<xsl:with-param name="older-sibling-has-content" select="count($elements[1]/text) = 1" />
				<xsl:with-param name="absolute-position" select="$absolute-position + 1" />
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="($older-sibling-name = 'appropriations-major' and name($elements[1]) = 'appropriations-intermediate') or ($older-sibling-name = 'appropriations-intermediate' and name($elements[1]) = 'appropriations-small')">
			<xsl:call-template name="next-sibling-index">
				<xsl:with-param name="elements" select="$elements[position() > 1]" />
				<xsl:with-param name="older-sibling-level" select="$older-sibling-level + 1" />
				<xsl:with-param name="older-sibling-name" select="name($elements[1])" />
				<xsl:with-param name="older-sibling-has-content" select="count($elements[1]/text) > 0" />
				<xsl:with-param name="absolute-position" select="$absolute-position + 1" />
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="($older-sibling-name = 'appropriations-small' and name($elements[1]) = 'appropriations-intermediate') or ($older-sibling-name = 'appropriations-intermediate' and name($elements[1]) = 'appropriations-major')">
			<xsl:variable name="new-level" select="$older-sibling-level - 1" />
			<xsl:choose>
				<xsl:when test="$new-level = 0">
					<xsl:value-of select="$absolute-position" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="next-sibling-index">
						<xsl:with-param name="elements" select="$elements[position() > 1]" />
						<xsl:with-param name="older-sibling-level" select="$new-level" />
						<xsl:with-param name="older-sibling-name" select="name($elements[1])" />
						<xsl:with-param name="older-sibling-has-content" select="count($elements[1]/text) > 0" />
						<xsl:with-param name="absolute-position" select="$absolute-position + 1" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$older-sibling-name = 'appropriations-small' and name($elements[1]) = 'appropriations-major'">
			<xsl:variable name="new-level" select="$older-sibling-level - 2" />
			<xsl:choose>
				<xsl:when test="$new-level = 0">
					<xsl:value-of select="$absolute-position" />
				</xsl:when>
 				<xsl:otherwise>
					<xsl:call-template name="next-sibling-index">
						<xsl:with-param name="elements" select="$elements[position() > 1]" />
						<xsl:with-param name="older-sibling-level" select="$new-level" />
						<xsl:with-param name="older-sibling-name" select="name($elements[1])" />
						<xsl:with-param name="older-sibling-has-content" select="count($elements[1]/text) > 0" />
						<xsl:with-param name="absolute-position" select="$absolute-position + 1" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$older-sibling-name = name($elements[1])">
			<xsl:choose>
 				<xsl:when test="$older-sibling-name = 'appropriations-major' and not($older-sibling-has-content)">
					<xsl:call-template name="next-sibling-index">
						<xsl:with-param name="elements" select="$elements[position() > 1]" />
						<xsl:with-param name="older-sibling-level" select="$older-sibling-level + 1" />
						<xsl:with-param name="older-sibling-name" select="name($elements[1])" />
						<xsl:with-param name="older-sibling-has-content" select="count($elements[1]/text) > 0" />
						<xsl:with-param name="absolute-position" select="$absolute-position + 1" />
					</xsl:call-template>
				</xsl:when>
  				<xsl:when test="$older-sibling-level = 0">
					<xsl:value-of select="$absolute-position" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="next-sibling-index">
						<xsl:with-param name="elements" select="$elements[position() > 1]" />
						<xsl:with-param name="older-sibling-level" select="$older-sibling-level" />
						<xsl:with-param name="older-sibling-name" select="name($elements[1])" />
						<xsl:with-param name="older-sibling-has-content" select="count($elements[1]/text) > 0" />
						<xsl:with-param name="absolute-position" select="$absolute-position + 1" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
 		<xsl:otherwise>
			<xsl:value-of select="-1" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="amendment-block/appropriations-major[following-sibling::title]">
<xsl:copy>
	<xsl:apply-templates select="@*" />
	<xsl:apply-templates />
	<xsl:variable name="this" select="." />
	<xsl:for-each select="following-sibling::title[preceding-sibling::appropriations-major[1] = $this]">
		<xsl:copy>
			<xsl:apply-templates select="@*" />
			<xsl:apply-templates select="enum" />
			<xsl:call-template name="appropriations" />
		</xsl:copy>
	</xsl:for-each>
</xsl:copy>
</xsl:template>

<xsl:template match="amendment-block/title[preceding-sibling::appropriations-major]" />

<xsl:template match="amendment-block/title/appropriations-major | amendment-block/title/appropriations-intermediate | amendment-block/title/appropriations-small" />

<xsl:template name="appropriations">
	<xsl:param name="elements" select="appropriations-major|appropriations-intermediate|appropriations-small" />
	<xsl:if test="count($elements) > 0">
		<xsl:variable name="first" select="$elements[1]" />
 		<xsl:variable name="next-sibling-index">
			<xsl:call-template name="next-sibling-index">
				<xsl:with-param name="elements" select="$elements" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="children" select="$elements[position() > 1 and ($next-sibling-index = 0 or position() &lt; $next-sibling-index)]" />
		<xsl:for-each select="$first">
			<xsl:copy>
				<xsl:apply-templates select="@*" />
				<xsl:apply-templates />
				<xsl:apply-templates select="following-sibling::section[preceding-sibling::appropriations-major[1] = $first]" />
	 			<xsl:call-template name="appropriations">
					<xsl:with-param name="elements" select="$children" />
				</xsl:call-template>
			</xsl:copy>
		</xsl:for-each>
		<xsl:if test="$next-sibling-index > 0">
			<xsl:call-template name="appropriations">
				<xsl:with-param name="elements" select="$elements[position() >= $next-sibling-index]" />
			</xsl:call-template>
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template match="section">
	<xsl:copy>
		<xsl:apply-templates select="@*" />
		<xsl:apply-templates select="*[not(self::appropriations-small)]" />
	</xsl:copy>
	<xsl:apply-templates select="appropriations-small" />
</xsl:template>

<xsl:template match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates select="@*" />
		<xsl:apply-templates />
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
