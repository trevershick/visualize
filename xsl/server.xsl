<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:beans="http://www.springframework.org/schema/beans"
	xmlns:batch="http://www.springframework.org/schema/batch">

	<xsl:output encoding="UTF-8" indent="yes" method="text" />

	<xsl:template match="/beans:beans">
		<xsl:apply-templates select="batch:*"/>
	</xsl:template>

<xsl:template match="/Server">
digraph {
rankdir=LR;
    server [shape=box3d,label="Server",style=filled,fillcolor=indianred1]
    {rank=top;server}

<xsl:apply-templates select="GlobalNamingResources"/>
<xsl:apply-templates select="//Context"/>
}
</xsl:template>
	
<xsl:template match="GlobalNamingResources">

    resources [shape=tab,label="Global Resources",style=filled,fillcolor=azure];
    server -> resources;
    datasources [shape=tab,style=filled,fillcolor=azure];
    environment [shape=tab,style=filled,fillcolor=azure];
    resources -> environment;
    resources -> datasources
    <xsl:apply-templates select="Resource"/>
    <xsl:apply-templates select="Environment"/>
</xsl:template>

<xsl:template match="Environment">
    <xsl:variable name="nodeName" select="concat('env_', position())"/>
    <xsl:value-of select="$nodeName"/> [style=filled,fillcolor=mediumpurple1,shape=note,label="&lt;&lt;Environment&gt;&gt;\n<xsl:value-of select="@name"/>\n<xsl:value-of select="@type"/>\n<xsl:value-of select="@value"/>"]
	environment -> <xsl:value-of select="$nodeName"/>;
</xsl:template>

<xsl:template match="Context">
    <xsl:variable name="nodeName" select="concat('ctx_', position())"/>
    <xsl:value-of select="$nodeName"/> [style=filled,fillcolor=khaki1,shape=folder,label="&lt;&lt;Context&gt;&gt;\n<xsl:value-of select="@path"/>"]
	server -> <xsl:value-of select="$nodeName"/>;    
</xsl:template>

<xsl:template match="Resource[@type='javax.sql.DataSource']">
    <xsl:variable name="nodeName" select="concat('ds_', position())"/>
    <xsl:value-of select="$nodeName"/> [style=filled,fillcolor=darkolivegreen1,shape=component,label="&lt;&lt;DataSource&gt;&gt;\n<xsl:value-of select="@name"/>\n<xsl:value-of select="@driverClassName"/>\n<xsl:value-of select="@url"/>"]
	datasources -> <xsl:value-of select="$nodeName"/>;    
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
