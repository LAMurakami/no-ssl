#! /bin/bash

BS=ak17
BD=/mnt/Bk0/Bk/${BS}/Day/$(date +'%y%m%d')

# Put the daily lam and wikidb backups in S3

aws s3 cp ${BD}/Bk-20-MySQL.lam.sql.gz s3://lamurakami
aws s3 cp ${BD}/Bk-20-MySQL.wikidb.sql.gz s3://lamurakami

