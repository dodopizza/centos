FROM centos:7
LABEL maintainer="Vitaly Uvarov <vitalyu@gmail.com>"

RUN     rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
        sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo' && \
        yum install -y azure-cli

RUN     yum install -y ansible && \
        curl https://bootstrap.pypa.io/get-pip.py | python && \
        pip install --upgrade pip && \
        pip install 'pywinrm>=0.3.0' 'requests-ntlm'
        
RUN     curl -C - https://pkg.scaleft.com/scaleft_yum.repo | tee /etc/yum.repos.d/scaleft.repo && \
        yes | rpm --import https://dist.scaleft.com/pki/scaleft_rpm_key.asc && \
        yum install -y scaleft-client-tools
