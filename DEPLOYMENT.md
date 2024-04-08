# Deploying Parra iOS SDK Packages

### Swift Package Manager

1. Merge your changes into the `main` branch.
2. Create a new tag on the `main` branch with the version number you want to release. For example, if you want to release version `1.0.0`, create a tag named `1.0.0`.
3. Push the tag to the remote repository with `git push origin --tags`.
4. If the new version is a patch release, verify that the [Parra CLI](https://github.com/Parra-Inc/parra-cli) now installs the correct version of the SDK.
5. If the new version is a minor or major release, update the Parra CLI to install the new version of the SDK, and publish an update to the Parra CLI.
