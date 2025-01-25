#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ] || [ $# -ne 1 ]; then
    echo "Usage: $0 <container_name>"
    exit 1
fi

# Assign the argument to a variable
CONTAINER_NAME="$1"
IMAGE_NAME=${CONTAINER_NAME}-dev-environment:latest

# check if the image exists, and create it if not
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "Docker image '$IMAGE_NAME' not found. Building..."

    # Ensure a Dockerfile exists before building
    if [ ! -f "./Dockerfile" ]; then
        echo "Error: No Dockerfile found in the current directory."
        exit 1
    fi

    docker build --build-arg HOST_UID=$(id -u) -t "$IMAGE_NAME" .
    if [ $? -ne 0 ]; then
        echo "Error: Failed to build the Docker image."
        exit 1
    fi
fi

# Check if the 'workspace' and 'config' directories exists, create it if not
# if [ ! -d "workspace" ]; then
    # echo "Creating 'workspace' directory..."
    # mkdir workspace
# fi

# create "attach.sh" script for attaching to detached container
printf "#!/bin/bash\ndocker exec -it ${CONTAINER_NAME}-dev-container /usr/bin/fish" > attach.sh
chmod +x attach.sh

# create docker volume
VOLUME_NAME="${CONTAINER_NAME}-workspace-volume"
if ! docker volume inspect "$VOLUME_NAME" > /dev/null 2>&1; then
    echo "Creating docker volume..."
    docker volume create ${CONTAINER_NAME}-workspace-volume
else
    echo "Volume $VOLUME_NAME already exists."
fi

# Run the Docker container
docker run -d --net=host \
    --platform linux/amd64 \
    --env DISPLAY=$DISPLAY \
    --volume /tmp/.X11-unix:/tmp/.X11-unix \
    --volume ~/.ssh:/home/ubuntu/.ssh \
    --volume ${VOLUME_NAME}:/home/ubuntu/workspace \
    --name "${CONTAINER_NAME}-dev-container" \
    "${CONTAINER_NAME}-dev-environment:latest"
