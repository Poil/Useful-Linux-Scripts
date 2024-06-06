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

# Mute detector
$(dirname $0)/splunk_monitor_mute.sh ${ENV}

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
done < <(echo "${databases}" | grep -Ev 'aria_log_control|information_schema|mysql|performance_schema' | xargs -I{} -n4)

# UnMute detector
$(dirname $0)/splunk_monitor_unmute.sh ${ENV}

for db in ${databases}; do
  [[ $db =~ aria_log_control|information_schema|mysql|performance_schema ]] && continue
  echo "backuping $db"
  BACKUP_PATH=${BACKUP_DIR}/${db}.$(date +"%Y%m%d.autobackup").sql.gz
  az storage copy -s "${BACKUP_PATH}" -d "${FS_SAS}"
done

find "${BACKUP_DIR}" -mtime +30 \( -not -name "*20????01*" -or -mtime +365 \) -exec rm {} \;
