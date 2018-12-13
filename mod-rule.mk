
# 伪目标 all
.PHONY : all

# 获取相对路径的绝对路径，这里是获取当前路径 . 的绝对路径
MODULE := $(realpath .)
# 取出模块文件名
MODULE := $(notdir $(MODULE))
# 模块最终编译的结果所放的路径，模块名加前缀 build/
DIR_OUTPUT := $(addprefix $(DIR_BUILD)/, $(MODULE))

# 模块编译所得到的静态库文件名
OUTPUT := $(MODULE).a
# 模块编译所得到的静态库文件路径
OUTPUT := $(addprefix $(DIR_BUILD)/, $(OUTPUT))

# 源码文件
SRCS := $(wildcard $(DIR_SRC)/*$(TYPE_SRC))
# 目标文件
OBJS := $(SRCS:$(TYPE_SRC)=$(TYPE_OBJ))
# 模块目标文件所放的编译路径
OBJS := $(patsubst $(DIR_SRC)/%, $(DIR_OUTPUT)/%, $(OBJS))
# 依赖文件
DEPS := $(SRCS:$(TYPE_SRC)=$(TYPE_DEP))
# 模块依赖文件所放的编译路径
DEPS := $(patsubst $(DIR_SRC)/%, $(DIR_OUTPUT)/%, $(DEPS))

# 告诉make解释器到各种类型的文件到哪里去寻找
# 头文件到DIR_INC、DIR_COMMON_INC、DIR_LIBS_INC去寻找
vpath %$(TYPE_INC) $(DIR_INC)
vpath %$(TYPE_INC) $(DIR_COMMON_INC)
vpath %$(TYPE_INC) $(DIR_LIBS_INC)
# 源文件到DIR_SRC文件夹中去寻找
vpath %$(TYPE_SRC) $(DIR_SRC)

# 自动生成依赖关系的思路：
# 1、通过 gcc -MM -E 和 sed 得到 .dep 依赖文件（目标部分依赖）
# 2、通过include指令包含所有的 .dep 依赖文件，
#    当 .dep 依赖文件不存在时，使用规则自动生成

# make对include关键字的处理方式：在当前目录搜索或指定目录搜索目标文件
# 	搜索成功：将文件里面的内容搬入当前makefile中
# 	搜索失败：产生警告 （前面加 - 去掉警告，-不仅关闭了include的警告，同时关闭了错误,当错误发生时mka将忽略这些错误）
#		以文件名作为目标查找并执行对应规则
#		当文件名对应的规则不存在在时，最终产生错误

# make 中include的暗黑操作：
# 如果include 包含的文件存在时，除了将文件内容搬到makefile对应位置
# 还会去对比makefile中以这个文件名的目标与其依赖的时间戳，若依赖时间比目标新，那么这个目标的规则将会被触发执行

# 自动生成依赖关系
# 包含模块的.dep文件中的内容到这里来，若没有这个文件，就触发.dep目的创建出这个依赖文件
-include $(DEPS)

all : $(OUTPUT)
	@echo "Success! Target ==> $(OUTPUT)"

# 用目标文件.o文件打包生成静态库文件.a文件	
$(OUTPUT) : $(OBJS)
	$(AR) $(ARFLAGS) $@ $^

# 源码文件编译出目标文件，再在这些目标文件前加上前缀 $(DIR_OUTPUT)
$(DIR_OUTPUT)/%$(TYPE_OBJ) : %$(TYPE_SRC)
	$(CC) $(CFLAGS) -o $@ -c $(filter %$(TYPE_SRC), $^)

# 3个自动：
# 	通过命令自动生成对头文件的依赖
# 	将生成的依赖自动包含进makefile中
# 	当头文件改动后，自动确认需要重新编译的文件

# 自动生成依赖关系的规则：	
# gcc的-M和-MM会列出一个源文件对其他文件的依赖关系，所不同的是-MM不会列出对于系统头文件的依赖关系
# gcc -E，这个命令告诉gcc只做预处理，而不进行程序编译，在生成依赖关系时，我们不需要编译只需预处理即可
# filter %$(TYPE_SRC) 只作用与源码文件 
# sed用正则表达式匹配替换目标，使用匹配的目标生成替换结果
#     ,分割符， 匹配.o(前有路径符合/，后有空格或者冒号的匹配上) 替换为 前面加上 obj/ 后面加上冒号: 再空格 还$@加上依赖文件名
# $@ 将依赖文件也直接作为目标，排除只更新头文件时make感知不到项目有变化的bug
# 我们为每一个源文件通过采用gcc和sed生成一个依赖关系文件，这些文件采用.dep后缀结尾
$(DIR_OUTPUT)/%$(TYPE_DEP) : %$(TYPE_SRC)
	@echo "Creating $@ ..."
	@set -e; \
	$(CC) $(CFLAGS) -MM -E $(filter %$(TYPE_SRC), $^)  | sed 's,\(.*\)\.o[ :]*,$(DIR_OUTPUT)/\1$(TYPE_OBJ) $@ : ,g' > $@
