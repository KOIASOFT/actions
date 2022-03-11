#!/bin/bash
test -n "$TARGET"         || { echo "Variable 'TARGET' missing"; exit 1; }

export account=$(cut -d '-' -f 1,2 <<< "$TARGET")
export environment=$(cut -d '-' -f 3- <<< "$TARGET")

