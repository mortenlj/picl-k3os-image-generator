#!/bin/bash

## Check if we have the necessary tools
assert_tool() {
	if [ "x$(which $1)" = "x" ]; then
		echo "Missing required dependency: $1" >&2
		exit 1
	fi
}

assert_tool yq
assert_tool docker

if [ ! -r config/secrets.yaml ]; then
  echo "== Generating secrets... =="
  cp config/secrets.yaml.template config/secrets.yaml
  yq write --inplace config/secrets.yaml "k3os.wifi.(name==Hypatia).passphrase" "$(security find-generic-password -wa Hypatia)"
  yq write --inplace config/secrets.yaml ssh_authorized_keys[+] "$(ssh-add -L | grep ibidem)"
  yq write --inplace config/secrets.yaml k3os.password "$(openssl rand -hex 20)"
  yq write --inplace config/secrets.yaml k3os.token "$(openssl rand -hex 20)"
fi

echo "== Building builder... =="
docker build -t picl-k3os-image-generator:latest .

echo "== Building image... =="
mkdir -p build deps
docker run --privileged --rm -ti \
  --mount type=bind,src=${PWD}/build,dst=/builder/build \
  --mount type=bind,src=${PWD}/deps,dst=/builder/deps \
  picl-k3os-image-generator:latest ./build-image.sh raspberrypi
