#!/bin/sh

# 路径配置
PWD=`pwd`
BIN_PATH=$PWD/bin

# 引入
source $BIN_PATH'/func.sh'
source $BIN_PATH'/extend.sh'

install_gcc

install_tools

# 获取配置
server_type=`get_config server type`
db_type=`get_config db type`

# 安装server服务器
if [ ! -f $BIN_PATH'/'$server_type'.sh' ];then
    echo $BIN_PATH'/'$server_type'.sh不存在'
    exit 1
fi

sh $BIN_PATH'/'$server_type'.sh'

if [ $? != 0 ];then
    echo $server_type'安装失败'
    exit 1
fi

# 安装php
sh $BIN_PATH'/php.sh'

if [ $? != 0 ];then
    echo 'php安装失败'
    exit 1
fi

# 安装php扩展
sh $BIN_PATH'/php_extension.sh'

if [ $? != 0 ];then
    echo 'php_extension安装失败'
    exit 1
fi

# 安装db服务器
if [ ! -f $BIN_PATH'/'$db_type'.sh' ];then
    echo $BIN_PATH'/'$db_type'.sh不存在'
    exit 1
fi

sh $BIN_PATH'/'$db_type'.sh'

if [ $? != 0 ];then
    echo $db_type'安装失败'
    exit 1
fi




