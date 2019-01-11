FROM centos:centos7.4.1708
LABEL maintainer="Vitaly Uvarov <vitalyu@gmail.com>"

RUN        yum install -y epel-release \
        && yum install -y python36 \
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

RUN        curl -C - https://pkg.scaleft.com/scaleft_yum.repo | tee /etc/yum.repos.d/scaleft.repo \
        && yes | rpm --import https://dist.scaleft.com/pki/scaleft_rpm_key.asc \
        && yum install -y scaleft-client-tools-1.36.2-1.x86_64 \
        && yum install -y openssh-clients \
        && yum clean all \
        && mkdir /root/.ssh && sft ssh-config > /root/.ssh/config
