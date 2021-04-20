#!/bin/bash

declare -a TEMPLLIST=("temp_strage.yaml")
i=1
i_max=10

## main-loop
while test "${i}" -lt "${i_max}"
do
  r="$((${i} % ${#TEMPLLIST[@]}))"  ## r <= 0 or 1
  n="$(printf %04d ${i})"           ## n <= 0001 ... 0099
  echo "---"
  sed -e s/__N__/${n}/ "${TEMPLLIST[${r}]}"
  i=$(($i+1))
done
