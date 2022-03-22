#! /bin/sh

library=$1
version=$2

if [ -z "$library" ]; then
    echo "Missing release library parameter."
    exit 1
fi

if [ -z "$version" ]; then
    echo "Missing release version parameter."
    exit 1
fi

if [ $(git tag -l "$version") ]; then
    echo "Tag $version already exists"
    exit 1
fi

echo "Preparing to release version ${version}"

if [[ -n $(git status -s) ]]; then 
    git add -A && git commit -m "Release v${version}"
fi

export PARRA_VERSION="$version" # Used to pass the version to the Podspec.

# TODO: Transform $library to Podspec name
pod spec lint ParraCore.podspec
git tag "${version}"

git push
git push --tags

export PARRA_VERSION="$version" # Used to pass the version to the Podspec.

pod trunk push ParraCore.podspec


echo "Successfully published version ${version}"
