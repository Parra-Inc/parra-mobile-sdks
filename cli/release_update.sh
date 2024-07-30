#! /bin/bash

if [ -z "$1" ]; then
  echo "Please provide the version number as the first argument."
  exit 1
fi

cargo install cargo-edit
cargo set-version --workspace "$1"

echo "Building release for all targets"

rm -rf target

echo "Building for macOS ARM"
cargo build --release --target aarch64-apple-darwin --quiet --locked

echo "Building for macOS Intel"
cargo build --release --target x86_64-apple-darwin --quiet --locked

echo "Build complete. Artifacts are in target/release"

echo "Preparing artifacts for release"

rm -rf artifacts
mkdir -p artifacts

tar -czf "artifacts/parra-cli-$1.x86_64_apple_darwin.tar.gz" target/x86_64-apple-darwin/release/parra
tar -czf "artifacts/parra-cli-$1.aarch64_apple_darwin.tar.gz" target/aarch64-apple-darwin/release/parra

chmod +x artifacts/*

echo "Artifact preparation complete"

printf "\nChecksums:\n"
shasum artifacts/* --algorithm 256


printf "\n\n Done!"