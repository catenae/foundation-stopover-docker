#!/bin/bash
source env.sh
docker build \
--build-arg ROCKSDB_VERSION=$ROCKSDB_VERSION \
-t catenae/stopover-foundation:ubuntu .
docker tag catenae/stopover-foundation:ubuntu catenae/stopover-foundation:latest
