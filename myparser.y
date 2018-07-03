%{
/****************************************************************************
myparser.y
ParserWizard generated YACC file.
Date: 2018Äê6ÔÂ14ÈÕ
****************************************************************************/
#include "mylexer.h"
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<direct.h>
#include<io.h>

#define bool int
#define true 1
#define false 0

char baseName[100]={0};
char dir[100]={0};
enum TYPE {INT,CHAR};

/***********CREATE ROOT AND NODE DEFINATION*************
*[typeCreate] -> [nextCreatefieldsdef1]
*			  -> [nextCreatefieldsdef2]
*			  -> ...
*[fieldType] -> CHAR(length)
-> INT
********************************************************/
struct Createfieldsdef{
	char		*field;
	enum TYPE	type;
	int			length;
	struct	Createfieldsdef	*next_fdef;
};
struct fieldType{
	enum TYPE	type;
	int		length;
};

struct Createstruct{
	char *table;
	struct	Createfieldsdef *fdef;
};

/****************INSERT LIST TYPE************************
*[TABLE_FIELD]
*	[value1] -> [value2] -> [value3] -> ...
*
*********************************************************/
struct insertValue {
    char *value;
    struct insertValue *next_Value;
};

/************SELECT ROOT AND NODE DEFINATION*************
*[SELECTEDFIELDS:_FIELD], ->NEXT_FIELD -> ...(SF)
*[SELECTEDTABLES:_TABLE], ->NEXT_TABLE -> ...(ST)
*[CONDITIONS]:(CONS)
*			LEFT   CMP    RIGHT
*			|				|
*	LEFT  CMP  RIGHT   LEFT  CMP  RIGHT
*	  |			 |		|			|
*   ...			...		...			...
*********************************************************/
struct Conditions{
	struct Conditions *left;
	struct Conditions *right;
	char comp_op;
	int type;
	char *value;
	char *table;
}; 

struct	Selectedfields{
	char 	*table;
	char 	*field;
	struct 	Selectedfields	*next_sf;
};

struct	Selectedtables{
	char	  *table;
	struct  Selectedtables  *next_st;
};

struct	Selectstruct{
	struct Selectedfields 	*sf;
	struct Selectedtables	*st;
	struct Conditions	*cons;
};

/***********UPDATE LIST DEFINATION***********************
*[FIELD, toValue]
*		->[nextFIELD, toValue]
*		->[nextFIELD, toValue]
*		...
*********************************************************/
struct Updatestruct{
    char *field;
    char *value;
    struct Updatestruct *next_sf;
};
char* removeEnter(char *s);
void createDataBase();
void showDataBase();
void useDataBase();
void dropDataBase();
void createTable(struct Createstruct *createList);
void showTable();
void dropTable(char *tableName);
void insertALL(char *tableName, struct insertValue *values);
void insertPart(char *tableName, struct insertValue *valueName, struct insertValue *values);
bool getCondition(struct Conditions *now, char fieldName[][100], char  fieldValue[][100]);
void freeCondition(struct Conditions *now);
void selectPart(struct Selectedfields *field, struct Selectedtables *table);
void selectPartCondition(struct Selectedfields *field, struct Selectedtables *table, struct Conditions *condition);
void updateCondition(char *tableName, struct Updatestruct *valueList, struct Conditions *condition);
void deleteCondition(char *tableName, struct Conditions *condition);

%}
//-----------------------------------------------------------------------
%union{
	char cop;
	char *yych;
	/******CREATE TYPE******/
	struct Createfieldsdef *cfdef_var;
	struct fieldType *field_typ;
	struct Createstruct *cs_var;

	/******SELECT TYPE******/
	struct Selectedfields	*sf_var;
	struct Selectedtables	*st_var;
	struct Conditions	*cons_var;
	struct Selectstruct	*ss_var;

	/******INSERT TYPE******/
	struct insertValue *is_val;
	
	/******UPDATE TYPE******/
	struct Updatestruct *u_var;
}

%term CREATE SELECT INSERT UPDATE DELETE DROP SHOW USE DATABASES DATABASE TABLE TABLES CHAR INT FROM WHERE OR AND QUOTE INTO VALUES SET EXIT
%term <yych> ID NUMBER
%nonterm <cop> comp_op
%nonterm <yych> table field
%nonterm <field_typ> type
%nonterm <cfdef_var> fieldsdefinition field_type
%nonterm <cs_var> createsql
%nonterm <is_val> values value
%nonterm <sf_var> fields_star  table_fields  table_field
%nonterm <st_var> tables
%nonterm <cons_var> condition  conditions comp_unit
%nonterm <ss_var> selectsql
%nonterm <u_var> set sets
%left AND
%left OR
%%
/*********************START STATEMENTS***********************************
*START_STATEMENTS
*	STATEMENT_CREATE_SELECT_INSERT_UPDATE_DELETE_DROP_USE_SHOW_EXIT
*
*************************************************************************/
start		:statements;
statements	:statements statement|statement;
statement	:createsql|selectsql|insertsql|deletesql|updatesql|dropsql|usesql|showsql|exitsql;

