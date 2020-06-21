#!/bin/bash
source env.sh
docker build \
--build-arg ROCKSDB_VERSION=$ROCKSDB_VERSION \
-t catenae/foundation-stopover .
