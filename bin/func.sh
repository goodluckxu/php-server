#!/bin/sh

# 路径配置
PWD=`pwd`
CONFIG_PATH=$PWD'/config.ini'

# 获取配置文件
# example: get_config server path
function get_config() {
    # 判断是否传入空
    if [ 'a'$1 == 'a' ] || [ 'a'$2 == 'a' ];then
        echo '没有传入配置项'
        exit 1
    fi
    # 获取类型
    cfg_type=`cat $CONFIG_PATH|grep '\['$1'\]'`
    cfg_start=`grep '\['$1'\]' $CONFIG_PATH -n|awk -F ':' '{print $1}'`
    if [ 'a'$cfg_type == 'a' ];then
        echo '配置['$1']不存在'
        exit 1
    fi
    cfg_data=''
    while read line;do
        # 替换特殊字符
        line=${line//\[/\\\[}
        line=${line//\]/\\\]}
        i=`grep $line $CONFIG_PATH -n|awk -F ':' '{print $1}'`
        if [ $i -gt $cfg_start ];then
            if [ 'a'`echo $line|grep '\['|grep '\]'` != 'a' ];then
                break
            fi
            cfg_val=`echo $line|grep $2'='|awk -F '=' '{print $2}'`
            if [ 'a'$cfg_val != 'a' ];then
                cfg_data=$cfg_val
            fi
        fi
    done<$CONFIG_PATH
    
    if [ 'a'$cfg_data == 'a' ];then
        echo '配置['$1']里面项'$2'不存在'
        exit 1
    fi
    echo $cfg_data
}

# 获取路径文件名
# example: get_path_name /root/package/pcre-8.43.tar.bz2
# result: pcre-8.43.tar.bz2
function get_path_name() {
    fun_file_path=$1
    echo ${fun_file_path##*/}
}

# 获取路径文件夹
# example: get_path_dir /root/package/pcre-8.43.tar.bz2
# result: /root/package
function get_path_dir() {
    fun_file_path=$1
    echo ${fun_file_path%/*}
}

# 获取路径文件后缀
# example: get_file_suffix /root/package/pcre-8.43.tar.bz2
# result: tar.bz2
function get_file_suffix() {
    # 获取后缀
    fun_suffix=`echo $1|awk -F '.' '{print $NF}'`
    if [[ $1 =~ '.tar.' ]];then
        fun_suffix=`echo $1|awk -F '.' '{print $(NF-1)}'`'.'`echo $1|awk -F '.' '{print $NF}'`
    fi
    echo $fun_suffix
}

# 获取路径文件的文件夹
# example: get_file_dir /root/package/pcre-8.43.tar.bz2
# result: /root/package/pcre-8.43
function get_file_dir() {
    # 获取后缀
    fun_suffix=`get_file_suffix $1`
    fun_file_dir=`echo $1|awk -F $fun_suffix '{print $1}'`
    echo ${fun_file_dir%*.}
}

# 解压文件
# example: get_file_dir /root/package/pcre-8.43.tar.bz2
function decompression() {
    # 判断是否传入空
    if [ 'a'$1 == 'a' ];then
        echo '没有传入压缩包地址'
        exit 1
    fi
    # 判断文件是否存在
    if [ ! -f $1 ];then
        echo $1'文件不存在'
        exit 1
    fi
    # 删除原解压
    zip_file_dir=`get_file_dir $1`
    rm -rf zip_file_dir
    
    zip_suffix=`get_file_suffix $1`
    zip_path_name=`get_path_name $1`
    zip_path_dir=`get_path_dir $1`
    cd $zip_path_dir
    if [ $zip_suffix == 'tar.bz2' ] || [ $zip_suffix == 'tar.gz' ] || [ $zip_suffix == 'tgz' ];then
        tar xvf $zip_path_name
    elif [ $zip_suffix == 'zip' ];then
        unzip $zip_path_name
    else
        echo $zip_suffix'格式的压缩文件无法解压'
        exit 1
    fi
}

# 存在http且下载
# example: exists_download http://www.baidu.com/a.tar.bz2
# result: /root/abc/package/a.tar.bz2
function exists_download() {
    down_path_name=`get_path_name $1`
    if [ ! -f $PWD'/package/'$down_path_name ];then
        if [ ! -d $PWD'/package' ];then
            mkdir -p $PWD'/package'
        fi
        wget -P $PWD'/package' $1
        if [ $? != 0 ];then
            echo $1'下载失败'
            exit 1
        fi
    fi
    echo $PWD'/package/'$down_path_name
}

# 修改文件
# example: update_file /root/a.txt user_name user_upload
function update_file() {
    update_file_url=$1
    update_find_name=$2
    update_name=$3
    if [ ! -f $update_file_url ];then
        echo $update_file_url'文件不存在'
        exit 1
    fi
    # 文件备份
    if [ ! -f $update_file_url'.bak' ];then
        cp $update_file_url $update_file_url'.bak' 
    fi
    # 临时文件
    mv $update_file_url $update_file_url'.tmp'
    SAVEIFS=$IFS  
    IFS=$(echo -en "\n") 
    while read -r line
    do
        if [ `echo $line|grep "$update_find_name"|wc -l` == 0 ];then
            echo "$line" >> $update_file_url
        else
            echo -e "$update_name" >> $update_file_url
        fi
    done < $update_file_url'.tmp'
    IFS=$SAVEIFS 
    rm -rf $update_file_url'.tmp'
}

# 追加文件
# example: append_file /root/a.txt user_name
function append_file() {
    append_file_url=$1
    append_name=$2
    if [ ! -f $append_file_url ];then
        echo $append_file_url'文件不存在'
        exit 1
    fi
    if [ `cat $append_file_url|grep "$append_name"|wc -l` == 0 ];then
        echo "$append_name" >> $append_file_url
    fi
}
