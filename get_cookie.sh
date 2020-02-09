#!/bin/bash
for i in "$@"
do
  echo "$i"
done |awk '/^Cookie/ {print "COOKIE:="$0}' > cookie.mk