/*************************ON CREATE DEFINATION***************************
*CREATE TABLE Student( Sno CHAR(9), Sname CHAR(20), Ssex CHAR(2), Sage INT );
*	table -> ID
*	fieldsdefinition -> field_type | fieldsdefinition ',' field_type
*	field_type -> field type
*	field -> ID
*	type -> CHAR '(' NUMBER ')' | INT
*
*************************************************************************/
createsql:CREATE TABLE table '(' fieldsdefinition ')' ';'
	  {
		$$=(struct Createstruct *)malloc(sizeof(struct Createstruct));
		$$->table=$3;
		$$->fdef=$5;
		createTable($$);
	  }
	 |CREATE DATABASE ID ';'
	  {
		strcpy(baseName,$3);
		createDataBase();
	  };
	  table:ID
	  {
		$$=$1;
	  };
	  fieldsdefinition:field_type
	  {
		$$=(struct Createfieldsdef *)malloc(sizeof(struct Createfieldsdef));
		$$->field=$1->field;
		$$->type=$1->type;
		$$->length=$1->length;
		$$->next_fdef=NULL;
	  }
	 |field_type ',' fieldsdefinition
	  {
		$$=(struct Createfieldsdef *)malloc(sizeof(struct Createfieldsdef));
		$$->field=$1->field;
		$$->type=$1->type;
		$$->length=$1->length;
		$$->next_fdef=$3;
	  };
	  field_type:field type
	  {
		$$=(struct Createfieldsdef *)malloc(sizeof(struct Createfieldsdef));
		$$->field=$1;
		$$->type=$2->type;
		$$->length=$2->length;
	  };
	  field:ID
	  {
		$$=$1;
	  };
	  type:CHAR '(' NUMBER ')'
	  {
		$$=(struct fieldType *)malloc(sizeof(struct fieldType));
		$$->type=CHAR;
		$$->length=atoi($3);
	  }
	 |INT
	  {
		$$=(struct fieldType *)malloc(sizeof(struct fieldType));
		$$->type=INT;
		$$->length=4;
	  };

/****************************ON SELECT DEFINATION************************
*SELECT Sno, Sname FROM student WHERE Ssex='ÄÐ' AND Sage=20;
*		fields_star -> table_fields | *
*		table_fields -> table_field | table_fields , table_field
*		table_field -> field | table . fields
*		tables -> table | tables , table
*		condition -> condition | '(' conditions ')' | conditions  AND conditions | conditions OR conditions
*
*************************************************************************/
selectsql:SELECT fields_star FROM tables ';'
	  {
		selectPart($2,$4);
	  }
	 |SELECT fields_star FROM tables WHERE conditions ';'
	  {
		selectPartCondition($2,$4,$6);
	  };
	  fields_star:table_fields
	  {
		$$ =(struct Selectedfields *)malloc(sizeof(struct Selectedfields));
		$$=$1;
	  }
	 |'*'
	  {
		$$ =(struct Selectedfields *)malloc(sizeof(struct Selectedfields));
		$$=NULL;
	  };
	  table_fields:table_field
	  {
		$$ =(struct Selectedfields *)malloc(sizeof(struct Selectedfields));
		$$=$1;
	  }
	 |table_field ',' table_fields
	  {
		$$ =(struct Selectedfields *)malloc(sizeof(struct Selectedfields));
		$$->field=$1->field;
		$$->table=$1->table;
		$$->next_sf=$3;
	  };
	  table_field:field
	  {
		$$=(struct Selectedfields *)malloc(sizeof(struct Selectedfields));
		$$->field=$1;
		$$->table=NULL;
		$$->next_sf=NULL;
	  }
	 |table '.' field
	  {
		$$=(struct Selectedfields *)malloc(sizeof(struct Selectedfields));
		$$->field=$3;
		$$->table=$1;
		$$->next_sf=NULL;
	  };
	  tables:table
	  {
		$$=(struct Selectedtables *)malloc(sizeof(struct Selectedtables));
		$$->table=$1;
		$$->next_st=NULL;
	  }
	 |table ',' tables
	  {
		$$=(struct Selectedtables *)malloc(sizeof (struct Selectedtables));
		$$->table=$1;
		$$->next_st=$3;
	  };
	  conditions:condition
	  {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$=$1;
	  }
	 |'('conditions')'
	  {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$=$2;
	  }
	 |conditions AND conditions
	  {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$->left=$1;
		$$->right=$3;
		$$->comp_op='A';
	  }
	 |conditions OR conditions
	  {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$->left=$1;
		$$->right=$3;
		$$->comp_op='O';
	  };
	  condition:comp_unit comp_op comp_unit
	  {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$->left=$1;
		$$->right=$3;
		$$->comp_op=$2;
	  };
	 comp_unit:table_field
	 {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$->type=0;
		$$->value=$1->field;
		$$->table=$1->table;
		$$->left=NULL;
		$$->right=NULL;
	 }
	|NUMBER
	 {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$->type=2;
		$$->value=$1;
		$$->table=NULL;
		$$->left=NULL;
		$$->right=NULL;
	 }
	|QUOTE ID QUOTE
	 {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$->type=1;
		$$->value=$2;
		$$->table=NULL;
		$$->left=NULL;
		$$->right=NULL;
	 }
	|QUOTE NUMBER QUOTE
	 {
		$$=(struct Conditions *)malloc(sizeof(struct Conditions));
		$$->type=1;
		$$->value=$2;
		$$->table=NULL;
		$$->left=NULL;
		$$->right=NULL;
	 };
	 comp_op:'<'
	 {
		$$='<';
	 }
	|'>'
	 {
		$$='>';
	 }
	|'='
	 {
		$$='=';
	 }
	|'!''='
	 {
		$$='!';
	 };
	 
