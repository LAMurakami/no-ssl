#!/bin/bash
#---:----|----:----|----:----|----:----|----:----|----:----|----:----|----:----|
check_dir () {
# Check the base directory for these changes
sub_dir=$1
base_dir="$2";
error_message="$3";
check_dir="${base_dir}/${sub_dir}";
if [ ! -d ${check_dir} ]; then
    echo "${check_dir} does not exist."
    echo "$error_message"
    exit
fi
}
#---:----|----:----|----:----|----:----|----:----|----:----|----:----|----:----|
set_site_conf () {
# Set the source directory for these changes
sub_dir=$1
order=$2
source_dir="/var/www/${sub_dir}";

check_dir "${sub_dir}" "/var/www" "Base directory is not where expected."

echo
echo "Enabling ${order}_${sub_dir} site"
if [ -L $apache2_sites_available_dir/${order}_${sub_dir}.conf ]; then
    file $apache2_sites_available_dir/${order}_${sub_dir}.conf
    rm /etc/apache2/sites-available/${order}_${sub_dir}.conf
    echo "$apache2_sites_available_dir/${order}_${sub_dir} removed"
fi
if [ -f $apache2_sites_available_dir/${order}_${sub_dir}.conf ]; then
    file $apache2_sites_available_dir/${order}_${sub_dir}.conf
    echo "$apache2_sites_available_dir/${order}_${sub_dir}.conf is a regular file"
    echo "$0 will not replace a regular file with a symbolic link."
    exit
fi
ln -s ${source_dir}/${sub_dir}_apache2.conf $apache2_sites_available_dir/${order}_${sub_dir}.conf
if [ ! -f $apache2_sites_enabled_dir/${order}_${sub_dir}.conf ]; then
    a2ensite ${order}_${sub_dir}
fi
file $apache2_sites_available_dir/${order}_${sub_dir}.conf
}
#---:----|----:----|----:----|----:----|----:----|----:----|----:----|----:----|
# Set the apache2 sites available dir where site configuration files go
apache2_sites_available_dir='/etc/apache2/sites-available';
check_dir "sites-available" "/etc/apache2" \
"Either apache2 is not installed or the apache2 sites available directory is not where expected."

# Set the apache2 sites enabled dir where site configuration files go
apache2_sites_enabled_dir='/etc/apache2/sites-enabled';
check_dir "sites-enabled" "/etc/apache2" \
"Either apache2 is not installed or the apache2 sites available directory is not where expected."

#---:----|----:----|----:----|----:----|----:----|----:----|----:----|----:----|
set_site_conf "oldinteriordems" "010"

set_site_conf "interiordems" "020"

set_site_conf "sites" "030"

set_site_conf "cabo" "040"

set_site_conf "z" "050"

set_site_conf "blinkenshell" "051"

set_site_conf "olnes" "052"

set_site_conf "arsc" "060"

set_site_conf "larryforalaska" "070"

set_site_conf "alaskademocrat" "071"

set_site_conf "aws" "080"

set_site_conf "mike" "081"

systemctl reload apache2

echo "$0 completed normally."

