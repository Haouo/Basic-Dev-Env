# Basic Dev Environment

This is a repository which provides the Dockerfile for basic development environment.

## Usage

1. At the beginning, we have to build the image on the host<br>
    `./create.sh <container name you want>`
2. After executing create.sh, it will generate `attach.sh` automatically, then you can now attach to the container via execute `attach.sh`<br>
    `./attach.sh`
