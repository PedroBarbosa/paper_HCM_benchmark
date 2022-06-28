#! /bin/sh
export BUILDAH_FORMAT=docker
docker build . -t hcm_eval
