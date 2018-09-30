%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <conio.h>
	#include <string.h>
	#include "y.tab.h"

	/* Tipos de datos para la tabla de simbolos */
  	#define Int 1
	#define Float 2
	#define String 3
	#define CteInt 4
	#define CteFloat 5
	#define CteString 6

	#define TAMANIO_TABLA 300
	#define TAM_NOMBRE 32

	/* Funciones necesarias */
	int yyerror(char* mensaje);
	void agregarVarATabla(char* nombre);
	void agregarTiposDatosATabla(void);
	void agregarCteStringATabla(char* nombre);
	void agregarCteIntATabla(int valor);
	void agregarCteFloatATabla(float valor);
	int chequearVarEnTabla(char* nombre);
	int buscarEnTabla(char * name);
	void escribirNombreEnTabla(char* nombre, int pos);
	void guardarTabla(void);

	int yystopparser=0;
	FILE  *yyin;

	/* Cosas de tabla de simbolos */
	typedef struct {
		char nombre[TAM_NOMBRE];
		int tipo_dato;
		char valor_s[TAM_NOMBRE];
		float valor_f;
		int valor_i;
		int longitud;
	} simbolo;

	simbolo tabla_simbolo[TAMANIO_TABLA];
	int fin_tabla = -1;

	/* Cosas para la declaracion de variables y la tabla de simbolos */
	int varADeclarar1 = 0;
	int cantVarsADeclarar = 0;
	int tipoDatoADeclarar;
%}

%union {
	int int_val;
	float float_val;
	char *string_val;
}

%token START
%token END

%token DECVAR ENDDEC
%token INT FLOAT STRING

%token WHILE ENDWHILE
%token IF THEN ELSE ENDIF

%token AND OR NOT

%token ASIG
%token MAS MENOS
%token POR DIVIDIDO

%token MENOR  MAYOR MENOR_IGUAL MAYOR_IGUAL
%token IGUAL DISTINTO

%token PA PC
%token CA CC
%token COMA
%token PUNTO_COMA

%token READ
%token WRITE
%token AVG
%token INLIST

%token <string_val>ID
%token <float_val>CTE_FLOAT
%token <int_val>CTE_INT
%token <string_val>CTE_STRING

%%

programa:
	START seccion_declaracion bloque END 	            {
															printf("\nCOMPILACION EXITOSA\n");
															guardarTabla();
														};

 /* Declaracion de variables */

seccion_declaracion:
	DECVAR bloque_dec ENDDEC 				            {printf("Regla 1: Seccion declaracion es DECVAR bloque_dec ENDEC\n\n");};

bloque_dec:
	bloque_dec declaracion					            {printf("Regla 2: bloque_dec es bloque_dec declaracion\n");}
	| declaracion							            {printf("Regla 3: bloque_dec es declaracion\n");};

declaracion:
	t_dato lista_id PUNTO_COMA				            {
															printf("Regla 4: declaracion es t_dato lista_id PUNTO_COMA\n");
															 agregarTiposDatosATabla();
														};

t_dato:
	FLOAT		                                        {
															printf("Regla 5: t_dato es FLOAT\n");
															tipoDatoADeclarar = Float;
														}
	| INT		                                        {
															printf("Regla 6: t_dato es INT\n");
															tipoDatoADeclarar = Int;
														}
	| STRING	                                        {
															printf("Regla 7: t_dato es STRING\n");
															tipoDatoADeclarar = String;
														};

lista_id:
	lista_id COMA ID	                                {
	                                                        printf("Regla 8: lista_id es lista_id COMA ID\n");
	                                                        agregarVarATabla(yylval.string_val);
															cantVarsADeclarar++;
                                                        }
	| ID				                                {
	                                                        printf("Regla 9: lista_id es ID\n");
	                                                        agregarVarATabla(yylval.string_val);
															varADeclarar1 = fin_tabla; /* Guardo posicion de primer variable de esta lista de declaracion. */
															cantVarsADeclarar = 1;
                                                        };

 /* Fin de Declaracion de variables */

 /* Seccion de codigo */

