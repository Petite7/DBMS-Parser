%{
/****************************************************************************
mylexer.l
ParserWizard generated Lex file.

Date: 2018Äê6ÔÂ14ÈÕ
****************************************************************************/

#include "myparser.h"
#include<stdlib.h>
#include<stdio.h>
#include<string.h>
%}

/////////////////////////////////////////////////////////////////////////////
// declarations section
CREATE			  create|CREATE
USE				  use|USE
SHOW			  show|SHOW
INSERT			  insert|INSERT
SELECT			  select|SELECT
UPDATE			  update|UPDATE
SET				  set|SET
DELETE			  delete|DELETE
DROP			  drop|DROP
AND				  and|AND
WHERE			  where|WHERE
OR				  or|OR
FROM			  from|FROM
INTO		 	  into|INTO
VALUES			  values|VALUES
EXIT			  exit|EXIT
DATABASE		  database|DATABASE
DATABASES		  databases|DATABASES
TABLE			  table|TABLE
TABLES			  tables|TABLES
CHAR			  char|CHAR
INT				  int|INT
ID     	  		  [_A-Za-z][A-Za-z0-9_]*
digit			  [0-9]
digits			  {digit}+
optional_fraction	  ("."{digits})?
optional_exponent	  (E[+-]?{digits})?

// place any declarations here

%%

/////////////////////////////////////////////////////////////////////////////
// rules section
[ ]+ ;
{CREATE}	    {return CREATE;}
{USE}		    {return USE;}
{SHOW}	  	    {return SHOW;}
{INSERT}  	    {return INSERT;}
{SELECT}	    {return SELECT;}
{UPDATE}	    {return UPDATE;}
{SET}		    {return SET;}
{DELETE}   	    {return DELETE;}
{DROP}	  	    {return DROP;}
{INTO}		    {return INTO;}
{VALUES}	    {return VALUES;}
{FROM}		    {return FROM;}
{WHERE}		    {return WHERE;}
{AND}	    	{return AND;}
{OR}	    	{return OR;}
{EXIT}		    {return EXIT;}
{TABLE}		    {return TABLE;}
{TABLES}	    {return TABLES;}
{DATABASE}	    {return DATABASE;}
{DATABASES}     {return DATABASES;}
{CHAR}		    {return CHAR;}
{INT}		    {return INT;}
{ID} {
	yylval.yych=(char *)malloc(strlen(yytext)+1); 
	strcpy(yylval.yych, yytext);
	return ID;
}
{digits}{optional_fraction}{optional_exponent} {
	yylval.yych=(char *)malloc(strlen(yytext)+1); 
	strcpy(yylval.yych, yytext);
	return NUMBER;
}

//[+-*/;,.!<>] {return yylex[0];}
//warning : reversed charactor

";"		{return ';';}
"("		{return '(';}
")"		{return ')';}
","		{return ',';}
"."		{return '.';}
"!"		{return '!';}
"="		{return '=';}
"<"		{return '<';}
">"		{return '>';}
"'"		{return QUOTE;}
"+"		{return '+';}
"-"		{return '-';}
"*"		{return '*';}
"/"		{return '/';}
"\n"	{return 0;}
// place your Lex rules here

%%