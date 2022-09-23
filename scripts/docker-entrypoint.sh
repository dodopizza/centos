#!/bin/bash
set -eu

## Default entrypoint
exec "$@"
exit $?
