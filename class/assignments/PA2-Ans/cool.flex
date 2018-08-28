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

int comment_nesting;

void append_string(char * yytext, int yyleng);
void set_error_message(char * msg);

%}

%x string comment found_null

/*
 * Define names for regular expressions here.
 */

CAPITAL_LETTER  [A-Z]
MINUSCLE_LETTER [a-z]
LETTER          ({CAPITAL_LETTER}|{MINUSCLE_LETTER})
DIGIT           [0-9]
A               [aA]
B               [bB]
C               [cC]
D               [dD]
E               [eE]
F               [fF]
G               [gG]
H               [hH]
I               [iI]
J               [jJ]
k               [kK]
L               [lL]
M               [mM]
N               [nN]
O               [oO]
P               [pP]
Q               [qQ]
R               [rR]
S               [sS]
T               [tT]
U               [uU]
W               [wW]
V               [vV]
X               [xX]
Y               [yY]
Z               [zZ]

DARROW          =>
ASSIGN          <-
LE              <=

INTERGER {DIGIT}+
TYPE     ({CAPITAL_LETTER}({LETTER}|{DIGIT}|_)*|SELF_TYPE)
ID       {MINUSCLE_LETTER}({LETTER}|{DIGIT}|_)*

CLASS    {C}{L}{A}{S}{S}
ELSE     {E}{L}{S}{E}
IF       {I}{F}
FI       {F}{I}
IN       {I}{N}
INHERITS {I}{N}{H}{E}{R}{I}{T}{S}
ISVOID   {I}{S}{V}{O}{I}{D}
LET      {L}{E}{T}
LOOP     {L}{O}{O}{P}
POOL     {P}{O}{O}{L}
THEN     {T}{H}{E}{N}
WHILE    {W}{H}{I}{L}{E}
CASE     {C}{A}{S}{E}
ESAC     {E}{S}{A}{C}
NEW      {N}{E}{W}
OF       {O}{F}
NOT      {N}{O}{T}

TRUE     t{R}{U}{E}
FALSE    f{A}{L}{S}{E}

%%

"--".*      ;

 /*
  *  Nested comments
  */

<comment>{
  <<EOF>>   {
              set_error_message("EOF in comment");
              BEGIN 0;
              return (ERROR);
            }
  "(*"      comment_nesting++;
  "*"+")"   {
              if (comment_nesting)
                --comment_nesting;
              else
                BEGIN INITIAL;
            }

  [^(*\n]+   /* consume non "*" or "(" */
  "*"*[^)\n] /* many "(" not followed by "*" */
  "("*[^*\n] /* many "*" not followed by ")" */
}

"*)"      {
            set_error_message("Unmatched *)");
            return (ERROR);
          }
"(*"      { BEGIN comment; }

 /*
  *  The multiple-character operators.
  */

{DARROW}  { return (DARROW); }
{ASSIGN}  { return (ASSIGN); }
{LE}      { return (LE); }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

{CLASS}     { return (CLASS); }
{ELSE}      { return (ELSE); }
{IF}        { return (IF); }
{FI}        { return (FI); }
{IN}        { return (IN); }
{INHERITS}  { return (INHERITS); }
{ISVOID}    { return (ISVOID); }
{LET}       { return (LET); }
{LOOP}      { return (LOOP); }
{POOL}      { return (POOL); }
{THEN}      { return (THEN); }
{WHILE}     { return (WHILE); }
{CASE}      { return (CASE); }
{ESAC}      { return (ESAC); }
{NEW}       { return (NEW); }
{OF}        { return (OF); }
{NOT}       { return (NOT); }
{TRUE}      {
              cool_yylval.boolean = 1;
              return BOOL_CONST;
            }
{FALSE}     {
              cool_yylval.boolean = 0;
              return BOOL_CONST;
            }

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

<string>{
  <<EOF>> {
            set_error_message("EOF in string constant");
            BEGIN 0;
            return (ERROR);
          }
  \"  {
        BEGIN INITIAL;

        if (strlen(string_buf) == MAX_STR_CONST) {
          set_error_message("String constant too long");
          BEGIN 0;
          return (ERROR);
        } else {
          cool_yylval.symbol = stringtable.add_string(string_buf);
          return (STR_CONST);
        }
      }

  \n  {
        curr_lineno++;
        set_error_message("Unterminated string constant");
        BEGIN 0;
        return (ERROR);
      }

  \0    {
          set_error_message("String contains null character.");
          BEGIN found_null;
          return (ERROR);
        }
  \\\0  {
          set_error_message("String contains escaped null character.");
          BEGIN found_null;
          return (ERROR);
        }
  \\\"  append_string("\"", 2);
  \\n   append_string("\n", 2);
  \\t   append_string("\t", 2);
  \\b   append_string("\b", 2);
  \\f   append_string("\f", 2);
  \\\n  {curr_lineno++; append_string(&yytext[1], 2); }
  \\.   append_string(&yytext[1], 2);

  [^\\\n"\0]+ {
                append_string(yytext, yyleng);
              }
}
\"  {
      string_buf[0] = '\0';
      string_buf_ptr = string_buf;
      BEGIN string;
    }
<found_null>{
  \"          { BEGIN INITIAL; }
  .*[^\\]$    { BEGIN INITIAL; }
  [^\\\n"]+   ;
  \\\"        ;
}

{INTERGER}  {
              cool_yylval.symbol = inttable.add_string(yytext);
              return (INT_CONST);
            }
{ID}        {
              cool_yylval.symbol = idtable.add_string(yytext);
              return (OBJECTID);
            }
{TYPE}      {
              cool_yylval.symbol = idtable.add_string(yytext);
              return (TYPEID);
            }

":" |
"@" |
";" |
"(" |
")" |
"{" |
"," |
"." |
"+" |
"-" |
"*" |
"/" |
"<" |
"=" |
"~" |
"}"         {
              printf("#%i '%s'\n", curr_lineno, yytext);
            }
<*>\n curr_lineno++;
[ \f\r\t\t\013]     ;
.                   {
                      set_error_message(yytext);
                      return (ERROR);
                    }

%%
void append_string(char * yytext, int yyleng) {
  int len = strlen(string_buf);
  strncat(string_buf, yytext, MAX_STR_CONST - len);
}

void set_error_message(char * msg) {
  string_buf[0] = '\0';
  strcat(string_buf, msg);
  cool_yylval.error_msg = string_buf;
}
