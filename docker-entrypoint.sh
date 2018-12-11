#!/bin/bash
set -eu

# For ScaleFT Host maching user mapping
# Requirements:
#   docker run \
#     -e "SFT_USER_ID=$(id -u)" \
#     -e "SFT_USER_NAME=$(id -un)" \
#     -v /var/run/sftd/management.sock:/var/run/sftd/management.sock
#     ..
#
if [ -z ${SFT_USER_ID:-''} ] && [ -z ${SFT_USER_NAME:-''} ]
then
  useradd -u ${ENV_TC_AGENT_UID} -g root ${SFT_USER_NAME}
  su ${SFT_USER_NAME} -c "
    install -d ~/.ssh/
    sft ssh-config > ~/.ssh/config
    sft config service_auth.enable true
  "
fi
# - For ScaleFT

exec "$@"
