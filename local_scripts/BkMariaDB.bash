#! /bin/bash

BS=ak20
BD=/mnt/ak20-Bk/Bk2/${BS}/Day/$(date +'%y%m%d')

# Put the daily lam and wikidb backups in S3

aws s3 cp ${BD}/Bk-20-MySQL.lam.sql.gz s3://lamurakami --no-progress
aws s3 cp ${BD}/Bk-20-MySQL.wikidb.sql.gz s3://lamurakami --no-progress

