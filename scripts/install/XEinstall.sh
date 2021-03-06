#!/bin/bash

#execute as root!
unzip /u01/download/oracle-xe-11.2.0-1.0.x86_64.rpm.zip -d /u01/download > /u01/logs/XEsilentinstall.log
rpm -ivh /u01/download/Disk1/oracle-xe-11.2.0-1.0.x86_64.rpm >> /u01/logs/XEsilentinstall.log
/etc/init.d/oracle-xe configure < /u01/git/oracle/scripts/install/OracleXESilentInst.iss >> /u01/logs/XEsilentinstall.log

echo 'export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe' >>/home/oracle/.bashrc
echo 'export ORACLE_SID=XE' >>/home/oracle/.bashrc
echo 'export PATH=$ORACLE_HOME/bin:$PATH' >>/home/oracle/.bashrc
echo 'export PATH=$ORACLE_HOME/bin:$PATH' >>/home/oracle/.bashrc
echo "alias sqlplus='rlwrap sqlplus'" >>/home/oracle/.bashrc

chown oracle:oinstall /home/oracle/.bashrc
