# Parra iOS SDK CLI

This CLI contains tools that are useful for the development and deployment of the Parra iOS SDK. If you're looking to integrate Parra into your iOS project, the contents of this directory can be ignored. The Parra CLI is designed to be flexible enough to be invoked locally during development, as well as during CI. The configuration for the latter can be found in [.circle/config.yml](https://github.com/Parra-Inc/parra-mobile-sdks/blob/main/.circleci/config.yml).

## Philosophy

Scripts designed to assist with the testing and deployment of an SDK, such as Parra, should make best efforts to always prioritize reliability, speed, and clarity. In that order. We would rather incur a more complicated initial setup cost than suffer maintenance of flaky or slow jobs and tests (particularly when they are run in a CI environment). To this end, you will find that most scripts interact with build tools directly and avoid using tools like Fastlane when possible. For some of the rationale on why, see [Life in the slow lane](https://silverhammermba.github.io/blog/2019/03/12/slowlane).

## Getting Started

1. Clone the repo
2. Install the Xcode version specified in the main [README](../README.md) file.
3. Install [Bun](https://bun.sh/).
4. Run `bun install` from the root of the repository.
5. Invoke the Parra CLI by running `./cli.sh --help` to learn more about the available commands.

## Common Use Cases

#### Building to Run Unit Tests

```{sh}
./cli.sh tests --build --run --log-level debug
```
