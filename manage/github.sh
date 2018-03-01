#!/usr/bin/env bash

set -e

function list_repos {
    local org=$1
    curl --silent https://api.github.com/orgs/${org}/repos | jq -r .[].name
}

function clone_or_update_repos {
    local org=$1
    local dir=$2
    mkdir -p ${dir}
    for r in $(list_repos $1)
    do
        echo "in ${dir} updating ${r}..."
        if [ -d ${dir}/${r} ]
        then
            cd ${dir}/${r}
            git pull
        else
            cd ${dir}
            git clone git@github.com:${org}/${r}.git
        fi
    done
}

case $1 in
    org-lr)
        shift
        repos=$(list_repos $1)
        echo ${repos}
        ;;
    org-cu)
        shift
        clone_or_update_repos $1 $2
        ;;
    *)
        echo "Usage:"
        echo "    $0 org-lr [org]  -- list repos of org"
        echo "    $0 org-cu [org] [dir] -- clone or update all repos of org"
        ;;
esac

