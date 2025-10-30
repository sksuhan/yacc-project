cat > infix2post.y <<'EOF'
%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  int yylex(void);
  void yyerror(const char *s){ fprintf(stderr, "Error: %s\n", s); }

  static char* sdup(const char* s){
    size_t n = strlen(s);
    char* r = (char*)malloc(n+1);
    memcpy(r, s, n+1);
    return r;
  }

  static char* cat3(const char* a, const char* b, const char* op){
    size_t na=strlen(a), nb=strlen(b), no=strlen(op);
    char* r = (char*)malloc(na + 1 + nb + 1 + no + 1);   /* "a b op" */
    memcpy(r, a, na); r[na]=' ';
    memcpy(r+na+1, b, nb); r[na+1+nb]=' ';
    memcpy(r+na+1+nb+1, op, no);
    r[na+1+nb+1+no] = '\0';
    return r;
  }
%}

%union { char* str; }

%token <str> ID NUMBER
%type  <str> expr term power factor line

/* Operator precedence (lowest → highest) */
%left '+' '-'
%left '*' '/'
%right '^'

%%
input:
    /* empty */
  | input line
  ;

line:
    expr '\n'     { printf("%s\n", $1); free($1); }
  | '\n'
  ;

expr:
    expr '+' term { $$ = cat3($1,$3,"+"); free($1); free($3); }
  | expr '-' term { $$ = cat3($1,$3,"-"); free($1); free($3); }
  | term
  ;

term:
    term '*' power { $$ = cat3($1,$3,"*"); free($1); free($3); }
  | term '/' power { $$ = cat3($1,$3,"/"); free($1); free($3); }
  | power
  ;

/* Right-associative power */
power:
    factor '^' power { $$ = cat3($1,$3,"^"); free($1); free($3); }
  | factor
  ;

factor:
    '(' expr ')'   { $$ = $2; }
  | ID             { $$ = sdup($1); free($1); }
  | NUMBER         { $$ = sdup($1); free($1); }
  ;
%%
int main(void){ return yyparse(); }
EOF
