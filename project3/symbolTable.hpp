#include <iostream>
#include <string.h>
#include <string>
#include <vector>
#include <sstream>
#include <fstream>
using namespace std;
extern int linenum;
extern void yyerror(char *s);

int boolean_expr_counter = 0;
int if_else_counter = 0;
int while_counter = 0;
int for_counter = 0;

enum DataType{
    iNT,
    rEAL,
    bOOL,
    sTRING,
    vOID,
    aRRAY
};

struct ID{
    int const_var_array_function_prod = 0; // 1: const, 2: var, 3: array 4: function 5: procedure
    string name;               // identifier's name
    int data_type;
    // data value
    int integer;
    bool boool;
    string str;
    ID(){
        const_var_array_function_prod = 0;
        name = "";
        data_type = iNT;
        integer = 0;
        boool = true;
        str = "";
    }
    ID(int vvaf, const char *s, int type, int inte, bool booool, string stri){
        const_var_array_function_prod = vvaf;
        name = s;
        data_type = type;
        
        integer = inte;
        boool = booool;
        str = stri;
    }
};

struct SymbolTable{
    int layer = 0; // layer of symbol table
    vector<ID> id; // identifier
    SymbolTable *previous = nullptr;
    SymbolTable *next = nullptr;
};

SymbolTable *head = nullptr;
SymbolTable *cur_table = head;
SymbolTable *temp_table = nullptr;

ofstream fileJasm;

void create(){
    SymbolTable *newSymbolTable = new SymbolTable();
    newSymbolTable -> id.clear();

    if (head == nullptr && cur_table == head){
        newSymbolTable -> layer = 0; // 1st symbol table
        newSymbolTable -> previous = nullptr;

        head = newSymbolTable;
        cur_table = head;
    }
    else{
        newSymbolTable -> layer = cur_table -> layer + 1;
        newSymbolTable -> previous = cur_table;

        // set current table
        cur_table -> next = newSymbolTable;
        cur_table = newSymbolTable;
    }
}

ID lookup(const char *s){
    SymbolTable *iter_table = cur_table;
    while (iter_table != NULL){
        for (int i = 0; i < iter_table -> id.size(); i++){
            if (iter_table -> id[i].name == s){
                return iter_table -> id[i];
            }
        }
        iter_table = iter_table -> previous;
    }
    return ID(0, "", iNT, 0, true, "");
}

void insert(int vvaf, const char *s, int type, int integer, bool boool, string str){
    ID newID = ID(vvaf, s, type, integer, boool, str);
    cur_table -> id.push_back(newID);
}

void dump(){
    cout << "-----Start to dump symbol table-----" << endl;
    SymbolTable *iter_table = head;
    while (iter_table != nullptr){
        cout << "number of symbol table: " << iter_table -> layer << endl;
        for (int i = 0; i < iter_table -> id.size(); i++){
            string temp_data_type = "";
            if (iter_table -> id[i].data_type == iNT){
                temp_data_type = "INT";
            }
            else if (iter_table -> id[i].data_type == rEAL){
                temp_data_type = "REAL";
            }
            else if (iter_table -> id[i].data_type == bOOL){
                temp_data_type = "BOOL";
            }
            else if (iter_table -> id[i].data_type == sTRING){
                temp_data_type = "STRING";
            }
            else if (iter_table -> id[i].data_type == vOID){
                temp_data_type = "VOID";
            }
            else if (iter_table -> id[i].data_type == aRRAY){
                temp_data_type = "ARRAY";
            }

            if (iter_table -> id[i].const_var_array_function_prod == 1){
                cout << i << ": " << iter_table -> id[i].name << " "
                     << "  constant  " << temp_data_type << endl;
            }
            else if (iter_table->id[i].const_var_array_function_prod == 2){
                cout << i << ": " << iter_table->id[i].name << " "
                     << "  variable  " << temp_data_type << endl;
            }
            else if (iter_table->id[i].const_var_array_function_prod == 3){
                cout << i << ": " << iter_table -> id[i].name << " "
                     << "  array  " << temp_data_type << endl;
            }
            else if (iter_table->id[i].const_var_array_function_prod == 4){
                cout << i << ": " << iter_table -> id[i].name << " "
                     << "  function  " << temp_data_type << endl;
            }
            else if (iter_table->id[i].const_var_array_function_prod == 5){
                cout << i << ": " << iter_table -> id[i].name << " "
                     << "  procedure  " << temp_data_type << endl;
            }
        }
        iter_table = iter_table -> next;
    }
    cout << "-----dump symbol table end-----" << endl;
}

