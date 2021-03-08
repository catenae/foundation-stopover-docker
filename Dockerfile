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

FROM labteral/easyrocks
RUN \
    apt-get update \
    && dpkg-query -Wf '${Package}\n' | sort > init_pkgs \
    && apt-get -y install build-essential \
    && dpkg-query -Wf '${Package}\n' | sort > current_pkgs \
    && pip install --upgrade pip \
    && pip install \
    "stopover>=21.3.5" \
    "orderedset==2.0.3" \
    && apt-get -y purge $(diff -u init_pkgs current_pkgs | grep -E "^\+" | cut -d + -f2- | sed -n '1!p' | uniq) \
    && apt-get clean
ENV CATENAE_DOCKER=true
WORKDIR /opt/catenae
ENTRYPOINT ["python"]
