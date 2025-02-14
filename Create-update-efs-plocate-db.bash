#!/usr/bin/bash

for EFS in efs efs2 efs3 ; do
    if [ -d /mnt/${EFS} ] ; then
        echo "/mnt/${EFS} directory exists."
        if [ ! -f /mnt/${EFS}/plocate.db ] ; then
            echo "/mnt/${EFS}/plocate.db does not exist"
            echo "Create /mnt/${EFS}/plocate.db"
            /var/www/no-ssl/local_scripts/plocate-mnt-${EFS}.sh # Build
        else
            one_day_ago=$(date -d 'now - 1 day' +%s)
            file_time=$(date -r "/mnt/${EFS}/plocate.db" +%s)
            if (( $file_time <= $one_day_ago )); then
                echo "/mnt/${EFS}/plocate.db is older than 1 day"
                echo "update /mnt/${EFS}/plocate.db"
                /var/www/no-ssl/local_scripts/plocate-mnt-${EFS}.sh # Update
            fi
        fi
    else
        echo "/mnt/${EFS} directory does not exist."
    fi
done

SYSTEM_LOCATE_PATH='/mnt/efs/plocate.db:/mnt/efs2/plocate.db'
if [ -f /mnt/efs3/plocate.db ] ; then
    SYSTEM_LOCATE_PATH="${SYSTEM_LOCATE_PATH}:/mnt/efs3/plocate.db"
fi
echo "export LOCATE_PATH=${SYSTEM_LOCATE_PATH}" > /etc/profile.d/plocate.sh
