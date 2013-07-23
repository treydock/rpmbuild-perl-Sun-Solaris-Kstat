#!/bin/bash

commit="c74e8e026445540143e90bd027fb074eec698ac6"
short_commit=$(echo $commit | cut -c1-7)
version="0.01"

tarball="perl-Sun-Solaris-Kstat-${version}-${short_commit}.tar.gz"
repo_url="https://github.com/zfsonlinux/linux-kstat/archive/${commit}/${tarball}"

if [ ! -e SOURCES/${tarball} ]; then
  curl -L -o SOURCES/${tarball} ${repo_url}
fi

out=$(rpmbuild -bs perl-Sun-Solaris-Kstat.spec)
srpm=$(echo $out | awk -F" " '{print $2}')

mock -r epel-6-x86_64 --rebuild ${srpm}

exit 0
