#include<stdbool.h>

union u {
	int ival;
	float rval;
	char sval[256];
	bool bval;
};

struct s {
   int type; // 0: ival 1:rval 2: sval 3: bvalt 4:bvalf
   union u uval;
};
