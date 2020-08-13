FROM alpine:3.10.3 
LABEL version_prefix=0.0
WORKDIR /workdir
RUN echo 'echo Testapp' > /version-info.sh && chmod +x /version-info.sh