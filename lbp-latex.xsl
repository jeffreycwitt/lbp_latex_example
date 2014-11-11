<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">
    
    <xsl:param name="apploc"><xsl:value-of select="/TEI/teiHeader/encodingDesc/variantEncoding/@location"/></xsl:param>
    <xsl:param name="notesloc"><xsl:value-of select="/TEI/teiHeader/encodingDesc/variantEncoding/@location"/></xsl:param>
    <xsl:variable name="title"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title"/></xsl:variable>
    <xsl:variable name="author"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/author"/></xsl:variable>
    <xsl:variable name="editor"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/editor"/></xsl:variable>
    <xsl:variable name="versionnumber"><xsl:value-of select="/TEI/teiHeader/fileDesc/editionStmt/edition/@n"/></xsl:variable>
    <xsl:variable name="fs"><xsl:value-of select="/TEI/text/body/div/@xml:id"/></xsl:variable>
    
    <xsl:output method="text" indent="no"/>
    <!-- <xsl:strip-space elements="*"/> -->
    
    <xsl:template match="text()">
    <xsl:value-of select="replace(., '\s+', ' ')"/>    
    </xsl:template>
    
    <xsl:template match="/">
        \documentclass{article}
        
        \usepackage{eledmac}
        \usepackage{titlesec}
        \usepackage [english]{babel}
        \usepackage [autostyle, english = american]{csquotes}
        
        \usepackage{fancyhdr}
        
        \pagestyle{fancy}
        \rhead{<xsl:value-of select="$title"/>}
        \lhead{<xsl:value-of select="$versionnumber"/>}
       
        \MakeOuterQuote{"}
        
        \titleformat{\section} {\normalfont\scshape}{\thesection}{1em}{}
        \titlespacing\section{0pt}{12pt plus 4pt minus 2pt}{12pt plus 2pt minus 2pt}
        
        \newcommand{\name}[1]{\textsc{#1}}
        \newcommand{\worktitle}[1]{\textit{#1}}
        
        \linespread{1.1}
        
        \begin{document}
        \title{<xsl:value-of select="$title"></xsl:value-of>}
        \author{<xsl:value-of select="$author"></xsl:value-of>}
        <!--\editor{<xsl:value-of select="$editor"></xsl:value-of>}-->
        \maketitle
        <xsl:apply-templates select="//body"/>
        \end{document}
    </xsl:template>
    <xsl:template match="div//head">\section*{<xsl:apply-templates/>}</xsl:template>
    <xsl:template match="div//div">
        \bigskip
        <xsl:apply-templates/>
        
    </xsl:template>
    <xsl:template match="p">
        <xsl:variable name="pn"><xsl:number level="any" from="tei:text"/></xsl:variable>
        \pstart
        \ledrightnote{\textbf{<xsl:value-of select="$pn"/>}}
        <xsl:apply-templates/>
        \pend
    </xsl:template>
    <xsl:template match="head">
    </xsl:template>
    <xsl:template match="div">
        \beginnumbering
        <xsl:apply-templates/>
        \endnumbering
        
    </xsl:template>
    
    <xsl:template match="pb | cb"><xsl:variable name="MsI"><xsl:value-of select="translate(./@ed, '#', '')"/></xsl:variable>\ledrightnote{<xsl:value-of select="concat($MsI, ./@n)"/>}</xsl:template>
    <xsl:template match="supplied">[<xsl:apply-templates/>]</xsl:template>
    <xsl:template match="cit[bibl]">
        <xsl:text>\edtext{\enquote{</xsl:text>
        <xsl:apply-templates select="quote"/>
        <xsl:text>}}{</xsl:text>
        <xsl:if test="count(tokenize(normalize-space(./quote), ' ')) &gt; 10">
            <xsl:text>\lemma{</xsl:text>
            <xsl:value-of select="tokenize(normalize-space(./quote), ' ')[1]"/>
           <xsl:text> \dots\ </xsl:text>
            <xsl:value-of select="tokenize(normalize-space(./quote), ' ')[last()]"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:text>\Afootnote{</xsl:text>
        <xsl:apply-templates select="bibl"/>
        <xsl:text>}}</xsl:text>
    </xsl:template>
    <xsl:template match="ref[bibl]">
        <xsl:text>\edtext{</xsl:text>
        <xsl:apply-templates select="seg"/>
        <xsl:text>}{</xsl:text>
        <xsl:if test="count(tokenize(normalize-space(./seg), ' ')) &gt; 10">
            <xsl:text>\lemma{</xsl:text>
            <xsl:value-of select="tokenize(normalize-space(./seg), ' ')[1]"/>
            <xsl:text> \dots\ </xsl:text>
            <xsl:value-of select="tokenize(normalize-space(./seg), ' ')[last()]"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:text>\Afootnote{</xsl:text>
        <xsl:apply-templates select="bibl"/>
        <xsl:text>}}</xsl:text>
    </xsl:template>
    <xsl:template match="ref"><xsl:apply-templates/></xsl:template>
    <xsl:template match="app">
        <xsl:variable name="appnumber"><xsl:number level="any" from="tei:text"/></xsl:variable>
        <xsl:text>\edtext{</xsl:text>
        <xsl:apply-templates select="lem"/>
        <xsl:text>}{</xsl:text>
        <xsl:if test="count(tokenize(normalize-space(./lem), ' ')) &gt; 10">
            <xsl:text>\lemma{</xsl:text>
            <xsl:value-of select="tokenize(normalize-space(./lem), ' ')[1]"/>
            <xsl:text> \dots\ </xsl:text>
            <xsl:value-of select="tokenize(normalize-space(./lem), ' ')[last()]"/>
            <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:text>\Bfootnote{</xsl:text>
        <xsl:for-each select="./rdg"><xsl:call-template name="varianttype"/></xsl:for-each>
        <xsl:text>[W</xsl:text><xsl:value-of select="$appnumber"></xsl:value-of><xsl:text>]}}</xsl:text>
    </xsl:template>
    
    <xsl:template match="name">
        <xsl:text>\name{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="title">
        <xsl:text>\worktitle{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="mentioned">
        <xsl:text>\enquote*{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="quote"><xsl:apply-templates/></xsl:template>
    <xsl:template match="rdg"></xsl:template>
    <xsl:template match="app/note"></xsl:template>

<xsl:template name="varianttype">
      <xsl:choose>
            <xsl:when test="contains(@type, 'om.')">
                <xsl:text>\textit{om.} </xsl:text>
                <xsl:value-of select="translate(./@wit, '#', '')"/>
                <xsl:text> </xsl:text>
            </xsl:when>
            <xsl:when test="contains(@type, 'add.sed.del.') or ./@type='corrDeletion'"> <!-- eventually the "contains" options should be removed as "corrDeletion, corrAddition" becomes the standard in the app schema -->
                <xsl:value-of select="./corr/del"/>
                <xsl:text> \textit{add. sed del.} </xsl:text>
                <xsl:value-of select="translate(@wit, '#', '')"/>
                <xsl:text> </xsl:text>
            </xsl:when>
            <xsl:when test="contains(@type, 'addCorrection') or ./@type='corrAddition'">
                <xsl:value-of select="./corr/add"/>
                <xsl:text> \textit{add.} </xsl:text> 
                <xsl:choose>
                    <xsl:when test="./corr/add/@place='aboveLine'">
                        <xsl:text>\textit{interl.} </xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(./corr/add/@place, 'margin')">
                        <xsl:text>\textit{in marg.} </xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:value-of select="translate(@wit, '#', '')"/><xsl:text> </xsl:text>
            </xsl:when>
            <xsl:when test="contains(@type, 'rep.')">
                <xsl:text> \textit{rep.} </xsl:text>
                <xsl:value-of select="translate(@wit, '#', '')"/><xsl:text> </xsl:text>
            </xsl:when>
            <xsl:when test="contains(@type, 'intextu')">
                <xsl:text> </xsl:text>
                <xsl:value-of select="."/>
                <xsl:text> \textit{in textu} </xsl:text>
                <xsl:value-of select="translate(@wit, '#', '')"/>
                <xsl:text> </xsl:text>
            </xsl:when>
            
            <xsl:when test="contains(@type, 'corr.') or ./@type='corrReplace'">
                <xsl:text> </xsl:text><xsl:value-of select="./corr/add"/>
                <xsl:text> \textit{corr. ex} </xsl:text>
                <xsl:value-of select="./corr/del"/><xsl:text> </xsl:text>
                <xsl:value-of select="translate(@wit, '#', '')"/><xsl:text> </xsl:text>
            </xsl:when>    
            <xsl:otherwise>
                <xsl:text> </xsl:text><xsl:value-of select="."/><xsl:text> </xsl:text>
                <xsl:value-of select="translate(@wit, '#', '')"/><xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
</xsl:template>
</xsl:stylesheet>