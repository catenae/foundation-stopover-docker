# Catenae Stopover base image
# Copyright (C) 2017-2020 Rodrigo Martínez <dev@brunneis.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

FROM brunneis/python:3.9

ARG ROCKSDB_VERSION

# Build rocksdb
RUN \
    ROCKSDB_BASE_URL=https://github.com/facebook/rocksdb/archive \
    && apt-get update \
    && dpkg-query -Wf '${Package}\n' | sort > init_pkgs \
    && apt-get -y install \
    build-essential \
    curl \
    && dpkg-query -Wf '${Package}\n' | sort > current_pkgs \
    && apt-get install -y \
    libgflags-dev \
    libsnappy-dev \
    zlib1g-dev \
    libbz2-dev \
    liblz4-dev \
    libzstd-dev \
    && curl -L $ROCKSDB_BASE_URL/v$ROCKSDB_VERSION.tar.gz -o rocksdb.tar.gz -s \
    && tar xf rocksdb.tar.gz \
    && cd rocksdb-$ROCKSDB_VERSION \
    && DEBUG_LEVEL=0 make shared_lib install-shared \
    && cd .. \
    && rm -r rocksdb-$ROCKSDB_VERSION \
    && rm rocksdb.tar.gz

# Fix for Python 3.9
RUN \
    curl -L https://github.com/cburgdorf/rusty-rlp/releases/download/0.1.15/rusty_rlp-0.1.15-cp38-cp38-manylinux1_x86_64.whl -o rusty_rlp-0.1.15-py3-none-any.whl -s \
    && pip install rusty_rlp-0.1.15-py3-none-any.whl

RUN \
    pip install --upgrade pip \
    && pip install \
    cython==0.29.20 \
    easyrocks \
    stopover>=0.0.6b0 \
    orderedset \
    easyweb3 \
    && apt-get -y purge $(diff -u init_pkgs current_pkgs | grep -E "^\+" | cut -d + -f2- | sed -n '1!p' | uniq) \
    && apt-get clean \
    && rm -rf init_pkgs current_pkgs /root/.cache/pip \
    && find / -type d -name __pycache__ -exec rm -r {} \+ \
    && echo "tcp 6 TCP\nudp 17 UDP" >> /etc/protocols

ENV \
    LD_LIBRARY_PATH=/usr/local/lib \
    CATENAE_DOCKER=true

WORKDIR /opt/catenae
ENTRYPOINT ["python"]
