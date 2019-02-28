![](https://img.shields.io/docker/automated/dodopizza/centos.svg)
![](https://img.shields.io/docker/build/dodopizza/centos.svg)

[DockerHub](https://hub.docker.com/r/dodopizza/centos)


# Packages

* scaleft
* az
* python36 / pip3
* ansible 2.7.4 / ansible-lint / requests-ntlm / pywinrm
* percona mysql client 5.7 / percona xtrabackup / percona toolkit
* terraform
* drone-cli
* jsonnet


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