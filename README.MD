![](https://img.shields.io/docker/automated/dodopizza/centos.svg)

[DockerHub](https://hub.docker.com/r/dodopizza/centos)

# Update info

## v1.14 (2019-06-05)
drone client 1.1.1 (from 0.8.6)

## v1.13 (2019-05-21)
Ansible 2.8.0 (from 2.7.10)


# Packages

* scaleft
* az
* azcopy
* python36 / pip3
* ansible 2.7.4 / ansible-lint / requests-ntlm / pywinrm
* percona mysql client 5.7 / percona xtrabackup / percona toolkit
* terraform (0.12)
* drone-cli
* redis-cli
* jsonnet
* az-mysqlpump (mysqlpump 5.7.21 с отключенной проверкой версии MySQL - нужно для managed баз)

# Usage

Run default shell and mount current working directory:
```
docker run -it --rm -w /workdir -v "$(PWD):/workdir" dodopizza/centos
```

To access to dodo infrastructure:
```
az login && sft enroll && sft login
```

To forward current service user onto the container use special image (sftd required):
```
docker run -it --rm \
    -w /workdir -v "$(PWD):/workdir" \
    -e "SFT_USER_ID=$(id -u)" \
    -e "SFT_USER_NAME=$(id -un)" \
    -v /var/run/sftd/management.sock:/var/run/sftd/management.sock \
    dodopizza/centos:latest-sftd-host-mapping
```


# Build and push to registry

```
./docker.sh <build|push> <tag> [message]
```