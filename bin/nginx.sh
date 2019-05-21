#!/bin/sh

# 路径配置
PWD=`pwd`
BIN_PATH=$PWD/bin
FILES_PATH=$PWD/files

# 引入
source $BIN_PATH'/func.sh'
source $BIN_PATH'/extend.sh'

install_nginx

# 获取配置
thread=`get_config core thread`
package=`get_config server nginx_package`

# 安装文件夹
file_name=`get_path_name $package`
path_dir='/usr/local/'`get_file_dir $file_name`

if [ -d $path_dir ];then
    exit 0
fi


# 安装nginx
# 下载地址
package=`exists_download $package`
# 解压文件
decompression $package
file_dir=`get_file_dir $package`
cd $file_dir

./configure --prefix=$path_dir --with-openssl=/usr/include/openssl --with-pcre --with-http_stub_status_module

make -j$thread && make install

error=$?
if [ $error == 0 ];then
    # 配置文件
    if [ ! -f $path_dir'/conf/nginx.conf.bak' ];then
        cp $path_dir'/conf/nginx.conf' $path_dir'/conf/nginx.conf.bak'
    fi
    if [ ! -d $path_dir'/conf/vhost' ];then
        mkdir -p $path_dir'/conf/vhost'
    fi
    \cp $FILES_PATH'/nginx.conf' $path_dir'/conf/nginx.conf'
    \cp $FILES_PATH'/enable-php.conf' $path_dir'/conf/enable-php.conf'
    \cp $FILES_PATH'/rewrite.conf' $path_dir'/conf/rewrite.conf'
    \cp $FILES_PATH'/default.conf' $path_dir'/conf/vhost/default.conf'
    update_file $path_dir'/conf/nginx.conf' 'pid        /usr/local/nginx/logs/nginx.pid;' 'pid        '$path_dir'/logs/nginx.pid;'
    if [ ! -d '/var/www/html' ];then
        mkdir -p '/var/www/html'
    fi
    if [ ! -d '/var/www/logs' ];then
        mkdir -p '/var/www/logs'
    fi
    echo -e 'Is Work!' > '/var/www/html/index.html'
    if [ `cat /etc/group|grep 'www:'|wc -l` == 0 ];then
        groupadd www
    fi
    if [ `cat /etc/passwd|grep 'www:'|wc -l` == 0 ];then
        useradd -s /sbin/nologin -g www -M www
    fi
else
    exit $error
fi
