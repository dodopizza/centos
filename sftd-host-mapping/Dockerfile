FROM vitalyu/az-ansible:latest
LABEL maintainer="Vitaly Uvarov <vitalyu@gmail.com>"

RUN   yum install -y sudo && yum clean all
COPY  docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/bin/bash"]
