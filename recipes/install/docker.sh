#! /bin/sh

# Does NOT work with $USER (why?)
# TODO: change to suit your case (and refactor to work with current user)
_USER=yassen

if uname -v | grep -iq ubuntu; then :; else
  die 15 'FATAL: Not on ubuntu, terminating'
fi

echo x"$(sudo whoami)"
if [ x"$(sudo whoami)" != xroot ]; then
  die 15 'FATAL: Not root, terminating'
fi

if curl -V >/dev/null 2>&1; then :; else
  die 15 'FATAL: curl not found, terminating'
fi

apt-get update && apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" \
 || die 14 'add-apt-repository FAILED'
apt-get update || die 14 'apt-get update FAILED'
apt install docker-ce || die 12 'apt install docker-ce FAILED'
usermod -aG docker "${_USER}"
systemctl disable docker
systemctl status docker --no-pager
docker run hello-world && echo '\nDone.' || die 12 '\nDocker installation FAILED.'
