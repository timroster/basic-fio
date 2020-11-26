FROM amd64/centos:centos8

RUN  yum install -y fio && \
     yum clean all -y 

COPY run.sh /opt/fio/run.sh

RUN mkdir /data && \
    chgrp -R 0 /opt/fio /data && \
    chmod -R g=u /opt/fio /data

WORKDIR /data

USER 1001

VOLUME ["/data"]

CMD ["/opt/fio/run.sh"]
