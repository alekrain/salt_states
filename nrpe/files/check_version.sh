#!/bin/bash
# Purpose: Returns the version of the OS that is running
# Version 1.0
#	Verion 1.0 is tested to work with:
#		CentOS, Fedora, Ubuntu, FreeBSD, Solaris


#CentOS
if [[ -f "/etc/centos-release" ]]
then
	version=`cat /etc/centos-release`

#Fedora
elif [[ -f "/etc/fedora-release" ]]
then
	version=`cat /etc/fedora-release`

#RedHat
elif [[	-f "/etc/redhat-release" ]]
then
	version=`cat /etc/redhat-release`

#Ubuntu
elif [[ -f "/etc/lsb-release" ]]
then
	version=`cat /etc/lsb-release | grep DESCRIPTION | sed s/DISTRIB_DESCRIPTION=//`

#FreeBSD 
elif [[ -d "/usr/ports" ]]
then
	version=`uname -rs`

#Solaris
elif [[ -d "/usr/sunos" ]]
then
	version=`uname -rs`
fi


if [[ -z "$version" ]]
then
	version="Operating System Unknown"
fi

echo "$version"
exit 0


