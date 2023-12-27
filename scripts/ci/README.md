# CI Scripts

This directory contains scripts that intended to be used from within a CI environment for things like running tests and building/shipping releases. Most of the scripts within this directory will be invoked automatically from [.circle/config.yml](https://github.com/Parra-Inc/parra-ios-sdk/blob/main/.circleci/config.yml).

## Philosophy

CI scripts should make best efforts to always prioritize reliability, speed, and clarity. In that order. We would rather incur a more complicated initial setup cost than suffer maintenance of flaky or slow jobs and tests. To this end, you will find that most scripts interact with build tools directly and avoid using tools like Fastlane when possible. For some of the rationale on why, see [Life in the slow lane](https://silverhammermba.github.io/blog/2019/03/12/slowlane).

## Scripts

#### Building to Run Unit Tests

`./build-for-testing.sh` performs a clean build of all Parra targets needed to execute unit tests. It also prepares a blank test runner app target to avoid running tests on the demo app, which may interfer with the tests.

#### Running Unit Tests

`./run-unit-tests.sh` will attempt to run the tests without building. If unable to do so, an incremental build will be performed. If the tests fail after this, a clean rebuild will happen and the tests will be run again.
