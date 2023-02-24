#!/bin/bash

set -e

ME=$(basename $0)

remove_old_cache_files() {
  if [[ -z "${VARNISH_STORAGE}" ]]; then
    echo >&3 "$ME: No env VARNISH_STORAGE found"
    return 0;
  fi

  IFS=, read -r backend path size <<< "$(echo $VARNISH_STORAGE | cut -d '=' -f2-)"

  if [[ $backend != "file" ]]; then
    echo >&3 "$ME: No storage backend of type file found, done"
    return 0
  fi

  rm -f $path;

  echo >&3 "$ME: Removed $path"
}

remove_old_cache_files

exit 0