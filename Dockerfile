FROM alpine:3.10.3 AS jsonnet_builder
WORKDIR /workdir
RUN apk -U add build-base git \
    && git clone https://github.com/google/jsonnet . \
    && export LDFLAGS=-static \
    && make

FROM centos:7.7.1908 AS redis_builder
WORKDIR /workdir
RUN curl -L http://download.redis.io/redis-stable.tar.gz | tar -xz \
    && cd ./redis-stable \
    && yum install -y centos-release-scl \
    && yum install -y devtoolset-7 \
    && scl enable devtoolset-7 make

FROM centos:7.7.1908
LABEL maintainer="Vitaly Uvarov <v.uvarov@dodopizza.com>"

COPY --from=jsonnet_builder /workdir/jsonnet /usr/local/bin/
COPY --from=jsonnet_builder /workdir/jsonnetfmt /usr/local/bin/
COPY --from=redis_builder /workdir/redis-stable/src/redis-cli /usr/local/bin/

RUN yum install -y epel-release \
    && yum install -y python36 jq unzip git strace htop \
    && yum clean all \
    && alternatives --install /usr/bin/python python /usr/bin/python2.7 50 \
    && alternatives --install /usr/bin/python python /usr/bin/python3.6 60 \
    && alternatives --set python /usr/bin/python2.7 \
    && curl https://bootstrap.pypa.io/get-pip.py | python2.7 \
    && curl https://bootstrap.pypa.io/get-pip.py | python3.6 \
    && pip install --upgrade pip

## expect && pexpect
RUN yum install -y expect \
    && pip2 install pexpect==4.7.0 \
    && pip3 install pexpect==4.7.0 \
    && yum clean all

## Debug available versions
RUN (    pip install 'ansible==' || true ) \
    && ( pip install 'azure-cli==' || true )

## azure-cli classic install on default python2
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc \
    && echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo \
    && yum install -y azure-cli \
    && yum clean all

## azure kubernetes client
RUN az aks install-cli

## ansible
RUN pip --no-cache-dir install \
    'ansible==2.9.10' \
    'ansible-lint' \
    'pywinrm>=0.3.0' \
    'requests-ntlm'

## azcopy10
RUN cd /tmp/ \
    && curl -L https://aka.ms/downloadazcopy-v10-linux | tar --strip-components 1 -xz \
    && mv -f /tmp/azcopy /usr/bin/

## mysql client + percona tools
RUN yum install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm \
    && yum list | grep percona \
    && yum install -y Percona-Server-client-57 percona-xtrabackup percona-toolkit innotop \
    && yum clean all

## drone ci
RUN drone_version=1.2.1 \
    && curl -L https://github.com/drone/drone-cli/releases/download/v${drone_version}/drone_linux_amd64.tar.gz | tar zx \
    && chmod +x ./drone \
    && mv ./drone /usr/bin/

## azure mysqlpump binary (5.6 issue)
COPY bin/az-mysqlpump /usr/local/bin/

## docker-client for dind
RUN yum-config-manager \
    --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
    && yum install -y docker-client \
    && yum-config-manager --disable docker-ce \
    && rm -rf /var/cache/yum/* \
    && rm -f /etc/yum.repos.d/docker-ce.repo \
    && yum clean all

## docker-compose for dind
RUN pip install docker-compose

## packer (hashicorp-packer) 
## https://github.com/hashicorp/packer/releases
## issue: https://github.com/cracklib/cracklib/issues/7
RUN packer_version=1.6.0 \
    && curl -o /tmp/packer.zip https://releases.hashicorp.com/packer/${packer_version}/packer_${packer_version}_linux_amd64.zip \
    && unzip /tmp/packer.zip -d /tmp/ \
    && mv -f /tmp/packer /usr/bin/hashicorp-packer \
    && rm -f /tmp/packer.zip

## bin/pt-online-schema-change temporary patch
RUN pt-online-schema-change --version || true
COPY bin/pt-online-schema-change-3.0.14-dev /usr/bin/pt-online-schema-change

## bin/gh-ost temporary patch
COPY bin/gh-ost /usr/bin/gh-ost

## helm
RUN cd /tmp/ \
    && helm_version=2.11.0 \
    && curl -L https://get.helm.sh/helm-v${helm_version}-linux-amd64.tar.gz | tar zx \
    && mv -f linux-amd64/helm /usr/bin/helm${helm_version} \
    && ln -f -s /usr/bin/helm${helm_version} /usr/bin/helm \
    && rm -rf linux-amd64

## werf
## https://github.com/flant/werf/releases
RUN werf_version=1.1.20+fix1 \
    && curl -L https://dl.bintray.com/flant/werf/v${werf_version}/werf-linux-amd64-v${werf_version} -o /tmp/werf \
    && chmod +x /tmp/werf \
    && mv /tmp/werf /usr/local/bin/werf

## promtool from prometheus
## https://github.com/prometheus/prometheus/releases
RUN cd /tmp/ \
    && prometheus_version=2.19.1 \
    && curl -L https://github.com/prometheus/prometheus/releases/download/v${prometheus_version}/prometheus-${prometheus_version}.linux-amd64.tar.gz | tar zx \
    && cp -f prometheus-${prometheus_version}.linux-amd64/promtool /usr/bin/ \
    && rm -rf prometheus-${prometheus_version}.linux-amd64

## terraform
RUN terraform_version=0.12.26 \
    && curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip \
    && unzip /tmp/terraform.zip -d /usr/bin/ \
    && rm -f /tmp/terraform.zip

## scaleft client
RUN curl -C - https://pkg.scaleft.com/scaleft_yum.repo | tee /etc/yum.repos.d/scaleft.repo \
    && yes | rpm --import https://dist.scaleft.com/pki/scaleft_rpm_key.asc \
    && yum install -y scaleft-client-tools.x86_64 \
    && yum install -y openssh-clients sshpass \
    && yum install -y sudo \
    && yum clean all \
    && mkdir /root/.ssh && sft ssh-config > /root/.ssh/config

## scaleft user forwarding from host machine to container
COPY  scripts/docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]

## bash aliases
COPY scripts/bash-aliases.sh /
RUN echo -e '\nsource /bash-aliases.sh' >> ~/.bashrc

## ---------------------------------------------------------------------------

## VERSION INFO FOR CHANGELOG
RUN echo '-------------------------------' \
    && jq --version \
    && git --version \
    && jsonnet --version \
    && redis-cli --version \
    && python --version \
    && python3.6 --version \
    && pip2 --version \
    && pip3 --version \
    && ( az --version 2> /dev/null ) | head -n 1 \
    && echo -n "kubectl: " && kubectl version --client=true --short=true \
    && ansible --version | head -n 1 \
    && ansible-lint --version \
    && azcopy --version \
    && mysql --version \
    && mysqldump --version \
    && mysqlpump --version \
    && xtrabackup --version \
    && pt-online-schema-change --version \
    && echo -n "gh-ost: " && gh-ost --version \
    && innotop --version \
    && terraform --version \
    && echo -n "packer (hashicorp-packer): " && hashicorp-packer --version \
    && ( drone --version || true ) \
    && sft --version \
    && az-mysqlpump --version \
    && docker --version \
    && docker-compose --version \
    && echo -n "helm: " && helm version --client --short \
    && echo -n "werf: " && werf version \
    && ( promtool --version 2>&1 | grep promtool ) \
    && echo '-------------------------------'
