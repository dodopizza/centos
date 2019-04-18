![](https://img.shields.io/docker/automated/dodopizza/centos.svg)
![](https://img.shields.io/docker/build/dodopizza/centos.svg)

[DockerHub](https://hub.docker.com/r/dodopizza/centos)


# Packages

* scaleft
* az
* azcopy
* python36 / pip3
* ansible 2.7.4 / ansible-lint / requests-ntlm / pywinrm
* percona mysql client 5.7 / percona xtrabackup / percona toolkit
* terraform (0.11.13)
* terraform12 (0.12.0-beta1)
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