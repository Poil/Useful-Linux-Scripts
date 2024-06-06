#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

[[ $# != 1 ]] && exit 1

ENV=$1

BACKUP_DIR="/home/user/backup/${ENV}"
[[ -f ${BACKUP_DIR} ]] && source ~/.config/backup_${ENV} || exit 2

[[ ! -d ${BACKUP_DIR} ]] && mkdir -p "${BACKUP_DIR}"

databases=$(mysql -B -N \
  -h "${MYSQL_HOST}" \
  -u "${MYSQL_USER}" \
  -p"${MYSQL_PASSWORD}" \
  -e "show databases;")

while read databases_split; do
  echo "Parallel backup of ${databases_split}"
  for db in ${databases_split}; do
    echo "backuping $db $(date +'%F %H:%M:%S')"
    BACKUP_PATH=${BACKUP_DIR}/${db}.$(date +"%Y%m%d.autobackup").sql.gz
    mysqldump \
      --skip-lock-tables \
      --single-transaction \
      -h "${MYSQL_HOST}" \
      -u "${MYSQL_USER}" \
      -p"${MYSQL_PASSWORD}" "${db}" | gzip > "${BACKUP_PATH}" &
  done

  wait
done < <(echo "${databases}" | grep -Ev 'aria_log_control|information_schema|performance_schema|mysql' | xargs -I{} -n4)

## Restore
[[ -f ~/.config/restore_${ENV} ]] && source ~/.config/restore_${ENV} || exit 2
while read databases_split; do
  echo "Parallel restore of ${databases_split}"
  for db in ${databases_split}; do
    [[ $db =~ aria_log_control|information_schema|performance_schema|mysql ]] && continue
    echo "restoring $db"
    BACKUP_PATH=${BACKUP_DIR}/${db}.$(date +"%Y%m%d.autobackup").sql.gz
    # mysql -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p${MYSQL_PASSWORD} -e "drop database IF EXISTS \`${db}\`;"
    mysql -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p${MYSQL_PASSWORD} -e "CREATE DATABASE ${db} /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */"
    gunzip < ${BACKUP_PATH} | mysql -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -A "${db}" &
  done

  wait
done < <(echo "${databases}" | grep -Ev 'aria_log_control|information_schema|performance_schema|mysql' | xargs -I{} -n4)
