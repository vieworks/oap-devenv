#!/usr/bin/env bash

set -e
P=`realpath $0`
BASE=`dirname ${P}`/..

function update_env {
    local dir=$1
    for d in `ls ${dir}`
    do
        if [ ! ${d} == 'oap-devenv' ]
        then
            local project_dir=${dir}/${d}
            echo "processing ${project_dir}..."
            if [ -f ${project_dir}/pom.xml ]
            then
                for f in `cat ${BASE}/manage/INSTALL`
                do
                    if [ ! -f ${project_dir}/${f} ]
                    then
                        echo "install ${f}..."
                        mkdir -p ${project_dir}/`dirname ${f}`
                        cp ${BASE}/${f} ${project_dir}/`dirname ${f}`
                        ( cd ${project_dir} && git add ${f} )
                    fi
                done
                for f in `cat ${BASE}/manage/UPDATE`
                do
                    echo "update ${f}..."
                    mkdir -p ${project_dir}/`dirname ${f}`
                    cp ${BASE}/${f} ${project_dir}/`dirname ${f}`
                    ( cd ${project_dir} && git add ${f} )
                done
            fi
            (cd ${project_dir} && [  "1" == `git status -uno | grep -c "nothing to commit"` ] || git commit -m "update devenv" && git push)
        fi
    done
}

case $1 in
    update)
        shift
        update_env $1
    ;;
    *)
        echo "Usage:"
        echo "    $0 update [dir]  -- update environment in repos listed in dir"
     ;;
esac