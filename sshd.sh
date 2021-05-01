#!/bin/sh

set -eu

SSH_KEY_DIR=/etc/ssh/keys

# Initialize separate volume /etc/ssh: Create sshd host keys
[ -f $SSH_KEY_DIR/ssh_host_rsa_key ] || /usr/bin/ssh-keygen -q -t rsa -f $SSH_KEY_DIR/ssh_host_rsa_key -C '' -N ''
[ -f $SSH_KEY_DIR/ssh_host_ecdsa_key ] || /usr/bin/ssh-keygen -q -t ecdsa -f $SSH_KEY_DIR/ssh_host_ecdsa_key -C '' -N ''
[ -f $SSH_KEY_DIR/ssh_host_ed25519_key ] || /usr/bin/ssh-keygen -q -t ed25519 -f $SSH_KEY_DIR/ssh_host_ed25519_key -C '' -N ''

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