bloque:                                                 /* No existen bloques sin sentencias */
	bloque sentencia	                                {printf("Regla 10: bloque es bloque sentencia\n");}
	| sentencia			                                {printf("Regla 11: bloque es sentencia\n");};

sentencia:
	asignacion PUNTO_COMA			                    {printf("Regla 12: sentencia es asignacion PUNTO_COMA\n");}
	| bloque_if                                         {printf("Regla 13: sentencia es bloque_if\n");}
	| bloque_while                                      {printf("Regla 14: sentencia es bloque_while\n");}
	| lectura PUNTO_COMA                                {printf("Regla 15: sentencia es lectura PUNTO_COMA\n");}
	| escritura PUNTO_COMA                              {printf("Regla 16: sentencia es escritura PUNTO_COMA\n");}
	| expresion PUNTO_COMA                   			{printf("Regla 17: sentencia es expresion PUNTO_COMA\n");};

bloque_if:
    IF expresion_logica THEN bloque ENDIF               {printf("Regla 18: bloque_if es IF expresion_logica THEN bloque ENDIF\n\n");};

bloque_if:
    IF expresion_logica THEN bloque ELSE bloque ENDIF   {printf("Regla 19: bloque_if es IF expresion_logica THEN bloque ELSE bloque ENDIF\n\n");};

bloque_while:
    WHILE expresion_logica bloque ENDWHILE              {printf("Regla 20: bloque_while es WHILE expresion_logica bloque ENDWHILE\n\n");};

asignacion:
	ID ASIG expresion	                                {
															chequearVarEnTabla($1);
															//TODO chequear tipo de dato
															printf("Regla 21: asignacion es ID ASIG expresion\n\n");
														};

/* Expresiones aritmeticas y otras */

expresion:
	expresion_cadena				                    {printf("Regla 22: expresion es expresion_cadena\n");}
	| expresion_entera			                   		{printf("Regla 23.1: expresion es expresion_entera\n");}
	| expresion_real			                    	{printf("Regla 23.2: expresion es expresion_real\n");};

expresion_cadena:
	CTE_STRING						                    {
															printf("Regla 24: expresion_cadena es CTE_STRING\n");
															agregarCteStringATabla(yylval.string_val);
														};

/* Expresiones con numeros enteros */
expresion_entera:
	expresion_entera MAS termino_e 		            	{printf("Regla 25.1: expresion_entera es expresion_entera MAS termino_e\n");}
	| expresion_entera MENOS termino_e 	            	{printf("Regla 26.1: expresion_entera es expresion_entera MENOS termino_e\n");}
	| termino_e								            {printf("Regla 27.1: expresion_entera es termino_e\n");};

termino_e:
	termino_e POR factor_e 			                    {printf("Regla 28.1: termino_e es termino_e POR factor_e\n");}
	| termino_e DIVIDIDO factor_e 	                    {printf("Regla 29.1: termino_e es termino_e DIVIDIDO factor_e\n");}
	| factor_e					                        {printf("Regla 30.1: termino_e es factor_e\n");};

factor_e:
	PA expresion_entera PC	                        	{printf("Regla 31.1: factor_e es PA expresion_entera PC\n");};

factor_e:
	ID			                                        {
															chequearVarEnTabla(yylval.string_val);
															//TODO chequear tipo entero
															printf("Regla 33.1: factor_e es ID\n");
														}
	| CTE_INT	                                        {
															printf("Regla 35: factor_e es CTE_INT\n");
															agregarCteIntATabla(yylval.int_val);
														};

/* Expresiones con numeros reales */
expresion_real:
	expresion_real MAS termino_r 		            	{printf("Regla 25.2: expresion_real es expresion_real MAS termino_r\n");}
	| expresion_real MENOS termino_r 	            	{printf("Regla 26.2: expresion_real es expresion_real MENOS termino_r\n");}
	| termino_r								            {printf("Regla 27.2: expresion_real es termino_r\n");};

