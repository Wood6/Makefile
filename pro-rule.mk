# 配置了项目，配置了需要的命令，改亮出规则了，总makefile 的规则

# 定义makefile伪目标
.PHONY : all compile link clean rebuild $(MODULES)

# 获取当前项目的路径
DIR_PROJECT := $(realpath .)
# 各个模块名加上前缀 build/ 后的列表，各个模块编译后的结果所存放的文件路径名
DIR_BUILD_SUB := $(addprefix $(DIR_BUILD)/, $(MODULES))
# 各个模块加上后缀 .a 后的列表
MODULE_LIB := $(addsuffix .a, $(MODULES))
# 对上面加上.a后缀的再加个前缀 build/
MODULE_LIB := $(addprefix $(DIR_BUILD)/, $(MODULE_LIB))
# libs/lib 下的所有第三方库文件列表
EXTERNAL_LIB := $(wildcard $(DIR_LIBS_LIB)/*)
# libs/lib 所有匹配的到的库文件加上 build/ 前缀后的列表
EXTERNAL_LIB := $(patsubst $(DIR_LIBS_LIB)/%, $(DIR_BUILD)/%, $(EXTERNAL_LIB))

# 可执行文件加上前缀 build/
APP := $(addprefix $(DIR_BUILD)/, $(APP))

# 自定义函数，进入到对应的模块路径下 make all编译
# make all + 将后面相关的参数在这里给带进模块的makefile中
# 在 build/、common/inc、libs/inc、cmd-cfg.mk、mod-cfg.mk、mode-rule.mk 前加上当前项目的绝对路径/ 
# 将上面这些传递到子模块的makefile中去，并且对子makefiel执行 make all
# 
define makemodule
	cd $(1) && \
	$(MAKE) all \
			DEBUG:=$(DEBUG) \
			DIR_BUILD:=$(addprefix $(DIR_PROJECT)/, $(DIR_BUILD)) \
			DIR_COMMON_INC:=$(addprefix $(DIR_PROJECT)/, $(DIR_COMMON_INC)) \
			DIR_LIBS_INC:=$(addprefix $(DIR_PROJECT)/, $(DIR_LIBS_INC)) \
			CMD_CFG:=$(addprefix $(DIR_PROJECT)/, $(CMD_CFG)) \
			MOD_CFG:=$(addprefix $(DIR_PROJECT)/, $(MOD_CFG)) \
			MOD_RULE:=$(addprefix $(DIR_PROJECT)/, $(MOD_RULE)) && \
	cd .. ; 
endef

# 项目路径下make all / make 执行的目标
all : compile $(APP)
	@echo "Success! Target ==> $(APP)"

# set -e的作用是告诉BASH Shell当生成依赖文件的过程中出现任何错误时，就直接退出，不然还会继续执行下去
# 阶段1：将每个模块中的代码编译为静态库文件(.a文件)
compile : $(DIR_BUILD) $(DIR_BUILD_SUB)
	@echo "Begin to compile ..."
	@set -e; \
	for dir in $(MODULES); \
	do \
		$(call makemodule, $$dir) \
	done
	@echo "Compile Success!"

# 阶段2：将每个模块的静态库文件链接成最终可执行程序
# Xlinker选项是将参数传给链接器，由链接器自动处理库的依赖关系，
# ”-(”和”-)”之间的静态库时，链接器会重复查找这些静态库，所以就解决了静态库依赖的先后顺序问题
# 不过，查man说明，可知这种由链接器自动处理的方式比人工提供了链接顺序的方式效率会低很多
link $(APP) : $(MODULE_LIB) $(EXTERNAL_LIB)
	@echo "Begin to link ..."
	$(CC) -o $(APP) -Xlinker "-(" $^ -Xlinker "-)" $(LFLAGS)
	@echo "Link Success!"

# 将 libs/lib 下的第三方库文件 复制一份到 build/ 下	
$(DIR_BUILD)/% : $(DIR_LIBS_LIB)/%
	$(CP) $^ $@

# build 和 子模块的工作目录: mkdir 创建
$(DIR_BUILD) $(DIR_BUILD_SUB) : 
	$(MKDIR) $@
	
clean : 
	@echo "Begin to clean ..."
	$(RM) $(DIR_BUILD)
	@echo "Clean Success!"
	
rebuild : clean all

# 单独编译模块的命令：譬如 make module 时只编译 module模块
$(MODULES) : $(DIR_BUILD) $(DIR_BUILD)/$(MAKECMDGOALS)
	@echo "Begin to compile $@"
	@set -e; \
	$(call makemodule, $@)
	