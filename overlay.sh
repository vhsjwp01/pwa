#!/bin/bash
set -x

PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin"
TERM="vt100"
export TERM PATH

# VARIABLE REPLACEMENT

# This get executed as-is ... no replacement needed
./overlay/etc/rc.local

# These are templates ... no replacement needed
./overlay/etc/default/hostapd-systemd.template
./overlay/etc/default/hostapd.template

# Needs to be replaced with values
./overlay/etc/default/wifi_ap_config:bridge_ifname="::BRIDGE_IFNAME::"
./overlay/etc/default/wifi_ap_config:bridge_ip="::BRIDGE_IP::"
./overlay/etc/default/wifi_ap_config:bridge_gateway="::BRIDGE_GATEWAY::"
./overlay/etc/default/wifi_ap_config:bridge_subnet="::BRIDGE_SUBNET::"

# Needs to be replaced with values
./overlay/etc/mac_allow_list/mac_allow_list.conf:db="::MAC_ALLOW_DB::"
./overlay/etc/mac_allow_list/mac_allow_list.conf:db_host="::DB_HOST::"
./overlay/etc/mac_allow_list/mac_allow_list.conf:db_port="::DB_PORT::"
./overlay/etc/mac_allow_list/mac_allow_list.conf:db_user="::DB_USER::"
./overlay/etc/mac_allow_list/mac_allow_list.conf:db_password="::DB_PASSWORD::"
