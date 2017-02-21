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
 cp /usr/local/tomcat/conf/catalina.properties /usr/local/tomcat/conf/catalina.orig
 rm -f /usr/local/tomcat/conf/catalina.properties
 sed '/^common.loader=/s@$@,"${catalina.base}/sakai-lib/*.jar"@' /usr/local/tomcat/conf/catalina.orig > /usr/local/tomcat/conf/catalina.beta
 sed '/^tomcat.util.scan.StandardJarScanFilter.jarsToSkip=/s@\\$@xerces-J_1.4.0.jar,jdbc-se2.0.jar,jndi_1.2.1.jar,jta1.0.1.jar,cglib-full-2.0.2.jar,commons-logging.jar,\\@' /usr/local/tomcat/conf/catalina.beta > /usr/local/tomcat/conf/catalina.properties
fi
# Then run tomcat if vars are available, else bash shell
if [[ -n "${DB_NAME}" && -n "${DB_USER}" && -n "${DB_PASS}" ]]; then
 catalina.sh run
else
 echo "Unexpected environment: Set environment properly."
fi
