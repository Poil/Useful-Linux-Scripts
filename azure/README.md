faz
===============

Installation
---------------


Usage
---------------
```sh
faz subtomatch.*
```

```json
{
  "cloudName": "AzureCloud",
  "id": "xxxxxxxx"
  "isDefault": false,
  "name": "subtomatch-blabla",
  "state": "Enabled",
  "tenantId": "xxxxxxxxxx",
  "user": {
    "name": "poil"
    "type": "user"
  }
}
```

gmygroup
=========

Usage
---------------
```sh
gmygroup myid
#  You can have ID via :
faz subtomatch | jq -r '. | "\(.name) : \(.id)"'
```

```json
[
  {
    "displayName": "lala",
    "objectId": "xxxxxxxxxx"
  },
  {
    "displayName": "lolo",
    "objectId": "yyyyyyyyyyy"
  }
]
```

list-vm
==============

List VM on a RG and generate confluence markdown

Usage
---------------

```sh
$ list-vm.sh -g my-rg -s xxxxxxxxxxxxxxxxxx
```

Note : Subscription is optionnal and is current one if not specified

```
|| Name                            || Internal Network                || Public Network    || Login             || Password                        || OS                              ||
|                           vm01   | 192.168.4.5                      | 40.127.153.27      | admin              | ssh key                          | Debian 10                        |
|                           vm02   | 192.168.4.4                      |                    | admin              | ssh key                          | Debian 10                        |
```

