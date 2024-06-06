dssh
==============

SSH Helper designed to work with KeePass2

Installation
---------------

```sh
sudo ln -nfs $PWD/dssh /usr/local/bin/dssh
[[ -f /etc/redhat_release ]] && sudo yum install -y xdotools
[[ -f /etc/lsb-release ]] && sudo apt install -y xdotools
```

Usage
---------------
In KeePass/Auto-Type override default sequence to `{PASSWORD}{ENTER}`

```sh
dssh myhost-that-require-password
```


drdp
==============

RDP Helper designed to work with KeePass2, support Socks5 Proxy over SSH (need freerdp 2.0)

Installation
---------------

```sh
sudo ln -nfs $PWD/drdp /usr/local/bin/drdp
[[ -f /etc/redhat_release ]] && sudo yum install -y xdotools freerdp2-x11
[[ -f /etc/lsb-release ]] && sudo apt install -y xdotools freerdp2-x11
```

Usage
---------------
In KeePass/Auto-Type override default sequence to `{PASSWORD}{ENTER}`

```sh
drdp user@10.1.1.100 my-ssh-bastion
```
