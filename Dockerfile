FROM centos:7
LABEL version=0.0
WORKDIR /workdir
RUN echo 'echo Testapp' > /version-info.sh && chmod +x /version-info.sh