termino_r:
	termino_r POR factor_r 			                    {printf("Regla 28.2: termino_r es termino_r POR factor_r\n");}
	| termino_r DIVIDIDO factor_r 	                    {printf("Regla 29.2: termino_r es termino_r DIVIDIDO factor_r\n");}
	| factor_r					                        {printf("Regla 30.2: termino_r es factor_r\n");};

factor_r:
	PA expresion_real PC	                        	{printf("Regla 31.2: factor_r es PA expresion_real PC\n");}
    | average                                           {printf("Regla 32: factor_r es average\n");};

factor_r:
	ID			                                        {
															chequearVarEnTabla(yylval.string_val);
															//TODO chequear tipo dato
															printf("Regla 33: factor_r es ID\n");
														}
	| CTE_FLOAT	                                        {
															printf("Regla 34: factor_r es CTE_FLOAT\n");
															agregarCteFloatATabla(yylval.float_val);
														};

/* Expresiones logicas */

expresion_logica:
    termino_logico AND termino_logico                   {printf("Regla 36: expresion_logica es termino_logico AND termino_logico\n");}
    | termino_logico OR termino_logico                  {printf("Regla 37: expresion_logica es termino_logico OR termino_logico\n");}
    | termino_logico                                    {printf("Regla 38: expresion_logica es termino_logico\n");}
    | NOT termino_logico                                {printf("Regla 39: expresion_logica es NOT termino_logico\n");};

termino_logico:
    expresion_entera comp_bool expresion_entera 		{printf("Regla 40.1: termino_logico es expresion_entera comp_bool expresion_entera\n");}
	| expresion_real comp_bool expresion_real 			{printf("Regla 40.2: termino_logico es expresion_real comp_bool expresion_real\n");}
    | inlist                                            {printf("Regla 41: termino_logico es inlist\n");};

/* TODO creo que tenemos que retornar un valor para reconocer que comparador fue en el termino logico. */
comp_bool:
    MENOR                                               {printf("Regla 42: comp_bool es MENOR\n");}
    |MAYOR                                              {printf("Regla 43: comp_bool es MAYOR\n");}
    |MENOR_IGUAL                                        {printf("Regla 44: comp_bool es MENOR_IGUAL\n");}
    |MAYOR_IGUAL                                        {printf("Regla 45: comp_bool es MAYOR_IGUAL\n");}
    |IGUAL                                              {printf("Regla 46: comp_bool es IGUAL\n");}
    |DISTINTO                                           {printf("Regla 47: comp_bool es DISTINTO\n");};

/* Funciones nativas */

average:
    AVG PA CA lista_exp_e_coma CC PC                      {printf("Regla 48.1: average es AVG PA CA lista_exp_e_coma CC PC\n\n");}
	| AVG PA CA lista_exp_r_coma CC PC                    {printf("Regla 48.2: average es AVG PA CA lista_exp_r_coma CC PC\n\n");};

inlist:
	INLIST PA ID PUNTO_COMA CA lista_exp_e_pc CC PC   	{
															chequearVarEnTabla($3);
															//TODO chequear tipo de dato entero
															printf("Regla 49.1: inlist es INLIST PA ID PUNTO_COMA CA lista_exp_e_pc CC PC\n\n");
														}
	INLIST PA ID PUNTO_COMA CA lista_exp_r_pc CC PC   	{
															chequearVarEnTabla($3);
															//TODO chequear tipo de dato real
															printf("Regla 49.2: inlist es INLIST PA ID PUNTO_COMA CA lista_exp_r_pc CC PC\n\n");
														};

/* Listas con coma para average */
lista_exp_e_coma:
    lista_exp_e_coma COMA expresion_entera            	{printf("Regla 50.1: lista_exp_e_coma es lista_exp_e_coma COMA expresion_entera\n");}
    | expresion_entera                              	{printf("Regla 51.1: lista_exp_e_coma es expresion_entera\n");};

lista_exp_r_coma:
    lista_exp_r_coma COMA expresion_real            	{printf("Regla 50.2: lista_exp_r_coma es lista_exp_r_coma COMA expresion_real\n");}
    | expresion_real                              		{printf("Regla 51.2: lista_exp_r_coma es expresion_real\n");};