/****************************ON INSERT DEFINATION************************
*INSERT INTO STUDENT(SNAME,SAGE,SSEX) VALUES ('ZHANGSAN',22,1);
*		table_fields -> table | table(value_fields)
*		value_fields -> value | value_fields , value
*		table_field -> field | table . fields
*		value -> 'ID' | ID | 'NUMBER' | NUMBER
*
*************************************************************************/
insertsql:INSERT INTO table VALUES '(' values ')' ';'
	  {
		insertALL($3,$6);
	  }
	 |INSERT INTO table '(' values ')' VALUES '(' values ')' ';'
	  {
		insertPart($3,$5,$9);
	  };
	  values:value
	  {
		$$=(struct insertValue *)malloc(sizeof(struct insertValue));
		$$->value=$1->value;
		$$->next_Value=NULL;
	  }
	 |value ',' values
	  {
		$$=(struct insertValue *)malloc(sizeof(struct insertValue));
		$$->value=$1->value;
		$$->next_Value=$3;
	  };
	  value:QUOTE ID QUOTE
	  {
		$$=(struct insertValue *)malloc(sizeof(struct insertValue));
		$$->value=$2;
		$$->next_Value=NULL;
	  }
	 |QUOTE NUMBER QUOTE
	  {
		$$=(struct insertValue *)malloc(sizeof(struct insertValue));
		$$->value=$2;
		$$->next_Value=NULL;
	  }
	 |NUMBER
	  {
		$$=(struct insertValue *)malloc(sizeof(struct insertValue));
		$$->value=$1;
		$$->next_Value=NULL;
	  }
	 |ID
	  {
		$$=(struct insertValue *)malloc(sizeof(struct insertValue));
		$$->value=$1;
		$$->next_Value=NULL;
	  };

usesql:USE ID ';'
       {
	    strcpy(baseName,$2);
	    useDataBase();
       };
showsql	:SHOW DATABASES ';'
	 {
		showDataBase();
	 }
	|SHOW TABLES ';'
	 {
		showTable();
	 };
	 
deletesql:DELETE FROM table ';'
	 |DELETE FROM table WHERE conditions ';'
	  {
		deleteCondition($3,$5);
	  };
dropsql:DROP TABLE ID ';'
	{
		dropTable($3);
	}
       |DROP DATABASE ID ';'
	{
		strcpy(baseName,$3);
		dropDataBase();
	};
	
/****************************ON UPDATE DEFINATION************************
*UPDATE STUDENT SET SAGE=27,SSEX=1 WHERE SNAME='ZHANGSAN';
*		table_fields -> table | table(value_fields)
*		value_fields -> value | value_fields , value
*		value -> 'ID'='ID' | ID = NUMBER
*
*************************************************************************/
updatesql:UPDATE table SET sets ';'
	 |UPDATE table SET sets WHERE conditions ';'
	  {
		updateCondition($2,$4,$6);
	  };
	  sets:set
	  {
		$$=$1;
	  }
	 |set ',' sets
	  {
		$$=(struct Updatestruct *)malloc(sizeof(struct Updatestruct));
		$$->field=$1->field;
		$$->value=$1->value;
		$$->next_sf=$3;
	  };
	  set:ID '=' NUMBER
	  {
		$$=(struct Updatestruct *)malloc(sizeof(struct Updatestruct));
		$$->field=$1;
		$$->value=$3;
		$$->next_sf=NULL;
	  }
	 |ID '=' QUOTE ID QUOTE
	  {
		$$=(struct Updatestruct *)malloc(sizeof(struct Updatestruct));
		$$->field=$1;
		$$->value=$4;
		$$->next_sf=NULL;
	  };
exitsql:EXIT ';'
	{
           	exit(0);
	};		
%%
///////////////////////////////////////////////////////////////////////////////////////////////


/***********TODO : MAIN FUNCTIONS REFERENCES OF SQL IN C++***************/
char* removeEnter(char *s) {
	char *ret;
	ret = (char*)malloc(100 * sizeof(char));
	memset(ret, 0, sizeof(ret));
	int i;
	for ( i = 0; s[i] != '\n' && i < strlen(s); i++) {
		ret[i] = s[i];
	}
	ret[i] = 0;
	return ret;
}

void createDataBase() 
{
	_chdir(dir);
	if (_access(baseName, 0) != -1) {
		printf("[!] Database Already Exist\n");
	}
	else {
		if (_mkdir(baseName) == -1) {
			printf("[!] Create Database Directory Failed, Check If You are Administrator\n");
		}
		else {
			freopen("sys.dat", "a", stdout);
			printf("%s\n", baseName);
			freopen("CON", "w", stdout);
			printf("[+] Database Created, 1 Row Affected\n");
		}
	}
	memset(baseName, 0, sizeof(baseName));
	printf("\nSQL_lite > ");
}

void showDataBase() 
{
	_chdir(dir);
	FILE *fp;
	if ((fp = fopen("sys.dat", "r")) == NULL) {
		printf("[!] Can Not Open Database File, Check If File Exist\n");
	}
	else {
		char now[100];
		printf("[#] Database : \n");
		printf("+---------------------+\n");
		while (~fscanf(fp, "%s", now)) {
			printf("|%-21s|\n", now);
			printf("+---------------------+\n");
		}
	}
	fclose(fp);
	printf("\nSQL_lite > ");
}

void useDataBase() 
{
	_chdir(dir);
	if (_access(baseName, 0) != 0) {
		printf("[!] Database [%s] Does Not Exist.\n", baseName);
	}
	else {
		if(_chdir(baseName) == 0)
			printf("[#] Using Database : %s\n", baseName);
	}
	printf("\nSQL_lite > ");
}

