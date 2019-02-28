FROM gcc:6 AS jsonnet_builder
WORKDIR    /workdir
RUN        git clone https://github.com/google/jsonnet . \
        && export LDFLAGS=-static \
        && make


FROM centos:centos7.4.1708
LABEL maintainer="Vitaly Uvarov <vitalyu@gmail.com>"

RUN        yum install -y epel-release \
        && yum install -y python36 unzip \
        && yum clean all \
        && curl https://bootstrap.pypa.io/get-pip.py | python36 \
        && pip3 install --upgrade pip

           # Getting available versions of packages for debug
RUN        ( pip3 --no-deps 'ansible=='   || true ) \ 
        && ( pip3 --no-deps 'azure-cli==' || true ) 

RUN     rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
        sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo' && \
        yum install -y azure-cli && \
        yum clean all

RUN     pip3 --no-cache-dir install \
           'ansible==2.7.4' \
           'pywinrm>=0.3.0' \
           'requests-ntlm' \
           'ansible-lint'

RUN        curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip \
        && unzip /tmp/terraform.zip -d /usr/bin/ \
        && rm -f /tmp/terraform.zip

RUN        curl -L https://github.com/drone/drone-cli/releases/download/v0.8.6/drone_linux_amd64.tar.gz | tar zx \
        && install -t /usr/local/bin drone

RUN        curl -C - https://pkg.scaleft.com/scaleft_yum.repo | tee /etc/yum.repos.d/scaleft.repo \
        && yes | rpm --import https://dist.scaleft.com/pki/scaleft_rpm_key.asc \
        && yum install -y scaleft-client-tools-1.36.2-1.x86_64 \
        && yum install -y openssh-clients \
        && yum clean all \
        && mkdir /root/.ssh && sft ssh-config > /root/.ssh/config

COPY    --from=jsonnet_builder /workdir/jsonnet /usr/local/bin/