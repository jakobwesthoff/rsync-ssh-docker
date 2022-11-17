#!/bin/sh

set -eu

SSH_KEY_DIR=/etc/ssh/keys

# Initialize unique server keys
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
fi
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ''
fi

# Restrict access from other users
chmod 600 /etc/ssh/ssh_host_ed25519_key || true
chmod 600 /etc/ssh/ssh_host_rsa_key || true

# Initialize container volume on first run
if [ ! -f ~/.is_initialized ]; then
    GROUPID="${GROUPID:-1000}"
    USERID="${USERID:-1000}"
    USER="${USERNAME:-$GITHUB_USER}"
    GROUP="${GROUPNAME:-sshuser}"

    # Create user, group and authorized_keys
    addgroup -g "$GROUPID" "$GROUP"
    adduser -G "$GROUP" --uid "$USERID" -s /bin/sh -D "$USER"
    echo "$USER":"$(head -c30 /dev/urandom | base64)" | chpasswd
    mkdir /home/"$USER"/.ssh
    if [ ! -z "${GITHUB_USER:-}" ]; then
        wget -q -O /home/"$USER"/.ssh/authorized_keys https://github.com/"$GITHUB_USER".keys
    fi
    echo "${SSH_KEY:-}" >> /home/"$USER"/.ssh/authorized_keys
    chown -R "$USER":"$GROUP" /home/"$USER"/.ssh
    chmod -R go-wx /home/"$USER"/.ssh
    ln -s "/data" "/home/$USER/data"
	touch ~/.is_initialized
fi

exec /usr/sbin/sshd -eD
