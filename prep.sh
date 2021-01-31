#!/bin/bash

# Install needed things
apt update
apt install -y lsb-release

# APT sources to enable
my_codename=$(lsb_release -cs)
non_free_source_list="/etc/apt/sources.list.d/non-free.list"

if [ -e "${non_free_source_list}" ]; then
    mv "${non_free_source_list}" ".#${non_free_source_list}.BAK"
fi

echo "deb http://deb.debian.org/debian ${my_codename} non-free"                       | sudo tee -a "${non_free_source_list}"
echo "deb-src http://deb.debian.org/debian buster non-free"                           | sudo tee -a "${non_free_source_list}"
echo ""                                                                               | sudo tee -a "${non_free_source_list}"
echo "deb http://deb.debian.org/debian-security/ ${my_codename}/updates non-free"     | sudo tee -a "${non_free_source_list}"
echo "deb-src http://deb.debian.org/debian-security/ ${my_codename}/updates non-free" | sudo tee -a "${non_free_source_list}"
echo ""                                                                               | sudo tee -a "${non_free_source_list}"
echo "deb http://deb.debian.org/debian ${my_codename}-updates non-free"               | sudo tee -a "${non_free_source_list}"
echo "deb-src http://deb.debian.org/debian ${my_codename}-updates non-free"           | sudo tee -a "${non_free_source_list}"
echo ""                                                                               | sudo tee -a "${non_free_source_list}"

apt update
apt install -y coreutils git ntp ntpdate iw make screen curl uuid-runtime hostapd wget rsync ifupdown net-tools jq htop iftop iotop vim bc ethtool bridge-utils wireless-tools firmware-realtek firmware-ralink firmware-iwlwifi 

# Turn off unwanted things
# TODO: disable all wpa supplicant processes
# TODO: disable networkmanager and networking
for i in systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online systemd-resolved network-manager networking wpa_supplicant hostapd ; do
    systemctl stop ${i}
    systemctl disable ${i}
done

# Turn off graphical login and boot
systemctl set-default multi-user
sed -i -e 's|\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)splash\(.*\)$|\1\2|g' /etc/default/grub
update-grub

# uninstall unneeded things
for i in openresolv dhcpcd5 isc-dhcp-client isc-dhcp-common plymouth netplan.io ; do
    apt remove -y ${i}
    apt purge -y ${i}
done

# Delete unneeded things
rm -rf /usr/share/plymouth
rm -rf /etc/dhcp/dhclient-enter-hooks.d/resolved
rm -rf /etc/resolv*



