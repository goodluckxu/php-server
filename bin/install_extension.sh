#!/bin/sh

# 路径配置
PWD=`pwd`
BIN_PATH=$PWD/bin

# 引入
source $BIN_PATH'/func.sh'
source $BIN_PATH'/extend.sh'

# 获取配置
thread=`get_config core thread`
php_package=`get_config php package`
php_extension=`get_config php php_extension`

# 安装扩展
php_file_name=`get_path_name $php_package`
php_file_dir=`get_file_dir $php_file_name`
php='/usr/local/'$php_file_dir'/bin/php'
phpize='/usr/local/'$php_file_dir'/bin/phpize'
php_config='/usr/local/'$php_file_dir'/bin/php-config'
php_ini='/usr/local/'$php_file_dir'/etc/php.ini'
pecl='/usr/local/'$php_file_dir'/bin/pecl'

if [ 'a'$1 == 'a' ];then
    echo '传入扩展为空'
    exit 1
fi

extension=$1
case $extension in
    mcrypt)
        libmcrypt_package=`get_config lib libmcrypt_package`
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
        ;;
esac


if [ `$php -m|grep $extension|wc -l` == 0 ];then
    ext_dir=$PWD'/package/'$php_file_dir'/ext'
    extension_dir=$ext_dir'/'$extension
    install_extension $extension
    if [ ! -d $extension_dir ];then
        $pecl install $extension
        pecl_error=$?
        if [ $pecl_error != 0 ] && [ $pecl_error != 1 ];then
            echo $extension'扩展不存在'
            exit 1
        fi
    else
        # so文件存在则删除重新编译
        dir_extension=`find '/usr/local/'$php_file_dir'/lib/php' -name $extension'.so'`
        if [ 'a'$dir_extension != 'a' ];then
            rm -rf $dir_extension
        fi
        cd $extension_dir
        if [ -f $extension_dir'/config0.m4' ] && [ ! -f $extension_dir'/config.m4' ];then
            cp $extension_dir'/config0.m4' $extension_dir'/config.m4'
        fi
        $phpize
        case $extension in
            pdo_mysql)
                ./configure --with-php-config=$php_config --with-pdo-mysql=/usr
                ;;
            mysqli)
                if [ ! -d $extension_dir'/ext/mysqlnd' ];then
                    mkdir -p $extension_dir'/ext/mysqlnd'
                fi
                if [ ! -f $extension_dir'/ext/mysqlnd/mysql_float_to_double.h' ];then
                    cp -R $ext_dir'/mysqlnd/mysql_float_to_double.h' $extension_dir'/ext/mysqlnd/mysql_float_to_double.h'
                fi
                ./configure --with-php-config=$php_config --with-mysqli=/usr/bin/mysql_config
                ;;
            mcrypt)
                ./configure --with-php-config=$php_config --with-mcrypt=/usr/local/libmcrypt
                ;;
            *)
                ./configure --with-php-config=$php_config
                ;;
        esac
        make -j$thread && make install
        if [ $? != 0 ];then
            exit 1
        fi
    fi
    # 配置文件是否配置
    file_extension_num=`cat $php_ini|grep $extension'.so'|wc -l`
    dir_extension_num=`find '/usr/local/'$php_file_dir'/lib/php' -name $extension'.so'|wc -l`
    if [ $file_extension_num == 0 ] && [ $dir_extension_num != 0 ];then
        echo 'extension='$extension'.so' >> $php_ini
    fi
fi