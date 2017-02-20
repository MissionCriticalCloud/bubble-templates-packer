skipx
install
text

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
bootloader --location=mbr --driveorder=vda

############
# PACKAGES #
############
%packages --excludedocs --nobase
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
vconfig
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

# Remove some packages
yum -C -y remove authconfig NetworkManager linux-firmware --setopt="clean_requirements_on_remove=1"

# Install epel packages
yum --enablerepo=epel -y install sshpass mysql-connector-python

# Install pip
curl "https://bootstrap.pypa.io/get-pip.py" | python

# set eth0 to recover from dhcp errors
echo PERSISTENT_DHCLIENT="1" >> /etc/sysconfig/network-scripts/ifcfg-eth0

# set virtual-guest as default profile for tuned
echo "virtual-guest" > /etc/tune-profiles/active-profile

# no zeroconf
echo NOZEROCONF=yes >> /etc/sysconfig/network
echo NETWORKING=yes >> /etc/sysconfig/network

# remove existing SSH keys - if generated - as they need to be unique
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

cat << EOF > /etc/cloud/cloud.cfg.d/99_cloudstack.cfg
datasource:
  CloudStack: {}
  None: {}
datasource_list:
  - CloudStack
EOF

cat > /etc/cloud/cloud.cfg << "EOF"
users:
 - default

disable_root: 0
ssh_pwauth:   1

locale_configfile: /etc/sysconfig/i18n
mount_default_fields: [~, ~, 'auto', 'defaults,nofail', '0', '2']
resize_rootfs_tmp: /dev
resize_rootfs: noblock
ssh_deletekeys:   0
ssh_genkeytypes:  ~
syslog_fix_perms: ~

cloud_init_modules:
 - migrator
 - bootcmd
 - write-files
 - growpart
 - resizefs
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - rsyslog
 - users-groups
 - ssh

cloud_config_modules:
 - mounts
 - locale
 - set-passwords
 - yum-add-repo
 - package-update-upgrade-install
 - timezone
 - puppet
 - chef
 - salt-minion
 - mcollective
 - disable-ec2-metadata
 - runcmd

cloud_final_modules:
 - rightscale_userdata
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - scripts-user
 - ssh-authkey-fingerprints
 - keys-to-console
 - phone-home
 - final-message

system_info:
  default_user:
    name: root
  distro: rhel
  paths:
    cloud_dir: /var/lib/cloud
    templates_dir: /etc/cloud/templates
  ssh_svcname: sshd

# vim:syntax=yaml
EOF
%end
