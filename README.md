# wavelog-container

Container Images of [wavelog/wavelog](https://github.com/wavelog/wavelog), run with [`lighttpd`](https://pkgs.alpinelinux.org/packages?name=lighttpd) and [`php84-fpm`](https://pkgs.alpinelinux.org/packages?name=php84-fpm) in [Alpine](https://hub.docker.com/_/alpine/).

[![container Image CI](https://github.com/uiolee/wavelog-container/actions/workflows/ci.yml/badge.svg?event=push)](https://github.com/uiolee/wavelog-container/actions/workflows/ci.yml)
[![GitHub Tag](https://img.shields.io/github/v/tag/uiolee/wavelog-container)](https://github.com/uiolee/wavelog-container/tags)

## Images

[![docker.io Image Size)](https://img.shields.io/docker/image-size/uiolee/wavelog/main)][dockerhub]

Images avaliable in registries:

| Registry                         | Tag                                  |
| -------------------------------- | ------------------------------------ |
| [Github Packages][githubpackage] | `ghcr.io/uiolee/wavelog:2.4.1-0.1`   |
| [Docker Hub][dockerhub]          | `docker.io/uiolee/wavelog:2.4.1-0.1` |

## Compose

Example Compose file: [`./example/compose.yaml`](./example/compose.yaml)

### Example Usage

1. setup your workdir:

   ```bash
   mkdir -p ./wavelog-compose/ ./wavelog-compose/config/ ./wavelog-compose/uploads/ ./wavelog-compose/userdata/
   chown -R 1000:1000 ./wavelog-compose/config/ ./wavelog-compose/uploads/ ./wavelog-compose/userdata/
   chmod -R 2775 ./wavelog-compose/config/ ./wavelog-compose/uploads/ ./wavelog-compose/userdata/
   ```

1. cwd to your workdir:

   ```bash
   cd ./wavelog-compose/
   ```

1. copy and edit your own [`./compose.yaml`](./example/compose.yaml) at your need.

1. setup coninater via compose:

   ```bash
   podman compose up
   ```

   **or** in the Detached/background mode:

   ```bash
   podman compose up -d
   ```

[dockerhub]: https://hub.docker.com/r/uiolee/wavelog
[githubpackage]: https://github.com/uiolee/wavelog-container/pkgs/container/wavelog
