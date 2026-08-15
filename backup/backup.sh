#!/bin/bash

FECHA=$(date +"%Y%m%d_%H%M%S")

PGPASSWORD=$POSTGRES_PASSWORD pg_dump \
  -h db \
  -U postgres \
  -d escuela \
  > /backups/escuela_$FECHA.sql

echo "$(date) - Backup creado: escuela_$FECHA.sql" >> /var/log/backup.log