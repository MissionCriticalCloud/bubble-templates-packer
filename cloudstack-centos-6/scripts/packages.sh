#!/bin/bash

set -x

yum install -y cloud-init

# CloudStack 4.4.4
wget https://github.com/schubergphilis/cloudstack/releases/download/cloudstack-4.4.4-20170414/cloudstack-awsapi-4.4.4-1.el6.x86_64.rpm
wget https://github.com/schubergphilis/cloudstack/releases/download/cloudstack-4.4.4-20170414/cloudstack-common-4.4.4-1.el6.x86_64.rpm
wget https://github.com/schubergphilis/cloudstack/releases/download/cloudstack-4.4.4-20170414/cloudstack-management-4.4.4-1.el6.x86_64.rpm
yum -y localinstall cloudstack-*

# VHD-util dependency for XenServer and CloudStack 4.4.4
# This binary does NOT work on CentOS6, it is supposed to be copied to 32bit XenServer where it will work
mkdir -p /usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver/
cd /usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver/
wget http://download.cloud.com.s3.amazonaws.com/tools/vhd-util
chmod 755 vhd-util