void dropDataBase() 
{
	_chdir(dir);
	char cmd[100];
	memset(cmd, 0, sizeof(cmd));
	FILE *fp = fopen("sys.dat", "r");
	if (fp != NULL) {
		char nameList[100][100];
		memset(nameList, 0, sizeof(nameList));
		int Line = 0;
		while (fscanf(fp, "%s", nameList[Line]) != EOF) {
			if (strcmp(nameList[Line], baseName) != 0) {
				Line++;
			}
			else {
				memset(nameList[Line], 0, sizeof(nameList[Line]));
			}
		}
		fclose(fp);
		fp = fopen("sys.dat", "w");
		int i;
		for (i = 0; i < Line; i++) {
			fprintf(fp, "%s\n", nameList[i]);
		}
		if (_access(baseName, 0) == 0) {
			strcat(cmd, "rd /s /q ");
			strcat(cmd, baseName);
			printf("[#] Database [%s] Droped\n", baseName);
		}
		else {
			printf("[!] Database [%s] Does Not Exist\n", baseName);
		}
		fclose(fp);
	}
	else {
		printf("[!] Can Not Open Database File, Check If File Exist\n");
	}
	printf("\nSQL_lite > ");
	system(cmd);
}

void createTable(struct Createstruct *createList)
{
	struct Createfieldsdef *nextcf = createList->fdef;
	_chdir(dir);
	if (strlen(baseName) == 0)
	{
		printf("[!] No Database Used\n");
		return;
	}
	_chdir(baseName);
	char tableName[100];
	strcpy(tableName, createList->table);
	FILE *fp;
	if ((fp = fopen("sys.dat", "a")) == NULL)
	{
		printf("[!] Table List Unreachable\n");
	}
	else
	{
		char tableFile[100];
		memset(tableFile, 0, sizeof(tableFile));
		strcpy(tableFile, tableName);
		strcat(tableFile, ".txt");
		if (_access(tableFile, 0) != -1)
		{
			printf("[!] Table [%s] Already Exist\n", tableFile);
		}
		else
		{
			int pros = 0;
			while (nextcf != NULL) {
				fprintf(fp, "%s %d ", tableName, ++pros);
				if (nextcf->type == CHAR)
				{
					fprintf(fp, "%s ", nextcf->field);
					fprintf(fp, "CHAR %d\n", (int)nextcf->length);
				}
				else if (nextcf->type == INT)
				{
					fprintf(fp, "%s INT 4\n", nextcf->field);
				}
				nextcf = nextcf->next_fdef;
			}
			fclose(fp);
			fp = fopen(tableFile, "w");
			fclose(fp);
			printf("[#] Table [%s] Created With %d Properties\n", tableName, pros);
		}
	}
	nextcf = createList->fdef;
	while (nextcf != NULL) {
		struct Createfieldsdef *tmp = nextcf;
		nextcf = nextcf->next_fdef;
		free(tmp);
	}
	free(createList);
	printf("\nSQL_lite > ");
}

void showTable()
{
	_chdir(dir);
	if (strlen(baseName) == 0)
	{
		printf("[!] No Database Used\n");
		return;
	}
	_chdir(baseName);
	FILE *fp;
	if ((fp = fopen("sys.dat", "r")) == NULL)
	{
		printf("[!] Table List Unreachable\n");
	}
	else
	{
		char tableName[100], col[100], type[10];
		int n, len;
		memset(tableName, 0, sizeof(tableName));
		memset(col, 0, sizeof(col));
		memset(type, 0, sizeof(type));
		printf("[#] Tables In Database [%s]\n", baseName);
		printf("+--------------------------------------------------------------+\n");
		while (~fscanf(fp, "%s %d %s %s %d", tableName, &n, col, type, &len))
		{
			if (strcmp(type, "CHAR") == 0)
			{
				printf("|%-32s|%-4d|%-14s|CHAR|%-4d|\n", tableName, n, col, len);
			}
			else if (strcmp(type, "INT") == 0)
			{
				printf("|%-32s|%-4d|%-14s|INT |%-4d|\n", tableName, n, col, len);
			}
			printf("+--------------------------------------------------------------+\n");
			memset(tableName, 0, sizeof(tableName));
			memset(col, 0, sizeof(col));
			memset(type, 0, sizeof(type));
		}
	}
	fclose(fp);
	printf("\nSQL_lite > ");
}

void dropTable(char *tableName)
{
	_chdir(dir);
	if (strlen(baseName) == 0)
	{
		printf("[!] No Database Used\n");
		return;
	}
	_chdir(baseName);
	char fileName[100];
	memset(fileName, 0, sizeof(fileName));
	strcpy(fileName, tableName);
	strcat(fileName, ".txt");
	if (_access(fileName, 0) == 0)
	{
		FILE *fp;
		if ((fp = fopen("sys.dat", "r")) == NULL)
		{
			printf("[!] Table List Unreachable\n");
		}
		else {
			int tables = 0;
			char nameList[100][100];
			memset(nameList, 0, sizeof(nameList));
			char tmptable[100];
			memset(tmptable, 0, sizeof(tmptable));
			while (fgets(tmptable, 100, fp) != NULL)
			{
				char ntable[100];
				memset(ntable, 0, sizeof(ntable));
				sscanf(tmptable, "%s", ntable);
				if (strcmp(ntable, tableName) != 0) {
					strcpy(nameList[tables++], tmptable);
				}
			}
			fclose(fp);
			fp = fopen("sys.dat", "w");
			int i;
			for (i = 0; i < tables; i++) {
				fprintf(fp, "%s", nameList[i]);
			}
			fclose(fp);
			char cmd[100] = "del ";
			strcat(cmd, fileName);
			system(cmd);
			printf("[#] Table [%s] Droped\n", tableName);
		}
		}
	else
	{
		printf("[!] Table [%s] Does Not Exist\n", tableName);
	}
	printf("\nSQL_lite > ");
}

