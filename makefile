# 编译得到的结果全部都在当前项目的 build 文件夹下，make会动态创建出 build 文件夹
# 在 build/ 下会编译链接生成各个模块的静态库的 $(MODULES).a 文件
# 将 libs/lib下的第三方库全部复制一份到build/下、以及由各个模块和第三方库链接成的 一个总的静态库 .a 文件
# 在 build/ 下动态创建以各个模块命名的模块文件夹
# 在 build/$(MODULES) 下会动态创建出 obj 目录
# 主 makefile 

include pro-cfg.mk
include cmd-cfg.mk
include pro-rule.mk
