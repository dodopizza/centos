FROM alpine:3.10.3 AS jsonnet_builder
WORKDIR /workdir
RUN apk -U add build-base git \
    && git clone https://github.com/google/jsonnet . \
    && export LDFLAGS=-static \
    && make

FROM centos:7.8.2003 AS redis_builder
WORKDIR /workdir
RUN curl -L http://download.redis.io/redis-stable.tar.gz | tar -xz \
    && cd ./redis-stable \
    && yum install -y centos-release-scl \
    && yum install -y devtoolset-7 \
    && scl enable devtoolset-7 make

FROM golang:1.15 AS ghost_builder
# 2b5d5e0 - Fix ghost issue with binary primary key - https://github.com/github/gh-ost/pull/915
RUN pwd \
    && git config --global user.email "git@dodopizza.com" \
    && git config --global user.name "DodoPizza" \
    && git clone https://github.com/github/gh-ost.git \
    && cd gh-ost/ \
    && git pull origin pull/915/head && git checkout 2b5d5e0 \
    && ./script/cibuild \
    && ls -l bin/

FROM centos:8

LABEL maintainer="Vitaly Uvarov <v.uvarov@dodopizza.com>"

COPY --from=jsonnet_builder /workdir/jsonnet /usr/local/bin/
COPY --from=jsonnet_builder /workdir/jsonnetfmt /usr/local/bin/
COPY --from=redis_builder /workdir/redis-stable/src/redis-cli /usr/local/bin/
COPY --from=ghost_builder /go/gh-ost/bin/gh-ost /usr/local/bin/

RUN dnf install -y epel-release \
    && dnf install -y python36 unzip git strace htop \
    && dnf install -y 'dnf-command(config-manager)' \
    && dnf clean all \
    && alternatives --set python /usr/bin/python3 \
    && curl https://bootstrap.pypa.io/get-pip.py | python \
    && pip install --upgrade pip \
    && pip install yq

## expect && pexpect
RUN dnf install -y expect \
    && pip install pexpect==4.7.0 \
    && dnf clean all

## Debug available versions
RUN    ( pip install 'ansible=='   || true ) \
    && ( pip install 'azure-cli==' || true )

## azure-cli
RUN dnf install -y gcc \
    && pip --no-cache-dir install 'azure-cli==2.12.1' \
    && dnf remove -y gcc

## azure kubernetes client
RUN az aks install-cli

## ansible
RUN pip --no-cache-dir install \
    'ansible==2.10.7' \
    'ansible-lint' \
    'pywinrm>=0.3.0' \
    'requests-ntlm'

## azcopy10
RUN cd /tmp/ \
    && curl -L https://aka.ms/downloadazcopy-v10-linux | tar --strip-components 1 -xz \
    && mv -f /tmp/azcopy /usr/bin/

## mysql client + percona tools
RUN dnf install -y innotop \
    && dnf install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm \
    && dnf module disable -y mysql \
    && dnf install -y percona-toolkit Percona-Server-client-57 percona-xtrabackup-24 \
    && dnf clean all

## azure mysqlpump binary (5.6 issue)
COPY bin/az-mysqlpump /usr/local/bin/

## mydumper
RUN dnf install -y \
    https://github.com/maxbube/mydumper/releases/download/v0.10.7-2/mydumper-0.10.7-2.el8.x86_64.rpm

## docker-client for dind
RUN dnf config-manager \
    --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
    && dnf install -y docker-ce-cli \
    && dnf clean all

## docker-compose for dind
RUN pip install docker-compose

## packer (hashicorp-packer)
## https://github.com/hashicorp/packer/releases
## issue: https://github.com/cracklib/cracklib/issues/7
RUN packer_version=1.7.8 \
    && curl -o /tmp/packer.zip https://releases.hashicorp.com/packer/${packer_version}/packer_${packer_version}_linux_amd64.zip \
    && unzip /tmp/packer.zip -d /tmp/ \
    && mv -f /tmp/packer /usr/bin/hashicorp-packer \
    && rm -f /tmp/packer.zip

## helm
RUN cd /tmp/ \
    && helm_version=2.11.0 \
    && curl -L https://get.helm.sh/helm-v${helm_version}-linux-amd64.tar.gz | tar zx \
    && mv -f linux-amd64/helm /usr/bin/helm${helm_version} \
    && ln -f -s /usr/bin/helm${helm_version} /usr/bin/helm \
    && rm -rf linux-amd64

## werf
## https://github.com/flant/werf/releases
RUN werf_version=1.1.23+fix50 \
    && curl -L "https://tuf.werf.io/targets/releases/${werf_version}/linux-amd64/bin/werf" -o /tmp/werf \
    && chmod +x /tmp/werf \
    && mv /tmp/werf /usr/local/bin/werf

## jq
## https://stedolan.github.io/jq/download/
RUN jq_version=1.6 \
    && curl -L https://github.com/stedolan/jq/releases/download/jq-${jq_version}/jq-linux64 -o /tmp/jq \
    && chmod +x /tmp/jq \
    && mv /tmp/jq /usr/local/bin/jq


## promtool from prometheus
## https://github.com/prometheus/prometheus/releases
RUN cd /tmp/ \
    && prometheus_version=2.30.3 \
    && curl -L https://github.com/prometheus/prometheus/releases/download/v${prometheus_version}/prometheus-${prometheus_version}.linux-amd64.tar.gz | tar zx \
    && cp -f prometheus-${prometheus_version}.linux-amd64/promtool /usr/bin/ \
    && rm -rf prometheus-${prometheus_version}.linux-amd64

## amtool from alertmanager
## https://github.com/prometheus/alertmanager/releases
RUN cd /tmp/ \
    && alertmanager_version=0.21.0 \
    && curl -L https://github.com/prometheus/alertmanager/releases/download/v${alertmanager_version}/alertmanager-${alertmanager_version}.linux-amd64.tar.gz | tar zx \
    && cp -f alertmanager-${alertmanager_version}.linux-amd64/amtool /usr/bin/ \
    && rm -rf alertmanager-${alertmanager_version}.linux-amd64

## terraform
## https://releases.hashicorp.com/terraform
RUN terraform_version=1.1.2 \
    && curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip \
    && unzip /tmp/terraform.zip -d /usr/bin/ \
    && rm -f /tmp/terraform.zip

## scaleft client
RUN curl -C - https://pkg.scaleft.com/scaleft_yum.repo | tee /etc/yum.repos.d/scaleft.repo \
    && yes | rpm --import https://dist.scaleft.com/pki/scaleft_rpm_key.asc \
    && dnf install -y scaleft-client-tools.x86_64 \
    && dnf install -y openssh-clients sshpass \
    && dnf install -y sudo \
    && dnf clean all \
    && mkdir /root/.ssh && sft ssh-config > /root/.ssh/config

## ghost-tool from dodopizza/sre-toolchain
COPY bin/ghost-tool.sh  /usr/bin/ghost-tool
RUN  ln -s /usr/bin/ghost-tool /usr/bin/gh-ost-tool

## scaleft user forwarding from host machine to container
COPY  scripts/docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]

## bash aliases
COPY scripts/bash-aliases.sh /
RUN echo -e '\nsource /bash-aliases.sh' >> ~/.bashrc

## version info for changelog
COPY scripts/version-info.sh /
RUN /version-info.sh
