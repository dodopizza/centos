#!/bin/bash
set -eu

# For ScaleFT Host machine user mapping
#   Requirements:
#     docker run \
#       -e "SFT_USER_ID=$(id -u)" \
#       -e "SFT_USER_NAME=$(id -un)" \
#       -v /var/run/sftd/management.sock:/var/run/sftd/management.sock
#       ..
#
if [ ! -z ${SFT_USER_ID:-''} ] && [ ! -z ${SFT_USER_NAME:-''} ]; then
  useradd -u ${SFT_USER_ID} -g root ${SFT_USER_NAME}
  su -l ${SFT_USER_NAME} -c "
    whoami
    install -d ~/.ssh/
    sft ssh-config > ~/.ssh/config
    sft config service_auth.enable true >/dev/null
  "

  if [ $# -gt 0 ]; then
    su -l ${SFT_USER_NAME} -c "$@"
  else
    su -l ${SFT_USER_NAME}
  fi

  exit $?
fi

## When logged from root user (default point)
echo "Logged from $(whoami)"
exec "$@"
