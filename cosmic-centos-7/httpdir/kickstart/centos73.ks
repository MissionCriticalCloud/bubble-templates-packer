skipx
install
text
reboot
lang en_US.UTF-8
keyboard us
timezone --utc GMT

################
# REPOSITORIES #
################
repo --name=os --mirrorlist http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra
repo --name=updates --mirrorlist http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates&infra=$infra
repo --name=extras --mirrorlist http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras&infra=$infra
url --mirrorlist http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra
eula --agreed

######################
# FIREWALL / SELINUX #
######################
firewall --disabled
selinux --enforcing

#################
# ROOT PASSWORD #
#################
rootpw password
authconfig --enableshadow --passalgo=sha512

########
# DHCP #
########
network --onboot yes --device=eth0 --bootproto=dhcp

#############
# PARTITION #
#############
zerombr
clearpart --initlabel --all
part / --size=1024 --grow --fstype ext4 --asprimary
bootloader --location=mbr --driveorder=vda --append="console=ttyS0,115200"

############
# PACKAGES #
############
%packages
-*-firmware
-NetworkManager
-b43-openfwwf
-biosdevname
-firewalld
-fprintd
-fprintd-pam
-gtk2
-iprutils
-kbd
-libfprint
-mcelog
-redhat-support-tool
-system-config-*
-wireless-tools

MySQL-python
acpid
bridge-utils
bzip2
cloud-init
cloud-utils-growpart
dracut-config-generic
ebtables
epel-release
ethtool
gcc
genisoimage
git
iproute
ipset
iptables
iptables-services
jakarta-commons-daemon-jsvc
java-1.8.0-openjdk-devel.x86_64
jsvc
libffi-devel
libvirt
libvirt-python
mariadb
mariadb-server
maven
mkisofs
nc
net-tools
nfs-utils
ntp
openssh-askpass
openssh-clients
openssh-server
openssl
openssl-devel
perl
python
python-devel
python-ecdsa
python-jsonpatch
python-paramiko
python-setuptools
qemu-img
qemu-kvm
rpm-build
rubygems
screen
setroubleshoot
socat
tomcat
tuned
vim
virt-manager
virt-top
wget
ws-commons-util
%end

############
# SERVICES #
############
services --enabled=network,acpid,ntpd,sshd,cloud-init,cloud-init-local,cloud-config,cloud-final,tuned --disabled=kdump

######################
# POST INSTALL SHELL #
######################
%post --erroronfail

# Ensure all packages are up to date
yum -y update
yum -y clean all

# Remove some packages
yum -C -y remove authconfig NetworkManager linux-firmware --setopt="clean_requirements_on_remove=1"

# Install epel packages
yum --enablerepo=epel -y install sshpass mysql-connector-python

# Install pip
curl "https://bootstrap.pypa.io/get-pip.py" | python

# Set eth0 to recover from dhcp errors
echo PERSISTENT_DHCLIENT="1" >> /etc/sysconfig/network-scripts/ifcfg-eth0

# Set virtual-guest as default profile for tuned
echo "virtual-guest" > /etc/tune-profiles/active-profile

# No zeroconf
echo NOZEROCONF=yes >> /etc/sysconfig/network
echo NETWORKING=yes >> /etc/sysconfig/network

# Remove existing SSH keys - if generated - as they need to be unique
rm -rf /etc/ssh/*key*
# the MAC address will change
sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-eth0 
# remove logs and temp files
yum -y clean all
rm -f /var/lib/random-seed

# Grub tuning -> enable tty console
grubby --update-kernel=ALL --args="crashkernel=0@0 video=1024x768 console=ttyS0,115200n8 console=tty0 consoleblank=0"
grubby --update-kernel=ALL --remove-args="quiet rhgb"

%end