void insertALL(char *tableName, struct insertValue *values)
{
	_chdir(dir);
	if (strlen(baseName) == 0)
	{
		printf("[!] No Database Used\n");
		return;
	}
	_chdir(baseName);
	char fileName[100];
	memset(fileName, 0, sizeof(fileName));
	strcpy(fileName, tableName);
	strcat(fileName, ".txt");
	if (_access(fileName, 0) == 0)
	{
		struct insertValue *valueList = values;
		FILE *fp;
		if ((fp = fopen(fileName, "a")) == NULL)
		{
			printf("[!] Table File [%s] Open Failed\n", fileName);
		}
		else
		{
			while (valueList != NULL) {
				if (valueList->next_Value == NULL)
				{
					fprintf(fp, "%s\n", valueList->value);
				}
				else
				{
					fprintf(fp, "%s ", valueList->value);
				}
				valueList = valueList->next_Value;
			}
			fclose(fp);
			printf("[#] Insert Into Table [%s], 1 row Affected\n", tableName);
		}
	}
	else
	{
		printf("[!] Table [%s] Does Not Exist\n", tableName);
	}
	while (values != NULL) {
		struct insertValue *tmp = values;
		values = values->next_Value;
		free(tmp);
	}
	printf("\nSQL_lite > ");
}

void insertPart(char *tableName, struct insertValue *valueName, struct insertValue *values)
{
	_chdir(dir);
	if (strlen(baseName) == 0)
	{
		printf("[!] No Database Used\n");
		return;
	}
	_chdir(baseName);
	char fileName[100];
	memset(fileName, 0, sizeof(fileName));
	strcpy(fileName, tableName);
	strcat(fileName, ".txt");
	if (_access(fileName, 0) != -1)
	{
		struct insertValue *valName = valueName;
		struct insertValue *val = values;
		char allField[100][100];
		int fields = 0;
			
		FILE *fp;
		if ((fp = fopen("sys.dat", "r")) != NULL) {
			char line[100];
			memset(line, 0, sizeof(line));
			while (fgets(line, 100, fp) != NULL) {
				char ntable[100], nfield[100];
				int col;
				memset(ntable, 0, sizeof(ntable));
				memset(nfield, 0, sizeof(nfield));
				sscanf(line, "%s %d %s", ntable, &col, nfield);
				if (strcmp(ntable, tableName) == 0) {
					strcpy(allField[fields++], nfield);
				}
				memset(line, 0, sizeof(line));
			}
			fclose(fp);
		}
		else {
			printf("[!] Table List Unreachable\n");
		}

		if ((fp = fopen(fileName, "a")) != NULL) {
			int loc[100], locs = 0;
			memset(loc, 0, sizeof(loc));
			while (valName != NULL) {
				char nfield[100];
				memset(nfield, 0, sizeof(nfield));
				strcpy(nfield, valName->value);
				for (int i = 0; i < fields; i++) {
					if (strcmp(allField[i], nfield) == 0) {
						loc[locs++] = i;
						break;
					}
				}
				valName = valName->next_Value;
			}
			int now = 0;
			char nowValue[100][100];
			memset(nowValue, 0, sizeof(nowValue));
			while (val != NULL) {
				strcpy(nowValue[loc[now++]], val->value);
				val = val->next_Value;
			}
			for (int i = 0; i < fields; i++) {
				if (strlen(nowValue[i]) == 0) {
					if (i != fields - 1) fprintf(fp, "NULL ");
					else fprintf(fp, "NULL\n");
				}
				else {
					if (i != fields - 1) fprintf(fp, "%s ", nowValue[i]);
					else fprintf(fp, "%s\n", nowValue[i]);
				}
			}
			printf("[#] Insert Into Table [%s], 1 row Affected\n", tableName);
			fclose(fp);
		}
		else {
			printf("[!] Open Database File [%s] Failed\n", fileName);
		}

		while (valueName != NULL)
		{
			struct insertValue *tmp = valueName;
			valueName = valueName->next_Value;
			free(tmp);
		}
		while (values != NULL)
		{
			struct insertValue *tmp = values;
			values = values->next_Value;
			free(tmp);
		}
	}
	else
	{
		printf("[!] Table [%s] Does Not Exist\n", tableName);
	}
	printf("\nSQL_lite > ");
}

bool getCondition(struct Conditions *now, char fieldName[][100], char  fieldValue[][100])
{
	if (now->comp_op == 'A') {
		if (getCondition(now->left, fieldName, fieldValue) && getCondition(now->right, fieldName, fieldValue))
			return true;
	}
	else if (now->comp_op == 'O') {
		if (getCondition(now->left, fieldName, fieldValue) || getCondition(now->right, fieldName, fieldValue))
			return true;
	}
	else {
		int tot = 0, i;
		for (i = 0; i < 100; i++) {
			if (strlen(fieldName[i]) > 0)
				tot++;
			else
				break;
		}
		int posName = -1;
		//Ssex = 'ÄÐ'
		if (now->left->type == 0) {
			for (i = 0; i < tot; i++) {
				if (strcmp(now->left->value, fieldName[i]) == 0) {
					posName = i;
					break;
				}
			}
		}
		//'ÄÐ' = Ssex
		else if (now->right->type == 0) {
			for (int i = 0; i < tot; i++) {
				if (strcmp(now->right->value, fieldName[i]) == 0) {
					posName = i;
					break;
				}
			}
		}
		if (posName == -1) {
			return true;
		}
		if (now->comp_op == '=' || now->comp_op == '!') {
			if (now->left->type == 0) {
				if (now->comp_op == '=') {
					return (strcmp(now->right->value, fieldValue[posName]) == 0) ? true : false;
				}
				else if (now->comp_op == '!') {
					return (strcmp(now->right->value, fieldValue[posName]) != 0) ? true : false;
				}
			}
			else {
				if (now->comp_op == '=') {
					return (strcmp(now->left->value, fieldValue[posName]) == 0) ? true : false;
				}
				else if (now->comp_op == '!') {
					return (strcmp(now->left->value, fieldValue[posName]) != 0) ? true : false;
				}
			}
		}
		else if (now->comp_op == '>' || now->comp_op == '<') {
			if (now->left->type == 0) {
				if (now->comp_op == '>') {
					return (atoi(now->right->value) < atoi(fieldValue[posName])) ? true : false;
				}
				else if (now->comp_op == '<') {
					return (atoi(now->right->value) > atoi(fieldValue[posName])) ? true : false;
				}
			}
			else {
				if (now->comp_op == '>') {
					return (atoi(now->left->value) > atoi(fieldValue[posName])) ? true : false;
				}
				else if (now->comp_op == '<') {
					return (atoi(now->left->value) < atoi(fieldValue[posName])) ? true : false;
				}
			}
		}
	}
}

