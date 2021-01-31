#!/bin/bash
set -x

PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin"
TERM="vt100"
export TERM PATH

# VARIABLE REPLACEMENT
echo

while [ -z "${enable_dns}" ]; do
    read -p "Do you wish to enable DNS (y/n)?: " enable_dns
    enable_dns=$(echo "${enable_dns}" | tr '[A-Z]' '[a-z]' | sed -e 's/[^(y|n)]//g')

    case ${enable_dns} in

        y)
            echo

            while [ -z "${nameserver}" ]; do
                read -p "Enter the IP address of your nameserver: " nameserver
            done

            echo

            while [ -z "${custom_search}" ]; do
                read -p "Do you wish to use a custom search domain (y/n)?: " custom_search
                custom_search=$(echo "${custom_search}" | tr '[A-Z]' '[a-z]' | sed -e 's/[^(y|n)]//g')

                case ${custom_search} in
                
                    y)
                        echo

                        while [ -z "${search}" ]; do
                            read -p "Enter the custom search domain: " search
                        done
                    
                    ;; 

                esac

            done

        ;;

        *)
            nameserver="8.8.8.8"
        ;;

    esac

done


while [ -z "${bridge_ifname}" ]; do
    read -p "Enter the Ethernet Bridge name: " bridge_ifname
done

echo

while [ -z "${bridge_ip}" ]; do
    read -p "Enter the TCP IP address for bridge '${bridge_ifname}': " bridge_ip
done

echo

while [ -z "${bridge_gateway}" ]; do
    read -p "Enter the Gateway IP address for bridge IP '${bridge_ip}': " bridge_gateway
done

echo

while [ -z "${bridge_subnet}" ]; do
    read -p "Enter the Netmask for bridge IP '${bridge_ip}': " bridge_subnet
done

echo

while [ -z "${mobility_domain}" ]; do
    read -p "Enter a 4 digit Mobility Domain for bridge '${bridge_ifname}': " mobility_domain
done

echo

while [ -z "${generate_ft_aes_key}" ]; do
    read -p "Do you have an existing Fast Transition AES Key (y/n)?: " generate_ft_aes_key
    generate_ft_aes_key=$(echo "${generate_ft_aes_key}" | tr '[A-Z]' '[a-z]' | sed -e 's/[^(y|n)]//g')

    case ${generate_ft_aes_key} in

        y)
            echo

            while [ -z "${ft_aes_key}" ]; do
                read -p "Enter your current FT AES key: " ft_aes_key
            done

        ;;

        *)
            ft_aes_key=$(hexdump -n 16 -e '4/4 "%08X" 1 "\n"' /dev/random | tr '[A-Z]' '[a-z]')
        ;;

    esac

done

echo

while [ -z "${enable_mac_allow_db}" ]; do
    read -p "Do you have a MAC allow list database (y/n)?: " enable_mac_allow_db
    enable_mac_allow_db=$(echo "${enable_mac_allow_db}" | tr '[A-Z]' '[a-z]' | sed -e 's/[^(y|n)]//g')

    case ${enable_mac_allow_db} in

        y)
            echo

            while [ -z "${mac_allow_db}" ]; do
                read -p "Enter the MAC allow DB name: " mac_allow_db
            done

            echo

            while [ -z "${db_host}" ]; do
                read -p "Enter the DB Hostname for DB '${mac_allow_db}': " db_host
            done

            echo

            while [ -z "${db_port}" ]; do
                read -p "Enter the Port Number for DB host '${db_host}': " db_port
            done

            echo

            while [ -z "${db_user}" ]; do
                read -p "Enter the Username with grants to DB '${mac_allow_db}': " db_user
            done

            echo

            while [ -z "${db_password}" ]; do
                read -p "Enter the Password for DB username '${db_user}': " db_password
            done

        ;;

    esac

done

# Find all files
this_dir=$(realpath -L $(dirname "${0}"))

if [ -d "${this_dir}/overlay" ]; then
    overlay_files=$(find "${this_dir}/overlay" -depth -type f 2> /dev/null)

    for overlay_file in ${overlay_files} ; do
        copy_command=""
        target_file=$(basename "${overlay_file}")
	target_path=$(dirname "${overlay_file}" | sed -e "s|^${this_dir}/overlay||g")

        if [ ! -e "${target_path}" ]; then
            mkdir -p "${target_path}"
        fi

        # Perform any variable substitution in line
        case ${target_file} in

            resolv.conf)

                if [ "${enable_dns}" = "y" ]; then
                    copy_command="sed -e \"s|::NAMESERVER::|${nameserver}|g\" -e \"s|::SEARCH::|${search}|g\" \"${overlay_file}\" > \"${target_path}/${target_file}\" ; if [ -n \"${search}\" ]; then sed -i -e 's|^#search |search |g' \"${target_path}/${target_file}\" ; fi"
                fi

            ;;

            wifi_ap_config)
                copy_command="sed -e \"s|::BRIDGE_IFNAME::|${bridge_ifname}|g\" -e \"s|::BRIDGE_IP::|${bridge_ip}|g\" -e \"s|::BRIDGE_GATEWAY::|${bridge_gateway}|g\" -e \"s|::BRIDGE_SUBNET::|${bridge_subnet}|g\" -e \"s|::MOBILITY_DOMAIN::|${mobility_domain}|g\" -e \"s|::FT_AES_KEY::|${ft_aes_key}|g\" \"${overlay_file}\" > \"${target_path}/${target_file}\""
            ;;

            macl_allow_list.conf)
                copy_command="sed -e \"s|::MAC_ALLOW_DB::|${mac_allow_db}|g\" -e \"s|::DB_HOST::|${db_host}|g\" -e \"s|::DB_PORT::|${db_port}|g\" -e \"s|::DB_USER::|${db_user}|g\" -e \"s|::DB_PASSWORD::|${db_password}|g\" \"${overlay_file}\" > \"${target_path}/${target_file}\""
            ;;

            *)
                copy_command="cp \"${overlay_file}\" \"${target_path}/${target_file}\""
            ;;

        esac

        if [ -n "${copy_command}" ]; then
            eval "${copy_command}"
        fi

    done

fi

    

## NOTES
#
## This get executed as-is ... no replacement needed
#./overlay/etc/rc.local
#
## These are templates ... no replacement needed
#./overlay/etc/default/hostapd-systemd.template
#./overlay/etc/default/hostapd.template
#
## Needs to be replaced with values
#./overlay/etc/default/wifi_ap_config:bridge_ifname="::BRIDGE_IFNAME::"
#./overlay/etc/default/wifi_ap_config:bridge_ip="::BRIDGE_IP::"
#./overlay/etc/default/wifi_ap_config:bridge_gateway="::BRIDGE_GATEWAY::"
#./overlay/etc/default/wifi_ap_config:bridge_subnet="::BRIDGE_SUBNET::"
#
## Needs to be replaced with values
#./overlay/etc/mac_allow_list/mac_allow_list.conf:db="::MAC_ALLOW_DB::"
#./overlay/etc/mac_allow_list/mac_allow_list.conf:db_host="::DB_HOST::"
#./overlay/etc/mac_allow_list/mac_allow_list.conf:db_port="::DB_PORT::"
#./overlay/etc/mac_allow_list/mac_allow_list.conf:db_user="::DB_USER::"
#./overlay/etc/mac_allow_list/mac_allow_list.conf:db_password="::DB_PASSWORD::"
