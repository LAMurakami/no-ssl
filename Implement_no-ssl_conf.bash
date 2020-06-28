#!/bin/bash
#---:----|----:----|----:----|----:----|----:----|----:----|----:----|----:----|
# Set the base directory for these changes
sub_dir='no-ssl';
base_dir="/var/www/$sub_dir";
if [ ! -d $base_dir ]; then
    echo "$base_dir does not exist."
    echo 'base directory is not where expected.'
    exit
fi

# Set the apache2 sites available dir where site configuration files go
apache2_sites_available_dir='/etc/apache2/sites-available';
if [ ! -d $apache2_sites_available_dir ]; then
    echo "$apache2_sites_available_dir does not exist."
    echo 'Either apache2 is not installed or the apache2 sites available directory is not where expected.'
    exit
fi

# Set the apache2 sites enabled dir where site configuration files go
apache2_sites_enabled_dir='/etc/apache2/sites-enabled';
if [ ! -d $apache2_sites_enabled_dir ]; then
    echo "$apache2_sites_enabled_dir does not exist."
    echo 'Either apache2 is not installed or the apache2 sites enabled directory is not where expected.'
    exit
fi

# Set the apache2 modules available dirirectory where module configuration files go
apache2_mods_available_dir='/etc/apache2/mods-available';
if [ ! -d $apache2_mods_available_dir ]; then
    echo "$apache2_mods_available_dir does not exist."
    echo 'The apache2 modules available dirirectory is not where expected.'
    exit
fi

# Set the apache2 modules enabled dirirectory where module configuration files go
apache2_mods_enabled_dir='/etc/apache2/mods-enabled';
if [ ! -d $apache2_mods_enabled_dir ]; then
    echo "$apache2_mods_enabled_dir does not exist."
    echo 'The apache2 modules enabled dirirectory is not where expected.'
    exit
fi
#---:----|----:----|----:----|----:----|----:----|----:----|----:----|----:----|
echo
echo 'Linking apache2.conf to no-ssl/apache2.conf'
if [ -f /etc/apache2/apache2.conf ]; then
    file /etc/apache2/apache2.conf
    echo "$0 will not replace /etc/apache2/apache2.conf if it exists."
    exit
fi
cp -p $base_dir/apache2.conf /etc/apache2/apache2.conf

echo
echo 'Enabling 000-no-ssl site and disabling 000-default site'
if [ -L $apache2_sites_available_dir/000-no-ssl.conf ]; then
    file $apache2_sites_available_dir/000-no-ssl.conf
    rm /etc/apache2/sites-available/000-no-ssl.conf
    echo "$apache2_sites_available_dir/000-no-ssl.conf removed"
fi
if [ -f $apache2_sites_available_dir/000-no-ssl.conf ]; then
    file $apache2_sites_available_dir/000-no-ssl.conf
    echo "$apache2_sites_available_dir/000-no-ssl.conf is a regular file"
    echo "$0 will not replace a regular file with a symbolic link."
    exit
fi
ln -s $base_dir/${sub_dir}_apache2.conf $apache2_sites_available_dir/000-no-ssl.conf
if [ ! -f $apache2_sites_enabled_dir/000-no-ssl.conf ]; then
    a2ensite 000-no-ssl
fi
file $apache2_sites_enabled_dir/000-no-ssl.conf
if [ -f $apache2_sites_enabled_dir/000-default.conf ]; then
    a2dissite 000-default
fi

echo
echo 'Enabling alias module for users logged in to the secure site'
if [ -L $apache2_mods_available_dir/alias.conf ]; then
    file $apache2_mods_available_dir/alias.conf
    rm $apache2_mods_available_dir/alias.conf
    echo "$apache2_mods_available_dir/alias.conf removed"
fi
if [ -f $apache2_mods_available_dir/alias.conf ]; then
    file $apache2_mods_available_dir/alias.conf
    echo "$apache2_mods_available_dir/alias.conf is a regular file"
    echo "$0 will not replace a regular file with a symbolic link."
    exit
fi
ln -s $base_dir/${sub_dir}_alias.conf /etc/apache2/mods-available/alias.conf
if [ ! -f $apache2_mods_enabled_dir/alias.conf ]; then
    a2enmod alias
fi
file $apache2_mods_enabled_dir/alias.conf

echo
echo 'Enabling autoindex module for users logged in to the secure site'
if [ -L $apache2_mods_available_dir/autoindex.conf ]; then
    file $apache2_mods_available_dir/autoindex.conf
    rm $apache2_mods_available_dir/autoindex.conf
    echo "$apache2_mods_available_dir/autoindex.conf removed"
fi
if [ -f $apache2_mods_available_dir/autoindex.conf ]; then
    file $apache2_mods_available_dir/autoindex.conf
    echo "$apache2_mods_available_dir/autoindex.conf is a regular file"
    echo "$0 will not replace a regular file with a symbolic link."
    exit
fi
ln -s $base_dir/${sub_dir}_autoindex.conf /etc/apache2/mods-available/autoindex.conf
if [ ! -f $apache2_mods_enabled_dir/autoindex.conf ]; then
    a2enmod autoindex
fi
file $apache2_mods_enabled_dir/autoindex.conf

echo
echo 'Enabling dir module for users logged in to the secure site'
if [ -L $apache2_mods_available_dir/dir.conf ]; then
    file $apache2_mods_available_dir/dir.conf
    rm $apache2_mods_available_dir/dir.conf
    echo "$apache2_mods_available_dir/dir.conf removed"
fi
if [ -f $apache2_mods_available_dir/dir.conf ]; then
    file $apache2_mods_available_dir/dir.conf
    echo "$apache2_mods_available_dir/dir.conf is a regular file"
    echo "$0 will not replace a regular file with a symbolic link."
    exit
fi
ln -s $base_dir/${sub_dir}_dir.conf /etc/apache2/mods-available/dir.conf
if [ ! -f $apache2_mods_enabled_dir/dir.conf ]; then
    a2enmod dir
fi
file $apache2_mods_enabled_dir/dir.conf

systemctl reload apache2

echo "$0 completed normally."

