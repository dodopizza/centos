FROM gcc:6 AS jsonnet_builder
WORKDIR /workdir
RUN git clone https://github.com/google/jsonnet . \
    && export LDFLAGS=-static \
    && make

FROM centos:centos7.4.1708 AS redis_builder
WORKDIR /workdir
RUN yum install -y gcc make \
    && curl -L http://download.redis.io/redis-stable.tar.gz | tar -xz \
    && cd ./redis-stable \
    && make

FROM centos:centos7.4.1708
LABEL maintainer="Vitaly Uvarov <v.uvarov@dodopizza.com>"

RUN yum install -y epel-release \
    && yum install -y python36 jq unzip \
    && yum clean all \
    && curl https://bootstrap.pypa.io/get-pip.py | python36 \
    && pip3 install --upgrade pip

## Getting available versions of packages for debug
# RUN ( pip3 install 'ansible==' || true )

RUN pip3 --no-cache-dir install \
    'azure>=2.0.0' \
    'azure-cli>=2.0.0' \
    'ansible==2.7.4' \
    'pywinrm>=0.3.0' \
    'requests-ntlm'  \
    'ansible-lint'

## azcopy: https://docs.microsoft.com/ru-ru/azure/storage/common/storage-use-azcopy-linux
RUN yum install -y libunwind icu \
    && yum clean all \
    && cd /srv/ \
    && curl -L https://aka.ms/downloadazcopylinux64 | tar -xz \
    && ./install.sh \
    && rm -f ./install.sh \
    && ln -f -s /srv/azcopy/azcopy /usr/bin/azcopy

## Set python36 as python, but yum uses python2, so change the script
RUN ln -f -s /usr/bin/python36 /usr/bin/python \
    && sed -i 's/python$/python2/' {/usr/bin/yum,/usr/libexec/urlgrabber-ext-down}

RUN yum install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm \
    && yum list | grep percona \
    && yum install -y Percona-Server-client-57 percona-xtrabackup percona-toolkit \
    && yum clean all

RUN curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.12.0-beta1/terraform_0.12.0-beta1_linux_amd64.zip \
    && unzip /tmp/terraform.zip -d /usr/bin/ \
    && mv /usr/bin/terraform{,12} \
    && rm -f /tmp/terraform.zip

RUN curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip \
    && unzip /tmp/terraform.zip -d /usr/bin/ \
    && rm -f /tmp/terraform.zip

RUN curl -L https://github.com/drone/drone-cli/releases/download/v0.8.6/drone_linux_amd64.tar.gz | tar zx \
    && install -t /usr/local/bin drone

RUN curl -C - https://pkg.scaleft.com/scaleft_yum.repo | tee /etc/yum.repos.d/scaleft.repo \
    && yes | rpm --import https://dist.scaleft.com/pki/scaleft_rpm_key.asc \
    && yum install -y scaleft-client-tools-1.38.5-1.x86_64 \
    && yum install -y openssh-clients \
    && yum clean all \
    && mkdir /root/.ssh && sft ssh-config > /root/.ssh/config

COPY --from=jsonnet_builder /workdir/jsonnet /usr/local/bin/

COPY --from=redis_builder /workdir/redis-stable/src/redis-cli /usr/local/bin/

COPY bin/az-mysqlpump /usr/local/bin/