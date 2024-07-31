## Developing Parra Mobile SDKs

To setup the Parra iOS SDK for local development, invoke the bootstrap command with `./cli.sh utils --bootstrap`.

### Generating the Sample App

Parra uses the default template from the `templates` directory when generating the public demo/sample app. There are special template options which can be passed to the CLI to re-generate the sample app. From the `cli` directory, run `cargo run bootstrap --template parra-sample-local` to create a sample app that is linked to the local Parra SDK in `sdks/ios`. Run `cargo run bootstrap --template parra-sample-remote` to link to the SDK version currently published on SPM matching the version in `cli/Cargo.toml`.
