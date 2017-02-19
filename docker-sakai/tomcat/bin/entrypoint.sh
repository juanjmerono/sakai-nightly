#!/bin/bash
set -e

# This creates a sakai.properties file for sakai based on the envrionment
# Only create a sakai.properties if the values are set.
if [[ -n "${DB_NAME}" && -n "${DB_USER}" && -n "${DB_PASS}" ]]; then
	cat <<EOF  > /usr/local/tomcat/sakai/sakai.properties
auto.ddl=true
vendor@org.sakaiproject.db.api.SqlService=mysql
#driverClassName@javax.sql.BaseDataSource=org.mariadb.jdbc.Driver
hibernate.dialect=org.hibernate.dialect.MySQL5InnoDBDialect
validationQuery@javax.sql.BaseDataSource=select 1 from DUAL
testOnBorrow@javax.sql.BaseDataSource=false
defaultTransactionIsolationString@javax.sql.BaseDataSource=TRANSACTION_READ_COMMITTED
url@javax.sql.BaseDataSource=jdbc:mysql://dbmysql:3306/${DB_NAME}?characterEncoding=UTF-8&useServerPrepStmts=false&cachePrepStmts=true&prepStmtCacheSize=4096&prepStmtCacheSqlLimit=4096
username@javax.sql.BaseDataSource=${DB_USER}
password@javax.sql.BaseDataSource=${DB_PASS}

EOF
fi
# This modify catalina.propertis adding sakai lib folder
if ! grep -q sakai "/usr/local/tomcat/conf/catalina.properties"; then
 sed -i.orig '/^common.loader=/s@$@,"${catalina.base}/sakai-lib/*.jar"@' /usr/local/tomcat/conf/catalina.properties
fi
# Then run tomcat if vars are available, else bash shell
if [[ -n "${DB_NAME}" && -n "${DB_USER}" && -n "${DB_PASS}" ]]; then
 catalina.sh run
else
 bash
fi
