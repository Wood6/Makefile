静态库和动态库的源码，模拟第三方库： 1、编译成静态库的编译命令： g++ -c slib.cpp -o slib.o
	ar -q slib.a slib.o
2、编译成动态库的编译命令： g++ -shared -fIPC dlib.cpp -o dlib.so