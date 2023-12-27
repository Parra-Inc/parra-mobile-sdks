#! /bin/bash

echo "Installing Homebrew dependencies..."

# Don't check for and install updates for taps on every brew command.
export HOMEBREW_NO_AUTO_UPDATE=1

# Speed up by skipping cleanup tasks after install.
export HOMEBREW_NO_INSTALL_CLEANUP=1


echo "Installing jq..."
# Used for parsing JSON in CLI tools. This is deliberately used instead of modern equivalents like
# fx, because it's available on macOS executors in CircleCI by default, and even when missing installs
# much more quickly.
brew install jq


echo "Installing applesimutils..."
# Used for scripts that query for specific simulators via simctl.
brew tap wix/brew && brew install applesimutils


echo "Installing xcbeautify..."
# Used for pretty printing xcodebuild output.
brew install xcbeautify
