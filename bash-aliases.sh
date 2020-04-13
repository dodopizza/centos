#!/bin/bash

alias dodo-login="az login && sft enroll && sft login"
alias k="kubectl"

function kubectx(){
    [ -n "${1}" ] && { [ "${1}" = '?' ] && { kubectl config get-contexts; return; } || kubectl config use-context ${1}; }
    [ -n "${2}" ] && { [ "${2}" = '?' ] && { kubectl get ns; return; } || kubectl config set-context --current --namespace=${2}; }
    kubectl config get-contexts | grep '\|CURRENT'
}