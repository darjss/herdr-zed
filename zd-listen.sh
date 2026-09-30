#!/bin/sh
# Receive "host path" lines on 127.0.0.1:9877 (reached via SSH RemoteForward)
# and open each one as a Zed remote project.
exec 9>/tmp/zed-open-listen.lock
flock -n 9 || exit 0

while true; do
  line=$(nc -l 127.0.0.1 9877 2>/dev/null) || { sleep 1; continue; }
  case $line in
    *\ *) zeditor "ssh://${line%% *}${line#* }" & ;;
  esac
done
