#!/bin/bash

echo ""
echo "### CMD ###"
echo ""

vault read database/creds/mariadb-role

echo ""
echo "### API ###"
echo ""

curl -s --header "X-Vault-Token:vault" \
	http://127.0.0.1:8200/v1/database/creds/mariadb-role | jq


