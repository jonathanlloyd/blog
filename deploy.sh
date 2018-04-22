#!/bin/bash -eu
set -o pipefail

rev=$(git rev-parse --short HEAD)

hugo
echo "=======> Public DIR"
ls public
cp -r public deploy
pushd deploy
git init
git config user.name "Automated build"
git config user.email "N/A"
git checkout -b gh-pages
git add --all :/
git commit -m "Automated build $rev"
git remote add origin "https://${GH_TOKEN}@github.com/${GH_REF}.git"
git push origin gh-pages --force --quiet
popd
rm -rf deploy
