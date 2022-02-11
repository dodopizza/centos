![Build](https://github.com/dodopizza/centos/workflows/Build/badge.svg?branch=latest&event=push)
![Create new release](https://github.com/dodopizza/centos/workflows/Create%20new%20release/badge.svg?event=workflow_dispatch)

* docker hub: [dodopizza/centos](https://hub.docker.com/r/dodopizza/centos)
* docker hub dev: [dodopizza/centos-dev](https://hub.docker.com/r/dodopizza/centos-dev)

## Table of contents

* [Usage](#usage)
  * [Linux/OS X](#usage-for-linuxos-x)
  * [Windows](#usage-for-windows)
* [Development and Workflow](#development-and-workflow)
* [Releases](#releases)

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
    local version=4
    docker run -it --rm \
        -w /workdir -v "${PWD}:/workdir" \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v ${HOME}/.kube:/root/.kube \
        dodopizza/centos:${version}
}
```

To run dodo-centos as a pod in Kubernetes cluster add next code:

```bash
function dodo-centos-k8s(){
    local version=4
    local username=$(id -u -n)
    local podname="dodo-centos-${username}"
    kubectl delete pod --ignore-not-found "${podname}"
    kubectl run "${podname}" -it --rm --image=dodopizza/centos:${version}
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
  $version="4"
  docker run -it --rm `
    --privileged `
    -w /workdir -v "${PWD}:/workdir" `
    -v //var/run/docker.sock:/var/run/docker.sock `
    -v ${HOME}/.kube:/root/.kube `
    dodopizza/centos:$version
}
```


## Development and Workflow

`latest` branch - is the main development branch. When changes was pushed to the `latest` branch, GHA build and push docker-image to:

* `dodopizza/centos:latest`
* `dodopizza/centos-dev:latest`

`*` branches - all other branches build and push images to:

* `dodopizza/centos-dev:`<branch_short_sha>

You can find image tag in the GHA workflow output

## Release

New release can be created from any branch by running [New release workflow](actions?query=workflow%3A%22Create+new+release%22) \
This release method allow to develop more than one image version simultaneously, create a fix versions between existing releases

## Documentation meta

```documentation
ttl: 30d
tags:
  - jq
  - yq
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
  - mydumper
  - xtrabackup
  - pt-online-schema-change
  - ghost
  - gh-ost
  - innotop
  - Terraform
  - packer
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
