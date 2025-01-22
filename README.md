# Basic Dev Environment

This is a repository which provides the Dockerfile for basic development environment.

## Usage

1. Firstly, we have to build the image on the host<br>
    `./create.sh <container name you want>`
2. Secondly, we attach on the container with fish shell<br>
    `./attach.sh`
3. If you want to delete both stopped container and the image, execute the command<br>
    `./delete.sh`