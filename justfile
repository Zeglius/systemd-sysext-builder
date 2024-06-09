#!/usr/bin/env -S just --justfile

export CONTAINERMGR := "docker"

_default:
    just --list

_select-target:
    #!/usr/bin/bash
    set -eo pipefail
    TARGET=""
    select RES in $(basename $(ls -d ./examples/*/)); do
        TARGET="$RES"
        if [[ -z $TARGET ]]; then
            echo "Invalid option"
            continue
        fi
        break
    done
    echo $TARGET

build $TARGET="":
    #!/usr/bin/bash
    set -euxo pipefail
    [[ -z $TARGET ]] && TARGET=$(just _select-target)
    CONTEXTDIR=./examples/$TARGET
    ${CONTAINERMGR} build -f ${CONTEXTDIR}/Containerfile -t ${TARGET}-sysext ${CONTEXTDIR}

build-tar $TARGET="":
    #!/usr/bin/bash
    set -euxo pipefail
    [[ -z ${TARGET} ]] && TARGET=$(just _select-target)
    just build ${TARGET}
    mkdir -p ./out/
    imgname=${TARGET}-sysext
    imgid=$(docker image ls -q ${imgname})
    [[ -z $imgid ]] && {
        echo >&2 "ERROR: ${CONTAINERMGR} image '${imgname}' not found"
        echo >&2 "\tBuild with 'just build ${TARGET}'"
        exit 1
    }
    containerid=$(${CONTAINERMGR} create ${imgid} :)
    trap "docker rm ${containerid}" EXIT
    ${CONTAINERMGR} export ${containerid} > ./out/${imgname}.tar