void freeCondition(struct Conditions *now)
{
	if (now->left != NULL)
	{
		freeCondition(now->left);
	}
	else if (now->right != NULL)
	{
		freeCondition(now->right);
	}
	else
	{
		free(now);
	}
}

void selectPart(struct Selectedfields *field, struct Selectedtables *table)
{
	_chdir(dir);
	if (strlen(baseName) == 0)
	{
		printf("[!] No Database Used\n");
		return;
	}
	_chdir(baseName);
	struct Selectedfields *fieldNow = field;
	struct Selectedtables *tableNow = table;
	char sf[100][100], st[100][100];
	memset(sf, 0, sizeof(sf));
	memset(st, 0, sizeof(st));
	int totField = 0, totTable = 0;
	bool all = false;
	if (fieldNow == NULL) {
		all = true;
	}
	while (fieldNow != NULL) {
		strcpy(sf[totField++], fieldNow->field);
		fieldNow = fieldNow->next_sf;
	}
	while (tableNow != NULL) {
		strcpy(st[totTable++], tableNow->table);
		tableNow = tableNow->next_st;
	}
	if (all) {
		int i;
		for (i = 0; i < totTable; i++) {
			char curTable[100];
			memset(curTable, 0, sizeof(curTable));
			strcpy(curTable, st[i]);
			strcat(curTable, ".txt");
			if (_access(curTable, 0) == 0) 
			{
				FILE *fp;
				if ((fp = fopen(curTable, "r")) != NULL) 
				{
					char line[100];
					memset(line, 0, sizeof(line));
					printf("[#] Selected From Table [%s] : \n", st[i]);
					printf("+-----------------------------------------------------+\n");
					while (fgets(line, 100, fp) != NULL) {
						char *nline = removeEnter(line);
						printf("|");
						const char *split = " ";
						char *ps;
						ps = strtok(nline, split);
						while (ps != NULL) {
							printf("%-10s|", ps);
							ps = strtok(NULL, split);
						}
						printf("\n");
						printf("+-----------------------------------------------------+\n");
						memset(line, 0, sizeof(line));
					}
				}
				else {
					printf("[!] Open Table File Failed\n");
				}
				fclose(fp);
			}
			else {
				printf("[!] Can Not Access Table File\n");
			}

		}
	}
	else {
		if (totTable > 1) 
		{
			printf("[!] Can Not Select More Than One Table In Such Case\n");
		}
		else if(totTable == 1)
		{
			char curTable[100], tname[100], fname[100];
			memset(curTable, 0, sizeof(curTable));
			memset(tname, 0, sizeof(tname));
			memset(fname, 0, sizeof(fname));
			strcpy(curTable, st[0]);
			int pos[100], p = 0, i, col;
			memset(pos, 0, sizeof(pos));
			FILE *fp = fopen("sys.dat", "r");
			if (fp == NULL) {
				printf("[!] Table List Unreachable\n");
				return;
			}
			while (fscanf(fp, "%s %d %s", tname, &col, fname) != EOF) {
				if (strcmp(tname, curTable) == 0)
				{
					for (i = 0; i < totField; i++) {
						if (strcmp(fname, sf[i]) == 0) {
							pos[p++] = col;
							break;
						}
					}
				}
				fgets(tname, 100, fp);
				memset(tname, 0, sizeof(tname));
				memset(fname, 0, sizeof(fname));
			}
			if (p == 0) {
				printf("[!] No Filed Selected In Table [%s] \n", curTable);
				return;
			}
			fclose(fp);
			strcat(curTable, ".txt");
			fp = fopen(curTable, "r");
			if (fp == NULL) {
				printf("[!] Can Not Open Table File\n");
				return;
			}
			char line[100];
			memset(line, 0, sizeof(line));
			printf("[#] Selected From Table [%s]\n", st[0]);
			printf("+-----------------------------------------------------+\n");
			while (fgets(line, 100, fp) != NULL) {
				char *nline = removeEnter(line);
				char tnow[100][100];
				memset(tnow, 0, sizeof(tnow));
				int n = 0;
				const char *split = " ";
				char *ps;
				ps = strtok(nline, split);
				while (ps != NULL) {
					strcpy(tnow[n++], ps);
					ps = strtok(NULL, split);
				}
				int k;
				printf("|");
				for (k = 0; k < p; k++) {
					printf("%-10s|", tnow[pos[k]-1]);
				}
				printf("\n+-----------------------------------------------------+\n");
				memset(line, 0, sizeof(line));
			}
			fclose(fp);
		}
	}


	struct Selectedfields *fieldnow = field;
	struct Selectedtables *tablenow = table;
	while (field!= NULL)
	{
		fieldnow = field;
		field = field->next_sf;
		free(fieldnow);
	}
	while (table != NULL)
	{
		tablenow = table;
		table = table->next_st;
		free(tablenow);
	}
	printf("\nSQL_lite > ");
}

