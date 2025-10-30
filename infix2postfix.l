cat > infix2post.l <<'EOF'
%option noyywrap

%{
  #include "infix2post.tab.h"
  #include <stdlib.h>
  #include <string.h>
%}

%%
[ \t\r]+            ;                /* skip whitespace */
\n                  { return '\n'; }
[0-9]+              { yylval.str = strdup(yytext); return NUMBER; }
[A-Za-z_][A-Za-z0-9_]*  { yylval.str = strdup(yytext); return ID; }
[()+\-*/^]          { return yytext[0]; }
.                   { /* ignore anything else */ }
%%
EOF
