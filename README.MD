* [DockerHub](https://hub.docker.com/r/dodopizza/centos)
* [GitLab CI/CD](https://gitlab.com/dodopizza/infrastructure/centos/pipelines)

# BUILD/PUSH/TEST IMAGE

```
./make <build|build-no-cache|push|test> <tag> [message]
```

```documentation
ttl: 30d
tags:
  - jq
  - git
  - jsonnet
  - redis
  - redis-cli
  - python
  - pip
  - azure
  - azure-cli
  - kubectl
  - ansible
  - ansible-lint
  - azcopy
  - mysql
  - mysqldump
  - mysqlpump
  - xtrabackup
  - pt-online-schema-change
  - ghost
  - gh-ost
  - innotop
  - Terraform
  - packer
  - drone
  - sft
  - az-mysqlpump
  - Docker
  - docker-compose
  - helm
  - werf
  - promtool
indexes:
  - Инфраструктура/Centos/Docker centos
  - Инфраструктура/Linux/Docker/Centos
  - Инфраструктура/Docker/dodo-centos
```

# SUMMARY
* jq-1.6
* git version 1.8.3.1
* Jsonnet commandline interpreter v0.15.0
* redis-cli 5.0.9
* Python 2.7.5
* Python 3.6.8
* pip 20.0.2 from /usr/lib/python2.7/site-packages/pip (python 2.7)
* pip 20.0.2 from /usr/local/lib/python3.6/site-packages/pip (python 3.6)
* azure-cli 2.3.1
* kubectl: Client Version: v1.18.2
* ansible 2.9.6
* ansible-lint 4.2.0
* azcopy version 10.4.0
* mysql  Ver 14.14 Distrib 5.7.29-32, for Linux (x86_64) using  6.2
* mysqldump  Ver 10.13 Distrib 5.7.29-32, for Linux (x86_64)
* mysqlpump  Ver 1.0.0 Distrib 5.7.29-32, for Linux (x86_64)
* xtrabackup version 2.3.10 based on MySQL server 5.6.24 Linux (x86_64) (revision id: bd0d4403f36)
* pt-online-schema-change 3.0.14-dev
* gh-ost: 13b5f48ca5e7cc83bf7af2455785304c2c4385fb
* innotop  Ver 1.12.0
* Terraform v0.12.24
* packer (hashicorp-packer): 1.5.5
* drone version 1.2.1
* sft version 1.44.4
* az-mysqlpump  Ver 1.0.0 Distrib 5.7.24, for Linux (x86_64)
* Docker version 1.13.1, build cccb291/1.13.1
* docker-compose version 1.25.5, build unknown
* helm: Client: v2.11.0+g2e55dbe
* werf: v1.1.9+fix5
* promtool, version 2.17.1 (branch: HEAD, revision: ae041f97cfc6f43494bed65ec4ea4e3a0cf2ac69)

# CHANGELOG

## v2.0.9 (2020-04-17)
* Based on centos:7.7.1908
* ansible 2.9.6
* redis-cli 5.0.9
* kubectl: Client Version: v1.18.2
* werf: v1.1.9+fix5
* promtool, version 2.17.1 (branch: HEAD, revision: ae041f97cfc6f43494bed65ec4ea4e3a0cf2ac69)

## v2.0.8 (2020-04-14)
* azure-cli 2.3.1
* kubectl: Client Version: v1.18.1
* azcopy version 10.4.0
* gh-ost: 13b5f48ca5e7cc83bf7af2455785304c2c4385fb
* Terraform v0.12.24
* packer (hashicorp-packer): 1.5.5
* drone version 1.2.1
* sft version 1.44.4
* docker-compose version 1.25.5, build unknown
* werf: v1.1.8

## v2.0.7 (2020-03-16)
* redis-cli 5.0.8
* azure-cli 2.2.0
* kubectl: Client Version: v1.17.4
* Terraform v0.12.23
* promtool, version 2.16.0 (branch: HEAD, revision: b90be6f32a33c03163d700e1452b54454ddce0ec)

## v2.0.6 (2020-03-05)
* helm: Client: v2.11.0+g2e55dbe

## v2.0.5 (2020-03-03)
* jq-1.6
* Jsonnet commandline interpreter v0.15.0
* pip 20.0.2 from /usr/lib/python2.7/site-packages/pip (python 2.7)
* pip 20.0.2 from /usr/local/lib/python3.6/site-packages/pip (python 3.6)
* azure-cli                          2.1.0
* kubectl: Client Version: v1.17.3
* azcopy version 10.3.4
* mysql  Ver 14.14 Distrib 5.7.29-32, for Linux (x86_64) using  6.2
* mysqldump  Ver 10.13 Distrib 5.7.29-32, for Linux (x86_64)
* mysqlpump  Ver 1.0.0 Distrib 5.7.29-32, for Linux (x86_64)
* Terraform v0.12.21
* Docker version 1.13.1, build 4ef4b30/1.13.1
* docker-compose version 1.25.4, build unknown
* sshpass util

## v2.0.4 (2019-12-20)
* azure-cli 2.0.78
* docker-compose version 1.25.0, build b42d419

## v2.0.3 (2019-12-16)
* git version 1.8.3.1

## v2.0.3 (2019-12-13)
* pt-online-schema-change 3.0.14-dev
* redis-cli 5.0.7
* azure-cli 2.0.77
* kubectl: Client Version: v1.17.0
* ansible-lint 4.2.0
* azcopy version 10.3.3
* Terraform v0.12.18
* sft version 1.41.0

## v2.0.2 (2019-12-06)
* innotop  Ver 1.12.0
* Terraform v0.12.17

## v2.0.2 (2019-11-27)
* redis-cli 5.0.7
* azure-cli 2.0.77
* sft version 1.41.0

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
* redis-cli 5.0.7
* Python 2.7.5
* Python 3.6.8
* pip 19.3.1 from /usr/lib/python2.7/site-packages/pip (python 2.7)
* pip 19.3.1 from /usr/local/lib/python3.6/site-packages/pip (python 3.6)
* azure-cli                         2.0.77
* kubectl: Client Version: v1.17.0
* ansible 2.9.1
* ansible-lint 4.2.0
* azcopy version 10.3.3
* mysql  Ver 14.14 Distrib 5.7.28-31, for Linux (x86_64) using  6.2
* mysqldump  Ver 10.13 Distrib 5.7.28-31, for Linux (x86_64)
* mysqlpump  Ver 1.0.0 Distrib 5.7.28-31, for Linux (x86_64)
* xtrabackup version 2.3.10 based on MySQL server 5.6.24 Linux (x86_64) (revision id: bd0d4403f36)
* pt-online-schema-change 3.0.14-dev
* innotop  Ver 1.12.0
* Terraform v0.12.18
* drone version 1.2.0
* sft version 1.41.0
* az-mysqlpump  Ver 1.0.0 Distrib 5.7.24, for Linux (x86_64)
* Docker version 1.13.1, build 7f2769b/1.13.1


# USAGE

Run default shell and mount current working directory:
```bash
docker run -it --rm -w /workdir -v "$(PWD):/workdir" dodopizza/centos:TAG
```

To login to dodo infrastructure just type:
```bash
dodo-login
```

To forward current service user onto the container (sftd required):
```bash
...
-e "SFT_USER_ID=$(id -u)" 
-e "SFT_USER_NAME=$(id -un)" 
-v /var/run/sftd/management.sock:/var/run/sftd/management.sock 
...
```

## Usage for Lnux/MaxOS X

To use convenient command line function (dodo-centos), add following code to ~/.bashrc (bash) or ~/.zshrc (zsh)
```bash
function dodo-centos(){
	local version=2.0.9
	local DRONE_SERVER=https://drone.dodois.ru
	local DRONE_TOKEN="Your_drone_token"
	docker run -it --rm \
		-w /workdir \
		-v "${PWD}:/workdir" \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${HOME}/.kube:/root/.kube \
		--env DRONE_SERVER=${DRONE_SERVER} \
		--env DRONE_TOKEN=${DRONE_TOKEN} \
		dodopizza/centos:${version}
}
```

## Usage for Windows

To use convenient command line function (dodo-centos) for Windows, open pwsh profile with command
```powershell
New-Item $profile -Type File -Force
notepad.exe $profile
```

and add following code
```powershell
Function dodo-centos {
  $version="2.0.9"
  $DRONE_SERVER="https://drone.dodois.ru"
  $DRONE_TOKEN="Your_drone_token"
  docker run -it --rm `
    --privileged `
    -w /workdir `
    -v "${PWD}:/workdir" `
    -v //var/run/docker.sock:/var/run/docker.sock `
    -v ${HOME}/.kube:/root/.kube `
    --env DRONE_SERVER=$DRONE_SERVER `
    --env DRONE_TOKEN=$DRONE_TOKEN `
    dodopizza/centos:$version
}
```
