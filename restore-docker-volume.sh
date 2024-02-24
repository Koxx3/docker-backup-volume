#!/bin/sh

DOCKER_RESTORE_VOLUME=$1
RESTORE_FILE=$2
DOCKER_IMAGE=alpine

validateInput() {
    if [ ! -f "${RESTORE_FILE}" ]; then
        echo "> Error: Restore file not found at ${RESTORE_FILE}"
        exit 1
    fi

    INSPECT_VOLUME=$(docker volume inspect ${DOCKER_RESTORE_VOLUME} 2>&1)
    if [[ ! ${INSPECT_VOLUME} == *"No such volume"* ]]; then
        echo "> Error: docker volume '${DOCKER_RESTORE_VOLUME}' already exists"
        exit 1
    fi
}

echo "> Restoring the file '${RESTORE_FILE}' to docker-volume '${DOCKER_RESTORE_VOLUME}'"
validateInput

echo "> Creating docker volume:" $(docker volume create --name ${DOCKER_RESTORE_VOLUME})

docker run --rm \
    -v ${DOCKER_RESTORE_VOLUME}:/backup-dest \
    -v ${RESTORE_FILE}:/restore-src.tar.gz ${DOCKER_IMAGE} \
    tar -xzvf /restore-src.tar.gz -C /backup-dest

echo "> Finished! Docker volume '${DOCKER_RESTORE_VOLUME}' is ready for use"
