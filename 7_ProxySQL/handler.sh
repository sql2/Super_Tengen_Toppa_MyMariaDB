#!/bin/bash
# encoding: UTF-8

# el handler se activa si los checks pasan.
# Usar orchestrator para hacer check del servidor ok y agregar al proxysql.
# validar si ya esta agregado, si hay nuevos hacer load & save.

exec >> /root/handler.log

[ $# -ge 1 -a -f "$1" ] && INPUT="$1" || INPUT="-"

JSON=$(cat $INPUT)

if [[ -z "${JSON}" || "${JSON}" == "null" ]]
then
  echo "No data"
  exit 1
fi

VALUES=$(echo $JSON | jq -r '.Value' | base64 --decode)
ARRAY=(${VALUES//,/ })

for IP in "${ARRAY[@]}"
do
  echo $IP
  mysql -h 127.0.0.1 -u admin -padmin -P 6032 --force --execute="
    INSERT INTO mysql_servers (
      hostgroup_id,
      hostname,
      port,
      max_connections,
      max_replication_lag
    ) VALUES (
      1,
      '${IP}',
      3306,
      10,
      60
    );"
done

mysql -h 127.0.0.1 -u admin -padmin -P 6032 --execute="
  LOAD MYSQL SERVERS TO RUNTIME;
  SAVE MYSQL SERVERS TO DISK;
"

mysql -h 127.0.0.1 -u admin -padmin -P 6032 --execute="
SET admin-web_enabled='true';
LOAD ADMIN VARIABLES TO RUNTIME;
"

# with LDAP
#mysql -h 127.0.0.1 -u admin -padmin -P 6032 --execute="
#UPDATE GLOBAL_VARIABLES SET variable_vaule = 'ldap://172.16.10.1' WHERE variable_name = 'ldap-uri';
#UPDATE GLOBAL_VARIABLES SET variable_vaule = 'DC=example,DC=test' WHERE variable_name = 'ldap-root_dn';
#UPDATE GLOBAL_VARIABLES SET variable_vaule = '@example.test' WHERE variable_name = 'ldap-bind_dn_suffix';
#UPDATE GLOBAL_VARIABLES SET variable_vaule = '@example.test' WHERE variable_name = 'ldap-bind_dn_suffix';

#LOAD LDAP VARIABLES TO RUNTIME;
#SAVE LDAP VARIABLES TO DISK;
#"

PMMSERVER_IP=$(consul kv get pmm-server)

pmm-admin config --force --server ${PMMSERVER_IP}

pmm-admin add linux:metrics 
pmm-admin add proxysql:metrics

pmm-admin list
pmm-admin check-network –no-emoji
