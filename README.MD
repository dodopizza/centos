![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/dodopizza/centos)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/dodopizza/centos)

[DockerHub](https://hub.docker.com/r/dodopizza/centos)

# BUILD/PUSH/TEST IMAGE

```
./docker.sh <build|push|test> <tag> [message]
```

# SUMMARY
* Jsonnet commandline interpreter v0.14.0
* redis-cli 5.0.6
* Python 2.7.5
* Python 3.6.8
* pip 19.3.1 from /usr/lib/python2.7/site-packages/pip (python 2.7)
* pip 19.3.1 from /usr/local/lib/python3.6/site-packages/pip (python 3.6)
* azure-cli                         2.0.76
* kubectl: Client Version: v1.16.3
* ansible 2.9.1
* ansible-lint 4.1.0
* azcopy version 10.3.2
* mysql  Ver 14.14 Distrib 5.7.28-31, for Linux (x86_64) using  6.2
* mysqldump  Ver 10.13 Distrib 5.7.28-31, for Linux (x86_64)
* mysqlpump  Ver 1.0.0 Distrib 5.7.28-31, for Linux (x86_64)
* xtrabackup version 2.3.10 based on MySQL server 5.6.24 Linux (x86_64) (revision id: bd0d4403f36)
* pt-online-schema-change 3.1.0
* Terraform v0.12.16
* drone version 1.2.0
* sft version 1.40.8
* az-mysqlpump  Ver 1.0.0 Distrib 5.7.24, for Linux (x86_64)
* Docker version 1.13.1, build 7f2769b/1.13.1

# CHANGELOG

## v2.0.2 (2019-11-15)
* kubectl: Client Version: v1.16.3
* ansible 2.9.1
* azcopy version 10.3.2
* mysql  Ver 14.14 Distrib 5.7.28-31, for Linux (x86_64) using  6.2
* mysqldump  Ver 10.13 Distrib 5.7.28-31, for Linux (x86_64)
* mysqlpump  Ver 1.0.0 Distrib 5.7.28-31, for Linux (x86_64)
* Terraform v0.12.16
+ Docker version 1.13.1, build 7f2769b/1.13.1

## v2.0.1 (2019-11-12)
* azure-cli 2.0.76
* Terraform v0.12.13

## v2.0 (2019-10-25) INITIAL
* Jsonnet commandline interpreter v0.14.0
* redis-cli 5.0.6
* Python 2.7.5
* Python 3.6.8
* pip 19.3.1 from /usr/lib/python2.7/site-packages/pip (python 2.7)
* pip 19.3.1 from /usr/local/lib/python3.6/site-packages/pip (python 3.6)
* azure-cli                         2.0.76
* kubectl: Client Version: v1.16.3
* ansible 2.9.1
* ansible-lint 4.1.0
* azcopy version 10.3.2
* mysql  Ver 14.14 Distrib 5.7.28-31, for Linux (x86_64) using  6.2
* mysqldump  Ver 10.13 Distrib 5.7.28-31, for Linux (x86_64)
* mysqlpump  Ver 1.0.0 Distrib 5.7.28-31, for Linux (x86_64)
* xtrabackup version 2.3.10 based on MySQL server 5.6.24 Linux (x86_64) (revision id: bd0d4403f36)
* pt-online-schema-change 3.1.0
* Terraform v0.12.15
* drone version 1.2.0
* sft version 1.40.8
* az-mysqlpump  Ver 1.0.0 Distrib 5.7.24, for Linux (x86_64)
* Docker version 1.13.1, build 7f2769b/1.13.1


# USAGE

Run default shell and mount current working directory:
```
docker run -it --rm -w /workdir -v "$(PWD):/workdir" dodopizza/centos:TAG
```

Run default shell and mount current working directory with dind (2.0.2+):
```
docker run -it --rm -w /workdir -v "$(PWD):/workdir" -v /var/run/docker.sock:/var/run/docker.sock dodopizza/centos:2.0.2
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