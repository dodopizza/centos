![](https://img.shields.io/docker/automated/dodopizza/centos.svg)
[![Build Status](https://drone.dodois.ru/api/badges/dodopizza/docker-centos/status.svg)](https://drone.dodois.ru/dodopizza/docker-centos)

[DockerHub](https://hub.docker.com/r/dodopizza/centos)

# BUILD/PUSH/TEST IMAGE

```
./docker.sh <build|push|test> <tag> [message]
```

# CHANGELOG

## v2.0 (2019-10-25) INITIAL
* Jsonnet commandline interpreter v0.14.0
* redis-cli 5.0.6
* Python 2.7.5
* Python 3.6.8
* azure-cli 2.0.75
* ansible 2.8.6
* ansible-lint 4.1.0
* azcopy version 10.3.1
* mysql  Ver 14.14 Distrib 5.7.27-30, for Linux (x86_64) using  6.2
* xtrabackup version 2.3.10 based on MySQL server 5.6.24 Linux (x86_64) (revision id: bd0d4403f36)
* pt-online-schema-change 3.1.0
* drone version 1.2.0
* sft version 1.40.8
* az-mysqlpump  Ver 1.0.0 Distrib 5.7.24, for Linux (x86_64)
* kubectl: Client Version: v1.16.2


# USAGE

Run default shell and mount current working directory:
```
docker run -it --rm -w /workdir -v "$(PWD):/workdir" dodopizza/centos:TAG
```

To login to dodo infrastructure just type:
```
dodologin
```

To forward current service user onto the container (sftd required):
```
docker run -it --rm \
    -w /workdir -v "$(PWD):/workdir" \
    -e "SFT_USER_ID=$(id -u)" \
    -e "SFT_USER_NAME=$(id -un)" \
    -v /var/run/sftd/management.sock:/var/run/sftd/management.sock \
    dodopizza/centos:TAG
```