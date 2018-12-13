# 本项目的组织架构配置

# 项目包含的子模块
# 每个模块的对外函数声明(.h头文件)统一放置于 common/inc 中
MODULES := common \
           module \
           main

# 子模块的配置
MOD_CFG := mod-cfg.mk
MOD_RULE := mod-rule.mk
CMD_CFG := cmd-cfg.mk

# 存储编译后的文件所存放的文件夹，目的不污染源码路径
DIR_BUILD := build
# 存放公共模块对外开放的头文件的
DIR_COMMON_INC := common/inc
# 第三方库对外开放的头文件，编译时需要用到
DIR_LIBS_INC := libs/inc
# 第三方库的库文件(静态库/动态库)，链接时会用到
DIR_LIBS_LIB := libs/lib

# 最终可执行文件的名称
APP := app.out
