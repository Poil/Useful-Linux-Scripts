#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

[[ $# != 1 ]] && exit 1

ENV=$1

BACKUP_DIR="/home/user/backup/${ENV}"
[[ -f ${BACKUP_DIR} ]] && source ~/.config/backup_${ENV} || exit 2

[[ ! -d ${BACKUP_DIR} ]] && mkdir -p "${BACKUP_DIR}"
BACKUP_PATH=${BACKUP_DIR}/grants.$(date +"%Y%m%d.autobackup").sql

mysql \
  -h"${MYSQL_HOST}" \
  -u"${MYSQL_USER}" \
  -p"${MYSQL_PASSWORD}" \
  -sNe"$(mysql \
    -h"${MYSQL_HOST}" \
    -u"${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    -se"SELECT CONCAT('SHOW GRANTS FOR \'',user,'\'@\'',host,'\';') \
        FROM mysql.user \
        WHERE user NOT LIKE 'azure_superuser%' \
        AND user NOT LIKE '${MYSQL_USER}%';")" \
  | grep -v "SHOW GRANTS FOR" > ${BACKUP_PATH}


[[ -f ~/.config/restore_${ENV} ]] && source ~/.config/restore_${ENV} || exit 2
while read grants; do
mysql \
  -h"${MYSQL_HOST}" \
  -u"${MYSQL_USER}" \
  -p"${MYSQL_PASSWORD}" \
  -se"$grants;"
done < ${BACKUP_PATH}
mysql \
  -h"${MYSQL_HOST}" \
  -u"${MYSQL_USER}" \
  -p"${MYSQL_PASSWORD}" \
  -se"flush privileges;"