void tab(int num){
    for (int i = 0; i < num; i++){
        fileJasm << "\t";
    }
}

ID find(string functionName){
    SymbolTable *iter_table = cur_table;
    while (iter_table != NULL){
        for (int i = 0; i < iter_table -> id.size(); i++){
            if (iter_table -> id[i].name == functionName){
                return iter_table -> id[i];
            }
        }
        iter_table = iter_table -> previous;
    }
    return ID(0, "", iNT, 0, true, "");
}

void putstatic_istore(const char *id){
    SymbolTable *iter_table = cur_table;
    while (iter_table != NULL){
        for (int i = 0; i < iter_table -> id.size(); i++){
            if (iter_table -> id[i].name == id){
                tab(cur_table -> layer + 1);
                if (iter_table == head){
                    fileJasm << "putstatic ";
                    if (iter_table->id[i].data_type == 0){
                        fileJasm << "int " << head -> id[0].name << "." << id << endl;
                        return;
                    }
                    else if (iter_table->id[i].data_type == 2){
                        fileJasm << "boolean " << head -> id[0].name << "." << id << endl;
                        return;
                    }
                    else{
                        yyerror((char *)"Identify data type error.");
                    }
                }
                else{
                    fileJasm << "istore " << i << endl;
                    return;
                }
            }
        }
        iter_table = iter_table -> previous;
    }
}

void getstatic_iload_sipush_iconst_ldc(const char *id){
    SymbolTable *iter_table = cur_table;
    while (iter_table != NULL){
        for (int i = 0; i < iter_table -> id.size(); i++){
            if (iter_table -> id[i].name == id){
                tab(cur_table -> layer + 1);
                if (iter_table -> id[i].const_var_array_function_prod == 2){
                    if (iter_table == head){
                        fileJasm << "getstatic ";
                        if (iter_table -> id[i].data_type == 0){
                            fileJasm << "int " << head -> id[0].name << "." << id << endl;
                            return;
                        }
                        else if (iter_table -> id[i].data_type == 2){
                            fileJasm << "boolean " << head -> id[0].name << "." << id << endl;
                            return;
                        }
                        else{
                            yyerror((char *)"Identify data type error.");
                        }
                    }
                    else{
                        fileJasm << "iload " << i << endl;
                        return;
                    }
                }
                else{
                    if (iter_table -> id[i].data_type == 0){
                        fileJasm << "sipush " << iter_table -> id[i].integer << endl;
                        return;
                    }
                    else if (iter_table -> id[i].data_type == 2){
                        if (iter_table->id[i].boool == true){
                            fileJasm << "iconst_1" << endl;
                            return;
                        }
                        else{
                            fileJasm << "iconst_0" << endl;
                            return;
                        }
                    }
                    else if (iter_table -> id[i].data_type == 3){
                        fileJasm << "ldc \"" << iter_table->id[i].str << "\"" << endl;
                        return;
                    }
                    else{
                        yyerror((char *)"Identify data type error.");
                    }
                }
            }
        }
        iter_table = iter_table -> previous;
    }
}

void boolean_expr_reduce(string boolean_operater){
    tab(cur_table -> layer + 1);
    fileJasm << "isub" << endl;
    tab(cur_table -> layer + 1);
    fileJasm << boolean_operater << " L" << boolean_expr_counter << endl;
    tab(cur_table -> layer + 1);
    fileJasm << "iconst_0" << endl;
    tab(cur_table -> layer + 1);
    fileJasm << "goto L" << boolean_expr_counter + 1 << endl;
    tab(cur_table -> layer);
    fileJasm << "L" << boolean_expr_counter << ": iconst_1" << endl;
    tab(cur_table -> layer);
    fileJasm << "L" << boolean_expr_counter + 1 << ":" << endl;
    boolean_expr_counter = boolean_expr_counter + 2;
}

void delete_ID(const char *s){
    SymbolTable *iter_table = cur_table;
    while (iter_table != NULL){
        for (int i = 0; i < iter_table -> id.size(); i++){
            if (iter_table -> id[i].name == s){
                iter_table -> id.erase(iter_table -> id.begin() + i);
            }
        }
        iter_table = iter_table -> previous;
    }
}
