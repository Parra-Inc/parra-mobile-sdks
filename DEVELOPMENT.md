## Developing Parra Mobile SDKs

To setup the Parra iOS SDK for local development, invoke the bootstrap command with `./cli.sh utils --bootstrap`.

### Generating the Sample App

Parra uses the default template from the `templates` directory when generating the public demo/sample app. There are special template options which can be passed to the CLI to re-generate the sample app. From the `cli` directory, run `cargo run bootstrap --template parra-sample-local` to create a sample app that is linked to the local Parra SDK in `sdks/ios`. Run `cargo run bootstrap --template parra-sample-remote` to link to the SDK version currently published on SPM matching the version in `cli/Cargo.toml`.

### Creating a new template

Most templates build off of the default template. To facilitate this, the standard practice for creating new templates is to start by symlinking all the files within the default one and modifying it from there.

1. Create a kebab-case folder name for the new template in the `templates` directory.
2. Duplicate the structure of the default template with links to the original files `cd templates; cp -RLs default/* new-template/`.
3. Delete and re-create, or otherwise modify the new template's files as needed.
4. Update the arg parser in the `cli` to add a new case to the `TemplateName` enum for the new template.
