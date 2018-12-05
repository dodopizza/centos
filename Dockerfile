FROM centos:7
LABEL maintainer="Vitaly Uvarov <vitalyu@gmail.com>"

RUN        yum install -y epel-release \
        && yum install -y python36 \
        && yum clean all \
        && curl https://bootstrap.pypa.io/get-pip.py | python36 \
        && pip3 install --upgrade pip \
        && ln -fs /usr/bin/python36 /usr/bin/python

           # Getting available versions of packages for debug
RUN        ( pip3 --no-deps 'ansible=='   || true ) \ 
        && ( pip3 --no-deps 'azure-cli==' || true ) 

RUN        pip3 --no-cache-dir install \
                'ansible==2.7.4' \
                'pywinrm>=0.3.0' \
                'requests-ntlm'  \
                'azure-cli'

RUN        curl -C - https://pkg.scaleft.com/scaleft_yum.repo | tee /etc/yum.repos.d/scaleft.repo \
        && yes | rpm --import https://dist.scaleft.com/pki/scaleft_rpm_key.asc \
        && yum install -y scaleft-client-tools \
        && yum install -y openssh-clients \
        && mkdir /root/.ssh && sft ssh-config > /root/.ssh/config \
        && yum clean all
