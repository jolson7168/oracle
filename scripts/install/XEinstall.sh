#!/bin/bash

#execute as root
unzip /u01/download/oracle-xe-11.2.0-1.0.x86_64.rpm.zip
rpm -ivh /u01/download/Disk1/oracle-xe-11.2.0-1.0.x86_64.rpm > /u01/logs/XEsilentinstall.log
/etc/init.d/oracle-xe configure < /OracleXESilentInst.iss >> /u01/logs/XEsilentinstall.log
