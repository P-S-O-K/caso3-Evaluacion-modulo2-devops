FROM postgres:16

RUN apt-get update && \
    apt-get install -y cron && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /scripts /backups

COPY backup.sh /scripts/backup.sh
COPY cleanup.sh /scripts/cleanup.sh
COPY crontab /etc/cron.d/postgres-backup

RUN chmod +x /scripts/backup.sh \
    /scripts/cleanup.sh && \
    chmod 0644 /etc/cron.d/postgres-backup

RUN touch /var/log/backup.log

CMD ["cron", "-f"]