/* Listas con punto y coma para inlist */
lista_exp_e_pc:
    lista_exp_e_pc PUNTO_COMA expresion_entera        	{printf("Regla 52.1: lista_exp_e_pc es lista_exp_e_pc PUNTO_COMA expresion_entera\n");}
    | expresion_entera                              	{printf("Regla 53.1: lista_exp_e_pc es expresion_entera\n");};

lista_exp_r_pc:
    lista_exp_r_pc PUNTO_COMA expresion_real        	{printf("Regla 52.2: lista_exp_r_pc es lista_exp_r_pc PUNTO_COMA expresion_real\n");}
    | expresion_real                              		{printf("Regla 53.2: lista_exp_r_pc es expresion_real\n");};

lectura:
    READ ID												{
															chequearVarEnTabla($2);
															//TODO chequear tipo de dato
															printf("Regla 54: lectura es READ ID\n");
														};

escritura:
    WRITE ID                                            {
															chequearVarEnTabla($2);
															//TODO saber que tipo de dato es
															printf("Regla 55: escritura es WRITE ID\n");
														}
    | WRITE CTE_STRING                                  {
															printf("Regla 56: escritura es WRITE CTE_STRING\n\n");
															agregarCteStringATabla(yylval.string_val);
														};
%%

int main(int argc,char *argv[])
{
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
	printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else
  {
	yyparse();
  	fclose(yyin);
  }
  return 0;
}


int yyerror(char* mensaje)
 {
	printf("Syntax Error: %s\n", mensaje);
	system ("Pause");
	exit (1);
 }

/* Funciones de la tabla de simbolos */

/* Devuleve la posici�n en la que se encuentra el elemento buscado, -1 si no encontr� el elemento */
int buscarEnTabla(char * name){
   int i=0;
   while(i<=fin_tabla){
	   if(strcmp(tabla_simbolo[i].nombre,name) == 0){
		   return i;
	   }
	   i++;
   }
   return -1;
}

/** Escribe el nombre de una variable o constante en la posición indicada */
void escribirNombreEnTabla(char* nombre, int pos){
	strcpy(tabla_simbolo[pos].nombre, nombre);
}

 /** Agrega un nuevo nombre de variable a la tabla **/
 void agregarVarATabla(char* nombre){
	 //Si se llena, error
	 if(fin_tabla >= TAMANIO_TABLA - 1){
		 printf("Error: me quede sin espacio en la tabla de simbolos. Sori, gordi.\n");
		 system("Pause");
		 exit(2);
	 }
	 //Si no hay otra variable con el mismo nombre...
	 if(buscarEnTabla(nombre) == -1){
		 //Agregar a tabla
		 fin_tabla++;
		 escribirNombreEnTabla(nombre, fin_tabla);
	 }
	 else yyerror("Encontre dos declaraciones de variables con el mismo nombre. Decidite."); //Error, ya existe esa variable

 }

/** Agrega los tipos de datos a las variables declaradas. Usa las variables globales varADeclarar1, cantVarsADeclarar y tipoDatoADeclarar */
void agregarTiposDatosATabla(){
	for(int i = 0; i < cantVarsADeclarar; i++){
		tabla_simbolo[varADeclarar1 + i].tipo_dato = tipoDatoADeclarar;
	}
}

