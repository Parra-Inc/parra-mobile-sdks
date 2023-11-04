#! /bin/sh

# Opens the Parra demo app data file from the current simulator in Finder.
# Useful for debugging data storage.
open `xcrun simctl get_app_container booted com.parra.parra-ios-sdk-demo data` -a Finder

