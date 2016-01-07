#MYSQL数据库帐号密码
MYSQL_USR="root"  # 数据库帐号
MYSQL_PWD="******"  # 数据库密码

#定义需要备份的目录
NGINX_CONF_DIR=/usr/local/nginx/conf  # nginx配置目录
WEB_DIR=/data/wwwroot  # 网站数据存放目录
GIT_DIR=/home/git  # gogs目录

#定义备份存放目录
DROPBOX_DIR=/$(date +%Y-%m-%d)  # Dropbox上的备份目录
LOCAL_BAK_DIR=/data/backup  # 本地备份文件存放目录

#定义备份文件名称
DBBakName=DB_$(date +%Y%m%d).tar.gz
NginxConfBakName=NginxConf_$(date +%Y%m%d).tar.gz
WebBakName=Web_$(date +%Y%m%d).tar.gz
GitBakName=Git_$(date +%Y%m%d).tar.gz

#定义旧数据名称
Old_DROPBOX_DIR=/$(date -d -2day +%Y-%m-%d)
OldDBBakName=DB_$(date -d -10day +%Y%m%d).tar.gz
OldNginxConfBakName=NginxConf_$(date -d -10day +%Y%m%d).tar.gz
OldWebBakName=Web_$(date -d -10day +%Y%m%d).tar.gz
OldGitBakName=Git_$(date -d -10day +%Y%m%d).tar.gz

cd $LOCAL_BAK_DIR

#使用命令导出SQL数据库,并且按数据库分个压缩
for db in `mysql -u$MYSQL_USR -p$MYSQL_PWD -B -N -e 'SHOW DATABASES' | xargs`; do
    (/usr/local/mysql/bin/mysqldump -u$MYSQL_USR -p$MYSQL_PWD ${db} | gzip -9 - > ${db}.sql.gz)
done

#压缩数据库文件合并为一个压缩文件
tar zcf $LOCAL_BAK_DIR/$DBBakName $LOCAL_BAK_DIR/*.sql.gz
rm -rf $LOCAL_BAK_DIR/*.sql.gz

#压缩Nginx配置数据
cd $NGINX_CONF_DIR
tar zcf $LOCAL_BAK_DIR/$NginxConfBakName ./*

#压缩网站数据
cd $WEB_DIR
tar zcf $LOCAL_BAK_DIR/$WebBakName ./*

#压缩Git数据
cd $GIT_DIR
tar zcf $LOCAL_BAK_DIR/$GitBakName ./*

cd /root/bin
#开始上传
./dropbox_uploader.sh upload $LOCAL_BAK_DIR/$DBBakName $DROPBOX_DIR/$DBBakName
./dropbox_uploader.sh upload $LOCAL_BAK_DIR/$NginxConfBakName $DROPBOX_DIR/$NginxConfBakName
./dropbox_uploader.sh upload $LOCAL_BAK_DIR/$WebBakName $DROPBOX_DIR/$WebBakName

#删除旧数据
rm -rf $LOCAL_BAK_DIR/$OldDBBakName $LOCAL_BAK_DIR/$OldNginxConfBakName $LOCAL_BAK_DIR/$OldWebBakName
./dropbox_uploader.sh delete $Old_DROPBOX_DIR/

echo -e "Backup Done!"
