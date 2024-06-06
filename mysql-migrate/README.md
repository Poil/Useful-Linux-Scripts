# Introduction

## MySQL main script
* migrate\_mysql.sh : parallel databases backup & restore script (src/target)
* migrate\_grants.sh : extract grants except `azure_super_azure` & `MYSQL_USER` and restore
* backup\_prod : src db config example (you can use keyvault call if you prefer)
* restore\_prod : target db config example (you can use keyvault call if you prefer)
