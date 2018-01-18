alias cronall='for crond in /etc/cron.d/*; do echo -e "\033[1m${crond##*\/} (cron.d):\n\033[0m" && cat ${crond} | grep -v HEADER && echo "====================="; done && for user in /var/spool/cron/crontabs/* /var/spool/cron/*; do [[ -f ${user} ]] && echo -e "\033[1m${user##*\/}:\n\033[0m" && crontab -u ${user##*\/} -l | grep -v HEADER && echo "====================="; done'

