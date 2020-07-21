install
lang en_US.UTF-8
keyboard us
timezone UTC
firewall --disable
firstboot --disable
selinux --permissive
network --bootproto=dhcp --onboot=on
auth --enableshadow --passalgo=sha512
text
skipx
reboot
url --mirrorlist="http://mirrorlist.centos.org/?release=8&arch=x86_64&repo=BaseOS"
repo --name=AppStream --mirrorlist="http://mirrorlist.centos.org/?release=8&arch=x86_64&repo=AppStream"
logging --level=info

# set passwd
rootpw password

# partition code
zerombr
clearpart --all --initlabel
part / --fstype="ext4" --size=1 --asprimary --grow
bootloader --location=mbr --append="crashkernel=auto rhgb quiet console=ttyS0,115200 net.ifnames=0"

# packages
%packages
@virtualization-host-environment
@development
@rpm-development-tools

acpid
bind-utils
genisoimage
genisoimage
git
java-1.8.0-openjdk-devel
mariadb
mariadb-server
maven
nc
network-scripts
NetworkManager-ovs
perl
policycoreutils
python2
python2-devel
python2-PyMySQL
python2-setuptools
python3
python3-devel
python3-libvirt
python3-PyMySQL
python3-setuptools
setroubleshoot
socat
vim-enhanced
virt-manager
virt-top

%end #%packages

%post --log=/root/ks-post-install.log

update-crypto-policies --set LEGACY
yum -y upgrade
systemctl enable network.service

# Set eth0 to recover from dhcp errors
echo PERSISTENT_DHCLIENT="1" >> /etc/sysconfig/network-scripts/ifcfg-eth0

# No zeroconf
echo NOZEROCONF=yes >> /etc/sysconfig/network
echo NETWORKING=yes >> /etc/sysconfig/network

# Don't let cloud-init handle networking
mkdir -p /etc/cloud/cloud.cfg.d
echo "network: {config: disabled}" > /etc/cloud/cloud.cfg.d/10-disable-network-config.cfg

# Remove existing SSH keys - if generated - as they need to be unique
rm -rf /etc/ssh/*key*

# the MAC address will change
sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-eth0 
rm -f /var/lib/random-seed

# Harden sshd, permit root login
cat <<'EOF' >/etc/ssh/sshd_config
Protocol 2
SyslogFacility AUTHPRIV
#PermitRootLogin no
PermitRootLogin yes
#PasswordAuthentication no
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
GSSAPIAuthentication yes
GSSAPICleanupCredentials yes
UsePAM yes
X11Forwarding no
X11DisplayOffset 10
Subsystem sftp /usr/libexec/openssh/sftp-server

EOF

cat <<'EOF' >/etc/ssh/ssh_config
Host *
  ForwardAgent yes
  ForwardX11 yes
  GSSAPIAuthentication yes
  ForwardX11Trusted yes

EOF

%end #%post

