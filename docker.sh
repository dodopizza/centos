#!/bin/bash
set -eu

function usage(){ echo "Usage: $(basename $0) <build|push> <tag> [message]" && exit 1; }
[ $# -lt 1 ] && usage;

repo=dodopizza/centos

action=${1:-'build'}
tag=${2:-'latest'}
message=${1:-"${tag}"}

echo "[~] Build with tag '${tag}'"

case "${action}" in
    build )
            docker build --rm -f "Dockerfile" -t ${repo}:${tag} .
            docker build --rm -f "sftd-host-mapping/Dockerfile" -t ${repo}:${tag}-sftd-host-mapping ./sftd-host-mapping
            ;;
    push  )
            docker push ${repo}:${tag}
            docker push ${repo}:${tag}-sftd-host-mapping
            ;;
    *     )
            usage
            ;;
esac

echo "[.] All Done"