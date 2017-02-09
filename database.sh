#!/bin/bash
 
EXPECTED_ARGS=4
E_BADARGS=65
MYSQL=`which mysql`

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: $0 dbname dbuser dbpass service [drop/create]"
  exit $E_BADARGS
fi

if [ "$5" == "drop" ]
then
	Q1="drop database if exists $1;"
	Q2="drop user $2@localhost;"
	Q3="flush privileges;"
fi
if [ "$5" == "create" ]
then
	Q1="create database if not exists $1 default character set utf8;"
	Q2="grant all on $1.* to $2@'localhost' identified by '$3';"
	Q3="flush privileges;"
fi
SQL="${Q1}${Q2}${Q3}"
 
# Monday 1
NOW=$(date +"%u")
if [ "$NOW" == "1" ]
then
  echo "DataBase $1 $5"
  if [ "$4" == "drop" ]
  then
  	rm -rf /www/$4/tomcat/sakai/*
  fi
  $MYSQL --defaults-extra-file=/home/sakai/.my.cnf -e "$SQL"
fi
