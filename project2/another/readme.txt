lex file更動:
print維持原狀，將yacc需要的字回傳，包含資料型態、ID、保留字、各式各樣的字元，在debug過程中發現我在return(STRING)和原本的%x STRING撞名，
導致symtax error，問同學才發現了這個問題，因此也把%x STRING取代成%x STR。conmment的地方因為沒有要傳給yacc所以沒有更動，
因為多個file需要共用yylex，加上extern int yylex(void);。