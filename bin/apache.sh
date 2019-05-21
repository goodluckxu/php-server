#!/bin/sh

# 路径配置
PWD=`pwd`
BIN_PATH=$PWD/bin

# 引入
source $BIN_PATH'/func.sh'
source $BIN_PATH'/extend.sh'

install_apache

# 获取配置
thread=`get_config core thread`
package=`get_config server apache_package`
apr_package=`get_config lib apr_package`
apr_util_package=`get_config lib apr_util_package`
pcre_package=`get_config lib pcre_package`

# 安装文件夹
file_name=`get_path_name $package`
path_dir='/usr/local/'`get_file_dir $file_name`

if [ -d $path_dir ];then
    exit 0
fi


# 安装apr
if [ ! -d '/usr/local/apr' ];then
    # 下载地址
    apr_package=`exists_download $apr_package`
    # 解压文件
    decompression $apr_package
    apr_dir=`get_file_dir $apr_package`
    cd $apr_dir
    ./configure --prefix=/usr/local/apr
    make -j$thread && make install
    if [ $? != 0 ];then
        echo 'apr安装失败'
        exit 1
    fi
fi

# 安装apr-util
if [ ! -d '/usr/local/apr-util' ];then
    # 下载地址
    apr_util_package=`exists_download $apr_util_package`
    # 解压文件
    decompression $apr_util_package
    apr_util_dir=`get_file_dir $apr_util_package`
    cd $apr_util_dir
    ./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
    make -j$thread && make install
    if [ $? != 0 ];then
        echo 'apr-util安装失败'
        exit 1
    fi
fi

# 安装pcre
if [ ! -d '/usr/local/pcre' ];then
    # 下载地址
    pcre_package=`exists_download $pcre_package`
    # 解压文件
    decompression $pcre_package
    pcre_dir=`get_file_dir $pcre_package`
    cd $pcre_dir
    ./configure --prefix=/usr/local/pcre
    make -j$thread && make install
    if [ $? != 0 ];then
        echo 'pcre安装失败'
        exit 1
    fi
fi

# 安装apache
# 下载地址
package=`exists_download $package`
# 解压文件
decompression $package
file_dir=`get_file_dir $package`
cd $file_dir

./configure --prefix=$path_dir --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util --with-pcre=/usr/local/pcre --enable-rewrite --enable-modes-shared=all

make -j$thread && make install

error=$?
if [ $error == 0 ];then
    # 修改配置文件
    update_file $file_dir'/build/rpm/httpd.init' 'httpd=${HTTPD-/usr/sbin/httpd}' 'httpd=${HTTPD-'$path_dir'/bin/httpd}'
    update_file $file_dir'/build/rpm/httpd.init' 'pidfile=${PIDFILE-/var/run/${prog}.pid}' 'pidfile=${PIDFILE-'$path_dir'/logs/${prog}.pid}'
    update_file $file_dir'/build/rpm/httpd.init' 'CONFFILE=/etc/httpd/conf/httpd.conf' '\tCONFFILE='$path_dir'/conf/httpd.conf'
    \cp $file_dir'/build/rpm/httpd.init' '/etc/rc.d/init.d/httpd'
    chmod 755 '/etc/rc.d/init.d/httpd'
    update_file $path_dir'/conf/httpd.conf' '#ServerName www.example.com:80' 'ServerName localhost:80'
    update_file $path_dir'/conf/httpd.conf' '#Include conf/extra/httpd-vhosts.conf' 'Include conf/extra/httpd-vhosts.conf'
    update_file $path_dir'/conf/httpd.conf' '#Include conf/extra/httpd-userdir.conf' 'Include conf/extra/httpd-userdir.conf'
    
    # 修改vhost配置
    if [ ! -f $path_dir'/conf/extra/httpd-vhosts.conf.bak' ];then
        mv $path_dir'/conf/extra/httpd-vhosts.conf' $path_dir'/conf/extra/httpd-vhosts.conf.bak'
    fi
    echo -e '<VirtualHost *:80>\n    DocumentRoot "/var/www/html"\n</VirtualHost>' > $path_dir'/conf/extra/httpd-vhosts.conf'
    if [ ! -d '/var/www/html' ];then
        mkdir -p '/var/www/html'
    fi
    echo -e 'Is Work!' > '/var/www/html/index.html'
    # 增加文件夹访问权限
    if [ ! -f $path_dir'/conf/extra/httpd-userdir.conf.bak' ];then
        mv $path_dir'/conf/extra/httpd-userdir.conf' $path_dir'/conf/extra/httpd-userdir.conf.bak'
    fi
    echo -e '<Directory "/var/www/html">\n    AllowOverride FileInfo AuthConfig Limit Indexes\n    Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec\n    Require method GET POST OPTIONS\n</Directory>' > $path_dir'/conf/extra/httpd-userdir.conf'

    append_file '/etc/profile' 'export PATH='$path_dir'/bin:$PATH'
    source '/etc/profile'
else
    exit $error
fi