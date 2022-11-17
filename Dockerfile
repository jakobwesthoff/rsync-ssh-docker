FROM alpine:latest

RUN apk add --no-cache bash mc rsync openssh && \
    mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key*

COPY sshd_config /etc/ssh/sshd_config

#RUN grep HostKey /etc/ssh/sshd_config && \
#    grep PermitRootLogin /etc/ssh/sshd_config && \
#    grep PasswordAuthentication /etc/ssh/sshd_config

ADD sshd.sh /usr/local/bin/
RUN chmod uog+x "/usr/local/bin/sshd.sh"

EXPOSE 22
ENTRYPOINT ["/usr/local/bin/sshd.sh"]
