#!/bin/bash

# Install needed things
apt update
apt install -y lsb-release

# APT sources to enable
my_codename=$(lsb_release -cn)
non_free_source_list="/etc/apt/sources.d/non-free.list"
rm "${non_free_source_list}" > /dev/null 2>&1
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
apt install -y coreutils make screen curl uuidgen hostapd wget rsync ifupdown install net-tools jq htop iftop iotop vim bc ethtool bridge-utils firmware-realtek firmware-ralink firmware-iwlwifi 

# Turn off unwanted things
for i in systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online systemd-resolved ; do
    systemctl stop ${i}
    systemctl disable ${i}
done

# Turn off graphical login and boot
systemctl set-default multi-user
sed -i -e 's|\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)splash\(.*\)$|\1\2|g' /etc/default/grub
update-grub

# uninstall unneeded things
for i in openresolv dhcpcd5 isc-dhcp-client isc-dhcp-common purge plymouth netplan.io ; do
    apt remove ${i}
    apt purge ${i}
done

# Delete unneeded things
rm -rf /usr/share/plymouth
rm -rf /etc/dhcp/dhclient-enter-hooks.d/resolved
rm -rf /etc/resolv*



