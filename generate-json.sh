#!/bin/bash

[ ! -d ./output ] && { echo "Cannot generate lists.json: lists folder not found."; exit 1; }

folderjson=()

for folder in ./output/*/; do
  folder=${folder%*/}
  foldername=${folder##*/}
  filejson=()

  for file in ${folder}/*; do
    filename=$(echo ${file##*/} | cut -d. -f1)
    fileurl=$(head -5 ${file} | sed -n 's/^.*File: //p')
    entries=$(head -5 ${file} | sed -n 's/^.*Entries: //p')
    filesize=$(stat -c '%s' ${file} | numfmt --to iec)
    filedate=$(head -5 ${file} | sed -n 's/^.*Updated: //p')
    filehash=$(sha256sum ${file} | head -c 64)
    filejson+=("\"${filename}\":{\"file\":\"${fileurl}\",\"hash\":\"${filehash}\",\"size\":\"${filesize}\"}")
  done

  folderjson+=("\"${foldername}\":{\"format\":{$(IFS=,; echo "${filejson[*]}")},\"updated\":\"${filedate}\",\"entries\":\"${entries}\"")
done

printf "{$(IFS=,; echo "${folderjson[*]}")}" > ./output/lists.json

echo "Finished generating lists.json."
exit 0
