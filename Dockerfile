FROM alpine:3.10.3 AS jsonnet_builder
WORKDIR /workdir
RUN apk -U add build-base git \
    && git clone https://github.com/google/jsonnet . \
    && export LDFLAGS=-static \
    && make

FROM centos:7.6.1810 AS redis_builder
WORKDIR /workdir
RUN yum install -y gcc make \
    && curl -L http://download.redis.io/redis-stable.tar.gz | tar -xz \
    && cd ./redis-stable \
    && make

FROM centos:7.6.1810
LABEL maintainer="Vitaly Uvarov <v.uvarov@dodopizza.com>"

COPY --from=jsonnet_builder /workdir/jsonnet /usr/local/bin/
COPY --from=jsonnet_builder /workdir/jsonnetfmt /usr/local/bin/
COPY --from=redis_builder /workdir/redis-stable/src/redis-cli /usr/local/bin/

RUN yum install -y epel-release \
    && yum install -y python36 jq unzip \
    && yum clean all \
    && alternatives --install /usr/bin/python python /usr/bin/python2.7 50 \
    && alternatives --install /usr/bin/python python /usr/bin/python3.6 60 \
    && alternatives --set python /usr/bin/python2.7 \
    && curl https://bootstrap.pypa.io/get-pip.py | python3.6 \
    && pip install --upgrade pip

## Debug available versions
RUN (    pip install 'ansible==' || true ) \
    && ( pip install 'azure-cli==' || true )

## azure-cli classic install on default python2
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc \
    && echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo \
    && yum install -y azure-cli \
    && yum clean all

## ansible
RUN pip --no-cache-dir install \
    'ansible==2.8.6' \
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
    && yum install -y Percona-Server-client-57 percona-xtrabackup percona-toolkit \
    && yum clean all

# ## terraform
RUN curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.12.12/terraform_0.12.12_linux_amd64.zip \
    && unzip /tmp/terraform.zip -d /usr/bin/ \
    && rm -f /tmp/terraform.zip

## drone ci
RUN curl -L https://github.com/drone/drone-cli/releases/download/v1.2.0/drone_linux_arm64.tar.gz | tar zx \
    && mv drone /usr/bin/

## azure mysqlpump binary (5.6 issue)
COPY bin/az-mysqlpump /usr/local/bin/

## azure kubernetes client
RUN az aks install-cli

## scaleft client
RUN curl -C - https://pkg.scaleft.com/scaleft_yum.repo | tee /etc/yum.repos.d/scaleft.repo \
    && yes | rpm --import https://dist.scaleft.com/pki/scaleft_rpm_key.asc \
    && yum install -y scaleft-client-tools.x86_64 \
    && yum install -y openssh-clients \
    && yum install -y sudo \
    && yum clean all \
    && mkdir /root/.ssh && sft ssh-config > /root/.ssh/config

## scaleft user forwarding from host machine to container
COPY  docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]

## ----------------------------------------------------------------------------

## VERSION INFO FOR CHANGELOG
RUN echo '------------------------------' \
    && jsonnet --version \
    && redis-cli --version \
    && python --version \
    && python3.6 --version \
    && az --version | head -n 1 \
    && ansible --version | head -n 1 \
    && ansible-lint --version \
    && azcopy --version \
    && mysql --version \
    && mysqldump --version \
    && mysqlpump --version \
    && xtrabackup --version \
    && pt-online-schema-change --version \
    && drone --version \
    && sft --version \
    && az-mysqlpump --version \
    && echo -n "kubectl: " && kubectl version --client=true --short=true \
    && echo '------------------------------'

## bash aliases
RUN echo $' \n\
    alias k="kubectl" \n\
    alias dodologin="az login && sft enroll && sft login)" \n\
    ' >> ~/.bashrc