void selectPartCondition(struct Selectedfields *field, struct Selectedtables *table, struct Conditions *condition)
{
	struct Selectedfields *sf = field;
	struct Selectedtables *st = table;
	struct Conditions *cons = condition;
	_chdir(dir);
	if (strlen(baseName) == 0)
	{
		printf("[!] No Database Used\n");
		return;
	}
	_chdir(baseName);
	char fieldName[100][100];
	char tableName[100][100];
	int totField = 0, totTable = 0;
	memset(fieldName, 0, sizeof(fieldName));
	memset(tableName, 0, sizeof(tableName));
	bool all = false;
	if (sf == NULL) {
		all = true;
	}
	while (sf != NULL) {
		strcpy(fieldName[totField++], sf->field);
		sf = sf->next_sf;
	}
	while (st != NULL) {
		strcpy(tableName[totTable++], st->table);
		st = st->next_st;
	}

	for (int i = 0; i < totTable; i++) {
		printf("[#] In Table [%s] Selected: \n", tableName[i]);
		printf("+-----------------------------------------------------+\n");
		char allField[100][100];
		int fields = 0;
		memset(allField, 0, sizeof(allField));
		FILE *fp = fopen("sys.dat", "r");
		if (fp == NULL) {
			printf("[!] Table List Unreachable\n");
			return;
		}
		char line[100];
		memset(line, 0, sizeof(line));
		while (fgets(line, 100, fp) != NULL) {
			char tname[100], fname[100];
			memset(tname, 0, sizeof(tname));
			memset(fname, 0, sizeof(fname));
			int col;
			sscanf(line, "%s %d %s", tname, &col, fname);
			if (strcmp(tname, tableName[i]) == 0) {
				strcpy(allField[fields++], fname);
			}
			memset(line, 0, sizeof(line));
		}
		fclose(fp);
		strcat(tableName[i], ".txt");
		fp = fopen(tableName[i], "r");
		if (fp == NULL) {
			printf("[!] Can Not Open Table File\n");
			return;
		}
		while (fgets(line, 100, fp) != NULL) {
			char *nline = removeEnter(line);
			char nowValue[100][100];
			int values = 0;
			memset(nowValue, 0, sizeof(nowValue));
			const char *split = " ";
			char *ps;
			ps = strtok(nline, split);
			while (ps != NULL) {
				strcpy(nowValue[values++], ps);
				ps = strtok(NULL, split);
			}
			bool valid = getCondition(condition, allField, nowValue);
			if (valid == true) {
				printf("|");
				if (!all) {
					for (int i = 0; i < totField; i++) {
						for (int j = 0; j < fields; j++) {
							if (strcmp(fieldName[i], allField[j]) == 0) {
								printf("%-10s|", nowValue[j]);
								break;
							}
						}
					}
					printf("\n+-----------------------------------------------------+\n");
				}
				else {
					for (int i = 0; i < values; i++) {
						printf("%-10s|", nowValue[i]);
					}
					printf("\n+-----------------------------------------------------+\n");
				}
			}
			memset(nowValue, 0, sizeof(nowValue));
		}
		fclose(fp);
	}

	freeCondition(condition);
	struct Selectedfields *fieldnow = field;
	struct Selectedtables *tablenow = table;
	while (field != NULL)
	{
		fieldnow = field;
		field = field->next_sf;
		free(fieldnow);
	}
	while (table != NULL)
	{
		tablenow = table;
		table = table->next_st;
		free(tablenow);
	}
	printf("\nSQL_lite > ");
}

void updateCondition(char *tableName, struct Updatestruct *valueList, struct Conditions *condition)
{
	struct Updatestruct *val = valueList;
	struct Conditions *cons = condition;
	_chdir(dir);
	if (strlen(baseName) == 0)
	{
		printf("[!] No Database Used\n");
		return;
	}
	_chdir(baseName);
	char backup[100][100], tableFile[100];
	int bcps = 0;
	memset(backup, 0, sizeof(backup));
	memset(tableFile, 0, sizeof(tableFile));
	strcat(tableFile, tableName);
	strcat(tableFile, ".txt");
	FILE *fp = fopen(tableFile, "r");
	if (fp == NULL) {
		printf("[!] Can Not Open Table File\n");
		return;
	}
	while (fgets(backup[bcps++], 100, fp));
	fclose(fp);
	char allField[100][100];
	int fields = 0;
	memset(allField, 0, sizeof(allField));
	fp = fopen("sys.dat", "r");
	if (fp == NULL) {
		printf("[!] Table List Unreachable\n");
		return;
	}
	char line[100];
	memset(line, 0, sizeof(line));
	while (fgets(line, 100, fp) != NULL) {
		char tname[100], fname[100];
		memset(tname, 0, sizeof(tname));
		memset(fname, 0, sizeof(fname));
		int col;
		sscanf(line, "%s %d %s", tname, &col, fname);
		if (strcmp(tname, tableName) == 0) {
			strcpy(allField[fields++], fname);
		}
		memset(line, 0, sizeof(line));
	}
	fclose(fp);
	fp = fopen(tableFile, "w");
	if (fp == NULL) {
		printf("[!] Can Not Open Table File\n");
		return;
	}
	int affected = 0;
	for (int i = 0; i < bcps; i++) {
		char nowValue[100][100];
		int values = 0;
		memset(nowValue, 0, sizeof(nowValue));
		char *nline = removeEnter(backup[i]);
		const char *split = " ";
		char *ps;
		ps = strtok(nline, split);
		while (ps != NULL) {
			strcpy(nowValue[values++], ps);
			ps = strtok(NULL, split);
		}
		bool valid = getCondition(condition, allField, nowValue);
		if (valid) {
			affected++;
			struct Updatestruct *now = valueList;
			while (now != NULL) {
				char nfield[100], nvalue[100];
				memset(nfield, 0, sizeof(nfield));
				memset(nvalue, 0, sizeof(nvalue));
				strcpy(nfield, now->field);
				strcpy(nvalue, now->value);
				int chidx = -1;
				for (int i = 0; i < fields; i++) {
					if (strcmp(nfield, allField[i]) == 0) {
						chidx = i;
						break;
					}
				}
				if (chidx == -1) {
					printf("[!] No Update Field In Table [%s] \n", tableName);
					return;
				}
				strcpy(nowValue[chidx], nvalue);
				now = now->next_sf;
			}
		} 
		for (int i = 0; i < values; i++) {
			if (i != values - 1)
				fprintf(fp, "%s ", nowValue[i]);
			else
				fprintf(fp, "%s\n", nowValue[i]);
		}
	}
	fclose(fp);
	printf("[#] Table Updated, %d Rows Affected\n", affected);

	freeCondition(condition);
	printf("\nSQL_lite > ");
}

