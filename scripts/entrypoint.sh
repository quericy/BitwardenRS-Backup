#!/bin/sh

. /app/includes.sh

# timezone
ln -sf /usr/share/zoneinfo/${TZ:-"Asia/Shanghai"} /etc/localtime
echo ${TZ:-"Asia/Shanghai"} > /etc/timezone

# rclone command
if [[ "$1" == "rclone" ]]; then
    $*

    exit 0
fi

# mailx test
if [[ "$1" == "mail" ]]; then
    MAIL_SMTP_ENABLE="TRUE"
    MAIL_DEBUG="TRUE"

    if [[ -n "$2" ]]; then
        MAIL_TO="$2"
    fi

    init_env

    send_mail "BitwardenRS Backup Test" "Your SMTP looks configured correctly."

    exit 0
fi

function configure_cron() {
    echo "${CRON} sh /app/backup.sh > /dev/stdout" >> /etc/crontabs/root
}

init_env
check_rclone_connection
configure_cron

# foreground run crond
crond -l 2 -f
