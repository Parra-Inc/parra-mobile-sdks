#! /bin/sh

version=$1

if [ -n "$version" ]; then
    echo "Preparing to release version ${version}"

    git add -A && git commit -m "Release v${version}"
    git tag "v${version}"
    git push
    git push --tags

    pod spec lint ParraCore.podspec

    echo "Successfully published version ${version}"
else
    echo "Missing release version parameter."
fi

