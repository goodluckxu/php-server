#!/bin/sh

function install_gcc() {
    if [ `rpm -qa|grep gcc|wc -l` == 0 ];then
        yum -y install gcc
    fi
    if [ `rpm -qa|grep gcc-c++|wc -l` == 0 ];then
        yum -y install gcc-c++
    fi
}

function install_apache() {
    if [ `rpm -qa|grep expat-devel|wc -l` == 0 ];then
        yum -y install expat-devel
    fi
}

function install_nginx() {
    if [ `rpm -qa|grep zlib-devel|wc -l` == 0 ];then
        yum -y install zlib-devel
    fi
    if [ `rpm -qa|grep pcre-devel|wc -l` == 0 ];then
        yum -y install pcre-devel
    fi
    if [ `rpm -qa|grep openssl-devel|wc -l` == 0 ];then
        yum -y install openssl-devel
    fi
}

function install_mysql() {
    if [ `rpm -qa|grep cmake|wc -l` == 0 ];then
        yum -y install cmake
    fi
    if [ `rpm -qa|grep ncurses-devel|wc -l` == 0 ];then
        yum -y install ncurses-devel
    fi
}

function install_php() {
    if [ `rpm -qa|grep libxml2-devel|wc -l` == 0 ];then
        yum -y install libxml2-devel
    fi
    if [ `rpm -qa|grep libjpeg-turbo-devel|wc -l` == 0 ];then
        yum -y install libjpeg-turbo-devel
    fi
    if [ `rpm -qa|grep libpng-devel|wc -l` == 0 ];then
        yum -y install libpng-devel
    fi
    if [ `rpm -qa|grep freetype-devel|wc -l` == 0 ];then
        yum -y install freetype-devel
    fi
}

# 扩展需要的函数
function install_extension() {
    if [ `rpm -qa|grep autoconf|wc -l` == 0 ];then
        yum -y install autoconf
    fi
    if [ 'a'$1 == 'a' ];then
        echo $1'扩展不能传空'
        exit 1
    fi
    case $1 in
        pdo_pgsql|pgsql)
            if [ `rpm -qa|grep postgresql-devel|wc -l` == 0 ];then
                yum -y install postgresql-devel
            fi
            ;;
        mysqli)
            if [ `rpm -qa|grep mysql-devel|wc -l` == 0 ];then
                yum -y install mysql-devel
            fi
            ;;
        snmp)
            if [ `rpm -qa|grep net-snmp-devel|wc -l` == 0 ];then
                yum -y install net-snmp-devel
            fi
            ;;
        amqp)
            if [ `rpm -qa|grep librabbitmq-devel|wc -l` == 0 ];then
                yum -y install librabbitmq-devel
            fi
            ;;
        *)
            grep_file=$1'-devel'
            if [ `echo $1|grep pdo_|wc -l` != 0 ];then
                grep_file=`echo $1|awk -F 'pdo_' '{print $2}'`'-devel'
            fi
            if [ `rpm -qa|grep "$grep_file"|wc -l` == 0 ];then
                yum -y install $grep_file
            fi
            ;;
    esac
}