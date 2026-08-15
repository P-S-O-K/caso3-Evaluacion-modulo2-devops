#!/bin/bash

ls -1t /backups/*.sql 2>/dev/null | tail -n +2 | xargs -r rm -f

echo "$(date) - Limpieza realizada. Se conserva el backup más reciente." >> /var/log/backup.log