void deleteCondition(char *tableName, struct Conditions *condition)
{
	struct Conditions *cons = condition;
	_chdir(dir);
	if (strlen(baseName) == 0)
	{
		printf("[!] No Database Used\n");
		return;
	}
	_chdir(baseName);
	char backup[100][100], tableFile[100];
	int bcps = 0;
	memset(backup, 0, sizeof(backup));
	memset(tableFile, 0, sizeof(tableFile));
	strcat(tableFile, tableName);
	strcat(tableFile, ".txt");
	FILE *fp = fopen(tableFile, "r");
	if (fp == NULL) {
		printf("[!] Can Not Open Table File\n");
		return;
	}
	while (fgets(backup[bcps++], 100, fp));
	fclose(fp);
	char allField[100][100];
	int fields = 0;
	memset(allField, 0, sizeof(allField));
	fp = fopen("sys.dat", "r");
	if (fp == NULL) {
		printf("[!] Table List Unreachable\n");
		return;
	}
	char line[100];
	memset(line, 0, sizeof(line));
	while (fgets(line, 100, fp) != NULL) {
		char tname[100], fname[100];
		memset(tname, 0, sizeof(tname));
		memset(fname, 0, sizeof(fname));
		int col;
		sscanf(line, "%s %d %s", tname, &col, fname);
		if (strcmp(tname, tableName) == 0) {
			strcpy(allField[fields++], fname);
		}
		memset(line, 0, sizeof(line));
	}
	fclose(fp);
	fp = fopen(tableFile, "w");
	if (fp == NULL) {
		printf("[!] Can Not Open Table File\n");
		return;
	}
	int affected = 0;
	for (int i = 0; i < bcps; i++) {
		char nowValue[100][100];
		int values = 0;
		memset(nowValue, 0, sizeof(nowValue));
		char *nline = removeEnter(backup[i]);
		const char *split = " ";
		char *ps;
		ps = strtok(nline, split);
		while (ps != NULL) {
			strcpy(nowValue[values++], ps);
			ps = strtok(NULL, split);
		}
		bool valid = getCondition(condition, allField, nowValue);
		if (valid) {
			affected++;
			continue;
		}
		for (int i = 0; i < values; i++) {
			if (i != values - 1)
				fprintf(fp, "%s ", nowValue[i]);
			else
				fprintf(fp, "%s\n", nowValue[i]);
		}
	}
	printf("[#] Data Deleted, %d Rows Affected\n", affected);
	fclose(fp);

	freeCondition(condition);
	printf("\nSQL_lite > ");
}

/************************************************************************/
void yyerror(const char *str)
{
    printf("%s at ->  %s\n", str, yytext);
    printf("\nSQL_lite > ");
}
int yywrap()
{
    return 1;
}

void main()
{
    printf("*-------------------------------------------------------*\n");
	printf("+ Welcome to SQL_lite monitor. Commands end with ;\n");
	printf("+ SQL_Lite Version 1.02 - Windows 10(64 bits)\n");
	printf("+ Copyright Petite7@vip.qq.com 2018 with GPL 2.0   All Rights Reserved\n\n");
	FILE *fp = fopen("time", "r");
	if (fp != NULL) {
		char last_time[100];
		memset(last_time, 0, sizeof(last_time));
		fgets(last_time, 100, fp);
		printf("+ Last log in time : [%s]\n", last_time);
		fclose(fp);
	}
	time_t rawtime;
	struct tm * timeinfo;
	char buffer[80];

	time(&rawtime);
	timeinfo = localtime(&rawtime);

	strftime(buffer, 80, "%c", timeinfo);
	fp = fopen("time", "w");
	fputs(buffer, fp);
	fclose(fp);
	char this_time[100];
	memset(this_time, 0, sizeof(this_time));
	strcat(this_time, "+ Now is : ");
	strcat(this_time, buffer);
	strcat(this_time, ", Have a nice day.\n");
	puts(this_time);
	printf("*-------------------------------------------------------*\n");
    printf("\nSQL_lite > ");
    while(true)
    {
		yyparse();
    }
}