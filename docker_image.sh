#!/usr/bin/env bash

platforms="linux/amd64,linux/arm64"

echo "Getting latest tag version from duckdb"
duckdb_version=$(git -C build/duckdb describe --tags --abbrev=0)
image_name=ogunseye/duckdb:"${duckdb_version}"

if [ -z "$(DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect "$image_name" 2> /dev/null)" ]; then
  echo "Building for duckdb version: ${duckdb_version}"

  docker run --privileged --rm tonistiigi/binfmt --install all
  docker buildx create --use --name builder
  docker buildx inspect --bootstrap builder

  docker buildx build \
    --platform "$platforms" \
    --build-arg "DUCKDB_VERSION=${duckdb_version}" \
    -t "$image_name" --push .

  echo "Done!"
else
  echo "Latest duckdb image version already exists, version: ${duckdb_version}"
fi
