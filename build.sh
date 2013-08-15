#!/bin/bash

# Variables that define the version and commit to pull from Github
commit="c74e8e026445540143e90bd027fb074eec698ac6"
short_commit=$(echo $commit | cut -c1-7)
version="0.01"

QUIET="--quiet"
DEBUG=0
TRACE=""
DIST="all"

pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null

usage () {

cat << EOF
usage: $(basename $0) [OPTIONS]

This script builds RPMs for perl-Sun-Solaris-Kstat.

OPTIONS:

  -d, --dist      Distribution to use.
                  Valid options are 5, 6, or all.
                  Default: all
  --debug         Show debug output
  --trace         Show mock's debug output
  -h, --help      Show this message

EXAMPLE:

$(basename $0) --epel ruby rubygems

EOF
}

ARGS=`getopt -o hd: -l help,debug,trace,dist: -n "$0" -- "$@"`

[ $? -ne 0 ] && { usage; exit 1; }

eval set -- "${ARGS}"

while true; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --debug)
      DEBUG=1
      QUIET=""
      shift
      ;;
    --trace)
      TRACE="--trace"
      shift
      ;;
    -d|--dist)
      DIST="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

if [ $DEBUG -eq 1 ]; then
  set -x
fi

if [ "$DIST" -ne 6 ] 2>/dev/null && [ "$DIST" -ne 5 ] 2>/dev/null && [ "$DIST" != "all" ] 2>/dev/null; then
  echo "dist must be 5 or 6"
  usage
  exit 1
fi

resultdir="${SCRIPTPATH}/results/\"%(dist)s\"/\"%(target_arch)s\"/"
tarball="perl-Sun-Solaris-Kstat-${version}-${short_commit}.tar.gz"
repo_url="https://github.com/zfsonlinux/linux-kstat/archive/${commit}/${tarball}"

if [ ! -e ${SCRIPTPATH}/SOURCES/${tarball} ]; then
  curl -L -o ${SCRIPTPATH}/SOURCES/${tarball} ${repo_url}
fi

if [ "$DIST" == "all" ]; then
  DIST="6 5"
fi

for d in $DIST
do
  if [ "$d" -eq 5 ]; then
    DIGEST="md5"
  else
    DIGEST="sha256"
  fi

  srpm=$(rpmbuild -bs --define "dist .el${d}" --define "_source_filedigest_algorithm ${DIGEST}" --define "_binary_filedigest_algorithm ${DIGEST}" ${SCRIPTPATH}/SPECS/perl-Sun-Solaris-Kstat.spec | awk -F" " '{print $2}')

  cmd="mock -r epel-${d}-x86_64 ${QUIET} ${TRACE} --resultdir=${resultdir} --rebuild ${srpm}"
  echo "Executing: ${cmd}"
  eval $cmd
done

exit 0
