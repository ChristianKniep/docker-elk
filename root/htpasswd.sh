#!/usr/bin/expect 
######################################### 
#$ file: htpasswd.sh 
#$ desc: Automated htpasswd shell script 
######################################### 
#$ 
#$ usage example: 
#$ 
#$ ./htpasswd.sh passwdpath username userpass 
#$ 
###################################### 
#$ SOURCE: http://www.seanodonnell.com/code/?id=21
######################################

set htpasswdpath [lindex $argv 0] 
set username [lindex $argv 1] 
set userpass [lindex $argv 2] 

# spawn the htpasswd command process 
spawn htpasswd -c $htpasswdpath $username 

# Automate the 'New password' Procedure 
expect "New password:" 
send "$userpass\r" 

expect "Re-type new password:" 
send "$userpass\r"
