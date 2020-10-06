![Build](https://github.com/dodopizza/centos/workflows/Build/badge.svg?branch=latest&event=push)
![Create new release](https://github.com/dodopizza/centos/workflows/Create%20new%20release/badge.svg?event=workflow_dispatch)

* [DockerHub](https://hub.docker.com/r/dodopizza/centos)

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

## Usage for Linux/OS X

To use convenient command line function (dodo-centos), add following code to ~/.bashrc (bash) or ~/.zshrc (zsh)
```bash
function dodo-centos(){
	local version=2.1.1
	local DRONE_SERVER=https://drone.dodois.ru
	local DRONE_TOKEN="Your_drone_token"
	docker run -it --rm \
		-w /workdir -v "${PWD}:/workdir" \
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
  $version="2.1.1"
  $DRONE_SERVER="https://drone.dodois.ru"
  $DRONE_TOKEN="Your_drone_token"
  docker run -it --rm `
    --privileged `
    -w /workdir -v "${PWD}:/workdir" `
    -v //var/run/docker.sock:/var/run/docker.sock `
    -v ${HOME}/.kube:/root/.kube `
    --env DRONE_SERVER=$DRONE_SERVER `
    --env DRONE_TOKEN=$DRONE_TOKEN `
    dodopizza/centos:$version
}
```
