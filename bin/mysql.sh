#!/bin/sh

# 路径配置
PWD=`pwd`
BIN_PATH=$PWD/bin

# 引入
source $BIN_PATH'/func.sh'
source $BIN_PATH'/extend.sh'

install_mysql

# 获取配置
thread=`get_config core thread`
package=`get_config db package`

# 安装文件夹
file_name=`get_path_name $package`
path_dir='/usr/local/'`get_file_dir $file_name`

if [ -d $path_dir ];then
    exit 0
fi


# 安装mysql
# 下载地址
package=`exists_download $package`
# 解压文件
decompression $package
file_dir=`get_file_dir $package`
cd $file_dir

cmake -DCMAKE_INSTALL_PREFIX=$path_dir -DMYSQL_DATADIR=$path_dir'/data' -DSYSCONFIGDIR=$path_dir'/etc' -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DMYSQL_UNIX_ADDR=/tmp/mysqld.sock -DMYSQL_TCP_PORT=3306 -DENABLED_LOCAL_INFILE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DMYSQL_USER=mysql

make -j$thread && make install
error=$?
if [ $error == 0 ];then
    cp $path_dir/support-files/my-huge.cnf /etc/my.cnf
    # 去掉innodb注释
    update_file '/etc/my.cnf' '#innodb_data_home_dir' 'innodb_data_home_dir = '$path_dir'/data'
    update_file '/etc/my.cnf' '#innodb_data_file_path' 'innodb_data_file_path = ibdata1:2000M;ibdata2:10M:autoextend'
    update_file '/etc/my.cnf' '#innodb_log_group_home_dir' 'innodb_log_group_home_dir = '$path_dir'/data'
    update_file '/etc/my.cnf' '#innodb_buffer_pool_size' 'innodb_buffer_pool_size = 384M'
    update_file '/etc/my.cnf' '#innodb_additional_mem_pool_size' 'innodb_additional_mem_pool_size = 20M'
    update_file '/etc/my.cnf' '#innodb_log_file_size' 'innodb_log_file_size = 100M'
    update_file '/etc/my.cnf' '#innodb_log_buffer_size' 'innodb_log_buffer_size = 8M'
    update_file '/etc/my.cnf' '#innodb_flush_log_at_trx_commit' 'innodb_flush_log_at_trx_commit = 1'
    update_file '/etc/my.cnf' '#innodb_lock_wait_timeout' 'innodb_lock_wait_timeout = 50'
    if [ ! -f '/etc/init.d/mysqld' ];then
        cp $path_dir'/support-files/mysql.server' '/etc/init.d/mysqld'
    fi
    if [ `cat /etc/group|grep 'mysql:'|wc -l` == 0 ];then
        groupadd mysql
    fi
    if [ `cat /etc/passwd|grep 'mysql:'|wc -l` == 0 ];then
        useradd -s /sbin/nologin -g mysql -M mysql
    fi
    chown -R mysql:mysql $path_dir
    $path_dir/scripts/mysql_install_db --user=mysql --basedir=$path_dir --datadir=$path_dir'/data' >> $path_dir'/install.log' 2>&1 &
    
    append_file '/etc/profile' 'export PATH='$path_dir'/bin:$PATH'
    source '/etc/profile'
else
    exit $error
fi