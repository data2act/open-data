#!/bin/bash
set -e

cd "$(dirname "$0")"

git pull

mkdir -p data
rm -f data/*

for URL in $(grep "https://" urls-to-fetch); do
  OUTFILE="./data/${URL##*/}"
 
  ssh fetcher@vcdataproxy.digistatecloud.nl curl -s --fail "$URL" > "${OUTFILE}"
  echo "Downloaded ${URL}" >> log
done

git add data
git add log

git commit -m "Downloaded files"
git push
