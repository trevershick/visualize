<?xml version="1.0" encoding="UTF-8" ?>
<!--
	untitled
	Created by Trever Shick on 2012-03-16.
	Copyright (c) 2012 __MyCompanyName__. All rights reserved.
-->
<!--
TODO - put readers,writers, listeners,etc. in here
TODO - figure out how to put this in javadoc or maven site.

-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:beans="http://www.springframework.org/schema/beans"
	xmlns:batch="http://www.springframework.org/schema/batch">

	<xsl:output encoding="UTF-8" indent="yes" method="text" />

	<xsl:template match="/beans:beans">
		<xsl:apply-templates select="batch:*"/>
	</xsl:template>

	<xsl:template match="batch:job">
digraph {
	label="<xsl:value-of select="@id"/>";
<xsl:apply-templates select="batch:*"/>
}

COMPLETED [shape=box,style=filled,fillcolor="blue"];


}
</xsl:template>
	
	<xsl:template match="batch:decision">
		<xsl:variable name="stepId" value="@id"/>
		<xsl:value-of select="@id"/> [label="&lt;&lt;decision&gt;&gt;\n<xsl:value-of select="@id"/>",shape="box"];

		<xsl:call-template name="handle_fail"/>
		<xsl:call-template name="handle_next"/>
		<xsl:apply-templates select="batch:*"/>
	</xsl:template>
	
	
	
	<xsl:template match="batch:step">
		<xsl:variable name="stepId" value="@id"/>
		<xsl:value-of select="@id"/> [label="&lt;&lt;step&gt;&gt;\n<xsl:value-of select="@id"/>"shape="box"];

		<xsl:call-template name="handle_fail"/>
		<xsl:call-template name="handle_next"/>
		<xsl:apply-templates select="batch:*"/>
		
		<xsl:if test="not(following-sibling::*)">
			<xsl:value-of select="@id"/> -> COMPLETED;
		</xsl:if>
	</xsl:template>
	

	<xsl:template name="handle_next">
		<xsl:if test="@next">
			<xsl:value-of select="@id"/> -> <xsl:value-of select="@next"/>;
		</xsl:if>
	</xsl:template>
	<xsl:template name="handle_fail">
		<xsl:if test="@fail">
			<xsl:value-of select="@id"/> -> <xsl:value-of select="@fail"/> [color="red"];
		</xsl:if>
	</xsl:template>
	
	<!-- if the fail is just FAILED/FAILED then that's default behavior
	and let's not put that in jsut yet -->
	<xsl:template match="batch:fail[@on != 'FAILED' and @exit-code != 'FAILED']">
		<xsl:value-of select="../@id"/>
		<xsl:text> -> </xsl:text>
		<xsl:value-of select="@exit-code"/>
		<xsl:text> [color="red",label="</xsl:text>
		<xsl:value-of select="@on"/>
		<xsl:text>"];</xsl:text>
	</xsl:template>
	
	<xsl:template match="batch:next">
		<xsl:value-of select="../@id"/>
		<xsl:text> -> </xsl:text>
		<xsl:value-of select="@to"/>
		<xsl:text>[label="</xsl:text>
		<xsl:value-of select="@on"/>
		<xsl:text>"];</xsl:text>
	</xsl:template>
	
	<xsl:template match="batch:end">
		<xsl:value-of select="../@id"/>
		<xsl:text> -> COMPLETED</xsl:text>
		<xsl:text>[label="</xsl:text>
		<xsl:value-of select="@on"/>
		<xsl:text>"];</xsl:text>
	</xsl:template>
	<xsl:template match="batch:tasklet">
		<xsl:apply-templates select="batch:*"/>

	</xsl:template>

	<xsl:template match="batch:chunk">
		<xsl:apply-templates select="batch:*"/>
	</xsl:template>
	
	
</xsl:stylesheet>
