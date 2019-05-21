#!/bin/sh

# 路径配置
PWD=`pwd`
BIN_PATH=$PWD/bin

# 引入
source $BIN_PATH'/func.sh'
source $BIN_PATH'/extend.sh'

install_php

# 获取配置
thread=`get_config core thread`
package=`get_config php package`
libmcrypt_package=`get_config lib libmcrypt_package`
server_type=`get_config server type`
apache_package=`get_config server apache_package`
nginx_package=`get_config server nginx_package`


# 安装文件夹
file_name=`get_path_name $package`
path_dir='/usr/local/'`get_file_dir $file_name`

if [ -d $path_dir ];then
    exit 0
fi

# 下载地址
package=`exists_download $package`
libmcrypt_package=`exists_download $libmcrypt_package`

# 安装libmcrypt
if [ ! -d '/usr/local/libmcrypt' ];then
    decompression $libmcrypt_package
    libmcrypt_dir=`get_file_dir $libmcrypt_package`
    cd $libmcrypt_dir
    ./configure --prefix=/usr/local/libmcrypt
    make -j$thread && make install
    if [ $? != 0 ];then
        echo 'libmcrypt安装失败'
        exit 1
    fi
fi


# 安装php
decompression $package
file_dir=`get_file_dir $package`
cd $file_dir

case $server_type in
    apache)
        apache_file_name=`get_path_name $apache_package`
        apache_file_dir=`get_file_dir $apache_file_name`
        apxs_path='/usr/local/'$apache_file_dir'/bin/apxs'
        ./configure --prefix=$path_dir --with-apxs2=$apxs_path --with-config-file-path=$path_dir/etc --enable-soap --with-jpeg-dir --with-freetype-dir --with-png-dir
        make -j$thread && make install
        error=$?
        if [ $error == 0 ];then
            cp $file_dir'/php.ini-development' $path_dir'/etc/php.ini'
            # 为apache添加php支持
            update_file '/usr/local/'$apache_file_dir'/conf/httpd.conf' 'AddType application/x-gzip .gz .tgz' '    AddType application/x-gzip .gz .tgz\n    AddType application/x-httpd-php .php .phtml\n    AddType application/x-httpd-php-source .phps'
            update_file '/usr/local/'$apache_file_dir'/conf/httpd.conf' 'DirectoryIndex index.html' '    DirectoryIndex index.html index.php'
            update_file '/usr/local/'$apache_file_dir'/conf/httpd.conf' 'AllowOverride None' '    AllowOverride All'
            update_file '/usr/local/'$apache_file_dir'/conf/httpd.conf' 'AllowOverride none' '    AllowOverride All'
            if [ ! -d '/var/www/html' ];then
                mkdir -p '/var/www/html'
            fi
            rm -rf '/var/www/html/index.html'
            echo -e '<?php\n    phpinfo();' > '/var/www/html/index.php'
        else
            exit $error
        fi
        ;;
    nginx)
        nginx_file_name=`get_path_name $nginx_package`
        nginx_file_dir=`get_file_dir $nginx_file_name`
        ./configure --prefix=$path_dir --with-config-file-path=$path_dir/etc --enable-fastcgi --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-soap --enable-opcache=no --with-jpeg-dir --with-freetype-dir --with-png-dir
        make -j$thread && make install
        error=$?
        if [ $error == 0 ];then
            cp $path_dir'/etc/php-fpm.conf.default' $path_dir'/etc/php-fpm.conf'
            cp $path_dir'/etc/php-fpm.d/www.conf.default' $path_dir'/etc/php-fpm.d/www.conf'
            cp $file_dir'/php.ini-development' $path_dir'/etc/php.ini'
            cp $file_dir'/sapi/fpm/init.d.php-fpm' '/etc/init.d/php-fpm'
            chmod +x /etc/init.d/php-fpm
            if [ `cat /etc/group|grep 'www:'|wc -l` == 0 ];then
                groupadd www
            fi
            if [ `cat /etc/passwd|grep 'www:'|wc -l` == 0 ];then
                useradd -s /sbin/nologin -g www -M www
            fi
            # 为nginx添加php支持
            update_file '/usr/local/'$nginx_file_dir'/conf/vhost/default.conf' 'index index.html index.htm;' '    index index.html index.htm index.php;'
            update_file '/usr/local/'$nginx_file_dir'/conf/vhost/default.conf' '# include enable-php.conf;' '    include enable-php.conf;'
            update_file '/usr/local/'$nginx_file_dir'/conf/vhost/default.conf' '# include rewrite.conf;' '    include rewrite.conf;'
            rm -rf '/var/www/html/index.html'
            echo -e '<?php\n    phpinfo();' > '/var/www/html/index.php'
        else
            exit $error
        fi
        ;;
esac