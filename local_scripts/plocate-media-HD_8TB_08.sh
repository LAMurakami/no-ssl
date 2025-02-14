#!/bin/sh
renice +19 -p $$ >/dev/null 2>&1
ionice -c2 -n7 -p $$ >/dev/null 2>&1
updatedb --require-visibility no \
--prunepaths "/media/HD_8TB_08/Bk2_Bk /media/HD_8TB_08/Bk3_Bk \
/media/HD_8TB_08/Install_Bk /media/HD_8TB_08/lost+found \
/media/HD_8TB_08/Music_Bk /media/HD_8TB_08/Pics_Bk \
/media/HD_8TB_08/Temp_Bk /media/HD_8TB_08/Zz_Bk" \
--output /media/HD_8TB_08/plocate.db \
--database-root /media/HD_8TB_08

chmod o+r /media/HD_8TB_08/plocate.db

# Script to rebuild the /media/HD_8TB_08 locate database for NFS client users

# To run this once
# sudo time -v /var/www/no-ssl/local_scripts/locate-media-HD_8TB_08.sh
