FROM alpine:3.12

RUN apk add -U \
    openssh-server \
    rsync \ 
    mc \
    && rm -f /var/cache/apk/*

RUN sed -i 's/[#\s]*PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/[#\s]*PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -ri 's/[#\s]*HostKey \/etc\/ssh\/(.+)/HostKey \/etc\/ssh\/keys\/\1/' /etc/ssh/sshd_config

#RUN grep HostKey /etc/ssh/sshd_config && \
#    grep PermitRootLogin /etc/ssh/sshd_config && \
#    grep PasswordAuthentication /etc/ssh/sshd_config

VOLUME ["/etc/ssh/keys/"]
ADD sshd.sh /usr/local/bin/
RUN chmod uog+x "/usr/local/bin/sshd.sh"

EXPOSE 22
ENTRYPOINT ["/usr/local/bin/sshd.sh"]
