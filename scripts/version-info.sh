#!/bin/bash
jq --version 
git --version 
jsonnet --version 
redis-cli --version 
python --version 
python3.6 --version 
pip2 --version 
pip3 --version 
( az --version 2> /dev/null ) | head -n 1 
echo -n "kubectl: " && kubectl version --client=true --short=true 
ansible --version | head -n 1 
ansible-lint --version 
azcopy --version 
mysql --version 
mysqldump --version 
mysqlpump --version 
xtrabackup --version 
pt-online-schema-change --version 
echo -n "gh-ost: " && gh-ost --version 
innotop --version 
terraform --version 
echo -n "packer (hashicorp-packer): " && hashicorp-packer --version 
( drone --version || true ) 
sft --version 
az-mysqlpump --version 
docker --version 
docker-compose --version 
echo -n "helm: " && helm version --client --short 
echo -n "werf: " && werf version 
( promtool --version 2>&1 | grep promtool ) 