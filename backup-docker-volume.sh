#!/bin/sh

# Initialize variables
DOCKER_VOLUME=$1
BACKUP_DIR=$2
BACKUP_FILE="${DOCKER_VOLUME}-backup-$(date +%d-%m-%y-%H.%M.%S).tar.gz"
DOCKER_IMAGE=alpine

# Function to validate input
validateInput() {
    if [ ! -d "${BACKUP_DIR}" ]; then
        echo "> Error: backup directory doesn't exist at '${BACKUP_DIR}'"
        exit 1
    fi

    INSPECT_VOLUME=$(docker volume inspect "${DOCKER_VOLUME}" 2>&1)
    if echo "${INSPECT_VOLUME}" | grep -q "No such volume"; then
        echo "> Error: docker volume '${DOCKER_VOLUME}' not found"
        exit 1
    fi
}

# Call the function to validate inputs
validateInput

# Log the backup operation
echo "> Backing up the docker-volume '${DOCKER_VOLUME}' to '${BACKUP_DIR}/${BACKUP_FILE}'"

# Execute the docker run command to back up the volume
docker run --rm \
    -v "${DOCKER_VOLUME}:/backup-src" \
    -v "${BACKUP_DIR}:/backup-dest" ${DOCKER_IMAGE} \
    sh -c "tar -czvf /backup-dest/${BACKUP_FILE} -C /backup-src ."

# Confirmation message
echo "> Backup of docker-volume finished!"
