#!/bin/bash
docker run -it --rm -w /workdir -v "$(PWD):/workdir" docker-az-ansible