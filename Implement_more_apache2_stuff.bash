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

source_dir='/var/www/no-ssl';
check_dir "no-ssl" "/var/www" "Base directory is not where expected."

echo
echo "Configuring logrotate for apache2"

logrotate_conf_dir='/etc/logrotate.d';
check_dir "logrotate.d" "/etc" \
"logrotate configuration directory is not where expected."

cp ${source_dir}/no-ssl_apache2-logrotate.conf ${logrotate_conf_dir}/apache2

echo
echo "Configuring php for apache2"

php_conf_dir='/etc/php/7.2/apache2';
check_dir "apache2" "/etc/php/7.2" \
"php/7.2 configuration directory is not where expected."

cp ${source_dir}/no-ssl_apache2-php.ini /etc/php/7.2/apache2/php.ini

echo
echo "Configuring mlocate path to use /mnt/efs database"

mlocate_path_conf_dir='/etc/profile.d';
check_dir "profile.d" "/etc" \
"mlocate path configuration directory is not where expected."

ln -s ${source_dir}/mlocate.sh ${mlocate_path_conf_dir}

echo
echo "$0 completed normally."

