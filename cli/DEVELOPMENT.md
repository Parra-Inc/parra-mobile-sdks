# Developing the Parra CLI

### Prerequisites

1. Install [Homebrew](https://brew.sh/).
2. Install Homebrew development dependencies. `brew install xcodes aria2 xcodegen gh`. This includes tools that are used by the script itself, and `gh` is used to create GitHub when running the `release_update.sh` script.
3. Install [Rust](https://www.rust-lang.org/tools/install).
4. Install the `cargo-edit` Crate by running `cargo install cargo-edit`.

### Publishing Updates on Homebrew

1. Always set `HOMEBREW_NO_INSTALL_FROM_API=1` before running any `brew` commands when developing locally!
2. Run `brew update` to update the local Homebrew formulae.
3. Run `cargo build --release` to build the latest version of the CLI. This will create a binary at `target/release/parra`.
4. Run `./release_update.sh <VERSION>` to create a new release on GitHub and update the Homebrew formulae. Replace `<VERSION>` with the new version number.
5. Update the cli Formula in the [Parra Homebrew Tap](https://github.com/Parra-Inc/homebrew-tap) with the new version number and the new SHA256 hash. These can be found in the output from the previous step.
6. Run `brew install parra-inc/parra/parra-cli` to install the latest version of the CLI to test with.

### Notes

1. When running the project using `cargo run`, you will see a prompt to access the system keychain every time the binary is modified and it tries to access an entry that was created by the CLI before modification. This Only happens when the binary changes and will not happen in production, except potentially after installing an update.
2. If you're on Apple Silicon and plan to create releases for x86\_64, you will need to run `rustup target install x86_64-apple-darwin` to enable cross compilation support for the x86\_64 architecture.

### Generating the Parra Demo Project

Invoke the bootstrap command with one of the local or remote demo app generation environmental variables set.

* `PARRA_GENERATE_DEMO_LOCAL=1 cargo run bootstrap`
* `PARRA_GENERATE_DEMO_REMOTE=1 cargo run bootstrap`
