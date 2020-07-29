## linux上的lanmp环境的安装(目前只支持centos)
~~~
*注: 
1. centos6.*支持php7.1及以下，centos7.*以上支持全部php
2. 配置的下载地址的地方可将安装包配置到当前目录的package目录下面，配置可只配置文件名。如: nginx_package=nginx-1.15.12.tar.bz2，将nginx-1.15.12.tar.bz2下载到package目录下面
~~~
### 软件开发的配置说明：
~~~
    [server]
    type=nginx
    nginx_package=http://nginx.org/download/nginx-1.15.12.tar.gz
    apache_package=http://www.apache.org/dist/httpd/httpd-2.4.39.tar.bz2
    [db]
    type=mysql
    package=http://mirrors.163.com/mysql/Downloads/MySQL-5.5/mysql-5.5.61.tar.gz
    [php]
    package=https://www.php.net/distributions/php-7.2.18.tar.bz2
    php_extension=openssl,zlib,mbstring,bz2,gd,pdo_pgsql,mcrypt,imagick,redis,amqp
    [lib]
    apr_package=http://www.apache.org/dist/apr/apr-1.7.0.tar.bz2
    apr_util_package=http://www.apache.org/dist/apr/apr-util-1.6.1.tar.bz2
    pcre_package=http://ftp.pcre.org/pub/pcre/pcre-8.43.tar.bz2
    libmcrypt_package=https://sourceforge.mirrorservice.org/m/mc/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
    mcrypt_package=http://pecl.php.net/get/mcrypt-1.0.1.tgz
    [core]
    thread=4
~~~
#### [server]
type配置[apache|nginx]

nginx_package配置nginx的下载地址

apache_package配置apache的下载地址

#### [db]
type配置[mysql]

pakcage配置mysql的下载地址(目前只支持mysql5.5)

#### [php]
pakcage配置php的下载地址

php_extension配置php支持的扩展，某些扩展无法安装可能没安装openssl扩展

#### [lib]
apr_package配置apr的下载地址(apache安装使用)

apr_util_package配置apr-util的下载地址(apache安装使用)

pcre_package配置pcre的下载地址(apache安装使用)

libmcrypt_package配置libmcrypt的下载地址(mcrypt扩展使用)

mcrypt_package配置mcrypt的下载地址(mcrypt扩展使用)

#### [core]
thread配置机器线程数(用于编译提速)


### 配置完毕运行
sh install.sh
