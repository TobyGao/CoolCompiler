/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

%}

/*
 * Define names for regular expressions here.
 */
DIGIT          [0-9]
LETTER         [a-zA-Z_]
LOWERCASE      [a-z]
UPPERCASE      [A-Z]
INTEGER        {DIGIT}+

A              [aA]
B              [bB]
C              [cC]
D              [dD]
E              [eE]
F              [fF]
G              [gG]
H              [hH]
I              [iI]
J              [jJ]
K              [kK]
L              [lL]
M              [mM]
N              [nN]
O              [oO]
P              [pP]
Q              [qQ]
R              [rR]
S              [sS]
T              [tT]
U              [uU]
V              [vV]
W              [wW]
X              [xX]
Y              [yY]
Z              [zZ]
DARROW         =>
ASSIGN         <-

CLASS          {C}{L}{A}{S}{S}
NEW            {N}{E}{W}
INHERITS       {I}{N}{H}{E}{R}{I}{T}{S}
SELF_TYPE      {S}{E}{L}{F}_{T}{Y}{P}{E}
OBJECT_ID      {LOWERCASE}{LETTER}*
TYPE_ID        {UPPERCASE}{LETTER}*
VOID           {V}{O}{I}{D}
OBJECT         {O}{B}{J}{E}{C}{T}
INT            {I}{N}{T}
BOOL           {B}{O}{O}{L}
STRING         {S}{T}{R}{I}{N}{G}
IF             {I}{F}
THEN           {T}{H}{E}{N}
ELSE           {E}{L}{S}{E}
FI             {F}{I}
WHILE          {W}{H}{I}{L}{E}
LOOP           {L}{O}{O}{P}
POOL           {P}{O}{O}{L}
LET            {L}{E}{T}
CASE           {C}{A}{S}{E}
OF             {O}{F}
ESAC           {E}{S}{A}{C}
ISVOID         {I}{S}{V}{O}{I}{D}
IN             {I}{N}

TRUE           t{R}{U}{E}
FALSE          f{A}{L}{S}{E}

%%

 /*
  *  Nested comments
  */




 /*
  *  The multiple-character operators.
  */
{CLASS}         { return (CLASS); }
{ELSE}          { return (ELSE);  }
{FI}            { return (FI); }
{IF}            { return (IF); }
{IN}            { return (IN); }
{INHERITS}      { return (INHERITS); }
{LET}           { return (LET); }
{LOOP}          { return (LOOP); }
{POOL}          { return (POOL); }
{THEN}          { return (THEN); }
{WHILE}         { return (WHILE); }
{CASE}          { return (CASE); }
{ESAC}          { return (ESAC); }
{OF}            { return (OF); }
{NEW}           { return (NEW); }
{ISVOID}        { return (ISVOID); }
{ASSIGN}        { return (ASSIGN);}
{DARROW}        { return (DARROW); }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */


%%