/** Guarda la tabla de simbolos en un archivo de texto */
void guardarTabla(){
	if(fin_tabla == -1)
		yyerror("No encontre la tabla de simbolos");

	FILE* arch = fopen("ts.txt", "w+");
	if(!arch){
		printf("No pude crear el archivo ts.txt\n");
		return;
	}

	for(int i = 0; i <= fin_tabla; i++){
		fprintf(arch, "%s\t", &(tabla_simbolo[i].nombre) );

		switch (tabla_simbolo[i].tipo_dato){
		case Float:
			fprintf(arch, "FLOAT");
			break;
		case Int:
			fprintf(arch, "INT");
			break;
		case String:
			fprintf(arch, "STRING");
			break;
		case CteFloat:
			fprintf(arch, "CTE_FLOAT\t%f", tabla_simbolo[i].valor_f);
			break;
		case CteInt:
			fprintf(arch, "CTE_INT\t%d", tabla_simbolo[i].valor_i);
			break;
		case CteString:
			fprintf(arch, "CTE_STRING\t%s\t%d", &(tabla_simbolo[i].valor_s), tabla_simbolo[i].longitud);
			break;
		}

		fprintf(arch, "\n");
	}
	fclose(arch);
}

/* Calculo que estas 3 funciones se podrían juntar en una sola */

/** Agrega una constante string a la tabla de simbolos */
void agregarCteStringATabla(char* nombre){
	if(fin_tabla >= TAMANIO_TABLA - 1){
		printf("Error: me quede sin espacio en la tabla de simbolos. Sori, gordi.\n");
		system("Pause");
		exit(2);
	}

	//Si no hay otra variable con el mismo nombre...
	if(buscarEnTabla(nombre) == -1){
		//Agregar nombre a tabla
		fin_tabla++;
		escribirNombreEnTabla(nombre, fin_tabla);

		//Agregar tipo de dato
		tabla_simbolo[fin_tabla].tipo_dato = CteString;

		//Agregar valor a la tabla
		strcpy(tabla_simbolo[fin_tabla].valor_s, nombre+1); //nombre+1 es para no copiar el _ del principio

		//Agregar longitud
		tabla_simbolo[fin_tabla].longitud = strlen(nombre) - 1;
	}
}

/** Agrega una constante real a la tabla de simbolos */
void agregarCteFloatATabla(float valor){
	if(fin_tabla >= TAMANIO_TABLA - 1){
		printf("Error: me quede sin espacio en la tabla de simbolos. Sori, gordi.\n");
		system("Pause");
		exit(2);
	}

	//Genero el nombre
	char nombre[12];
	sprintf(nombre, "_%f", valor);

	//Si no hay otra variable con el mismo nombre...
	if(buscarEnTabla(nombre) == -1){
		//Agregar nombre a tabla
		fin_tabla++;
		escribirNombreEnTabla(nombre, fin_tabla);

		//Agregar tipo de dato
		tabla_simbolo[fin_tabla].tipo_dato = CteFloat;

		//Agregar valor a la tabla
		tabla_simbolo[fin_tabla].valor_f = valor;
	}
}

/** Agrega una constante entera a la tabla de simbolos */
void agregarCteIntATabla(int valor){
	if(fin_tabla >= TAMANIO_TABLA - 1){
		printf("Error: me quede sin espacio en la tabla de simbolos. Sori, gordi.\n");
		system("Pause");
		exit(2);
	}

	//Genero el nombre
	char nombre[30];
	sprintf(nombre, "_%d", valor);

	//Si no hay otra variable con el mismo nombre...
	if(buscarEnTabla(nombre) == -1){
		//Agregar nombre a tabla
		fin_tabla++;
		escribirNombreEnTabla(nombre, fin_tabla);

		//Agregar tipo de dato
		tabla_simbolo[fin_tabla].tipo_dato = CteInt;

		//Agregar valor a la tabla
		tabla_simbolo[fin_tabla].valor_i = valor;
	}
}

/** Se fija si ya existe una entrada con ese nombre en la tabla de simbolos.
Si no existe, muestra un error de variable sin declarar y aborta la compilacion.
Si existe, devuelve el tipo de dato */
int chequearVarEnTabla(char* nombre){
	//Si no existe en la tabla, error
	int pos;
	if(pos = buscarEnTabla(nombre) == -1){
		char msg[100];
		sprintf(msg,"%s? No, man, tenes que declarar las variables arriba. Esto no es un viva la pepa como java...", nombre);
		yyerror(msg);
	}
	//Si existe en la tabla, dejo que la compilacion siga
	return tabla_simbolo[pos].tipo_dato;
}
