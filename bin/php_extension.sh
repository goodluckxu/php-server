#!/bin/sh

# 路径配置
PWD=`pwd`
BIN_PATH=$PWD/bin

# 引入
source $BIN_PATH'/func.sh'
source $BIN_PATH'/extend.sh'

# 获取配置
php_extension=`get_config php php_extension`

# 安装扩展
extension_arr=(${php_extension//,/ })
for extension in ${extension_arr[@]};do
    sh $BIN_PATH'/install_extension.sh' $extension
    if [ $? != 0 ];then
        echo $extension'的php扩展安装失败'
        exit 1
    fi
done