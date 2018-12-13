#include <cstdio>
#include "define.h"
#include "slib.h"
#include "dlib.h"
#include "common.h"

int main()
{
    printf("Version: %s\n", VERSION);
    printf("main()::start main ...\n");
    
    common();
    module_main();
    
    printf("Dynamic Lib: %s\n", dlib_name());
    printf("2 + 3 = %d\n", add(2, 3));
    
    printf("Static Lib: %s\n", slib_name());
    printf("4 * 5 = %d\n", multi(4, 5));

    return 0;
}
