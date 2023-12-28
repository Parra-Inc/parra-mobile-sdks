#! /bin/bash

echo "Killing simulator"
set +e

killall Simulator

echo "Disabling hardware keyboard"
defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool false