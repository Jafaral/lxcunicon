#!/bin/bash

echo ""
echo "#####################################################"
echo "Setup LXC Environemt  luxify 0.2 - Jafar Al-Gharaibeh"
echo "Modified: 9/28/2016"
echo "GPLv2"
echo "#####################################################"
echo ""

# uncomment this line to DEBUG
#set -x

echo Current User  : $USER
echo Home Directory: $HOME

###### create directories and setup configuration
LXCCONFDIR=$HOME/.config/lxc
LXCCDIR=$HOME/.local/share
mkdir -p $LXCCONFDIR
mkdir -p $LXCCDIR
chmod +x $HOME/.local
chmod +x $LXCCDIR

echo "LXC config dir: $LXCCONFDIR"
echo "LXC run dir   : $LXCCDIR" 

IFACE=eth0
BRDGNAME=lxcbr0
LXCHOSTNAME=guest
IFACEFILE=/etc/network/interfaces
LXCONFD=$LXCCONFDIR/default.conf

### Install all necessary packages
corpkgs="build-essential lxc lxc-dev lxc-templates bridge-utils lxctl systemd-services uidmap debootstrap libcap2-bin"
#optpkgs="emacs-nox htop ruby ruby-dev"
pkgs="$corpkgs $optpkgs"
echo ""
echo "Making sure we have all of the packages, install if missing"
#sudo apt-get update
for i in $pkgs
do
    dpkg -l $i >& /dev/null
    if [ $? = 1 ]; then
	echo
	echo "###############################"
	echo installing $i
	sudo apt-get install --yes  $i
	echo
	echo +++ done installing $i
	echo
    fi
done

#echo Get chef-lxc
#sudo gem install ruby-lxc
#sudo gem install chef-lxc

echo ""
echo "Done with software checking, moving on to Configuration..."
echo ""
echo "Making sure /etc/subuid has $USER"

grep $USER /etc/subuid
if [ "$?" -ne "0" ]; then
    echo "set subuid and subgid /etc/subuid and /etc/subgid"
    cat - <<EOF | sudo tee /etc/subuid
$USER:100000:65536
root:165536:65536
lxd:231072:65536
EOF

    # subgid has identical content
    sudo cp /etc/subuid /etc/subgid
fi

echo "lxc default config file: $LXCONFD"
cat - <<EOF | tee  $LXCONFD
lxc.network.type = veth
lxc.network.link = $BRDGNAME
lxc.network.flags = up
lxc.network.name = eth0
lxc.network.hwaddr = 00:16:3e:xx:xx:xx
lxc.id_map = u 0 100000 65536
lxc.id_map = g 0 100000 65536
EOF

sudo cp $LXCONFD /etc/lxc/default.conf

echo "make sure the user can add virtual interfaces"
grep $USER /etc/lxc/lxc-usernet
if [ "$?" -ne "0" ]; then
    cat <<EOF | sudo tee -a /etc/lxc/lxc-usernet
# USERNAME TYPE BRIDGE COUNT
$USER veth $BRDGNAME 50
EOF

fi

echo "Making sure we a network bridge set up..."
grep "auto $BRDGNAME" $IFACEFILE
if [ "$?" -ne "0" ]; then
    echo "No bridge found..."
    read -p "Please enter the network device to be bridged [$IFACE]: " device
    device=${device:-$IFACE}
    cat - <<EOF | sudo tee -a $IFACEFILE
# LXC-Config
auto $BRDGNAME
iface $BRDGNAME inet static
	address 10.200.0.2
	netmask 255.255.255.0
	bridge_ports $device
	bridge_stp off
	bridge_maxwait 5
	post-up /usr/sbin/brctl setfd $BRDGNAME 0
EOF

#   sudo /etc/init.d/networking restart
fi

#echo Get chef-lxc
#sudo gem install ruby-lxc
#sudo gem install chef-lxc

