use crate::types::dependency::XcodeVersion;
use semver::{Version, VersionReq};
use std::process::Command;
use std::process::Stdio;
use std::vec;

#[derive(Debug, PartialEq)]
pub enum DerivedDependency {
    Xcode,
}

/// xcodegen is expected to be installed on the system by homebrew since it is a
/// project dependency. Other brew dependencies like xcodes and aria2 are installed
/// manually at this point since they are not always used.
pub fn install_missing_dependencies(desired_xcode_version: XcodeVersion) {
    println!("Installing missing dependencies...");

    install_brew_dependencies();
    install_xcode(desired_xcode_version);
}

pub fn check_for_missing_dependencies(
    min_xcode_version: XcodeVersion,
) -> Vec<DerivedDependency> {
    println!("Checking for missing dependencies");

    let mut missing_deps = Vec::<DerivedDependency>::new();

    let valid_version = check_xcode_version(min_xcode_version);
    if !valid_version {
        missing_deps.push(DerivedDependency::Xcode)
    }

    return missing_deps;
}

fn check_xcode_version(min_version: XcodeVersion) -> bool {
    let output = Command::new("xcodebuild")
        .arg("-version")
        .stderr(Stdio::null())
        .output()
        .expect("Failed to execute xcodebuild -version");

    if !output.status.success() {
        return false;
    }

    let stdout = String::from_utf8_lossy(&output.stdout);

    let min_version_string = format!(
        "{}.{}.{}",
        min_version.major, min_version.minor, min_version.patch
    );

    let min_version_req =
        match VersionReq::parse(&format!(">={}", min_version_string)) {
            Ok(req) => req,
            Err(_) => return false, // Return false if the minimum version string is invalid
        };

    for line in stdout.lines() {
        // Attempt to extract the version number from the beginning of the line
        let components: Vec<&str> = line.split_whitespace().collect();
        let first = components.first();
        let last = components.last();

        if let (Some(first), Some(last)) = (first, last) {
            if first == &"Xcode" {
                let version_str = ensure_full_semver(last);

                if let Ok(version) = Version::parse(&version_str) {
                    if min_version_req.matches(&version) {
                        println!("Found installed Xcode version: {}", version);
                        return true;
                    }
                }
            }
        }
    }

    println!("No installed Xcode version meets the minimum requirement");

    return false;
}

fn install_brew_dependencies() {
    let dependencies = vec!["xcodes", "aria2"];

    let output = Command::new("brew")
        .env("HOMEBREW_NO_INSTALL_UPGRADE", "1")
        .env("HOMEBREW_NO_AUTO_UPDATE", "1")
        .arg("install")
        .args(dependencies)
        .output()
        .expect("Failed to execute command");

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        eprintln!("Command failed. Error:\n{}", stderr);
    }
}

fn install_xcode(version: XcodeVersion) {
    let version_string =
        format!("{}.{}.{}", version.major, version.minor, version.patch);
    let version_string_clone = version_string.clone();

    println!("Installing Xcode version: {:?}", version_string);

    //  and if fail retry without

    let output = Command::new("xcodes")
        .arg("install")
        .arg(version_string)
        // Will skip prompting for password but will result in user being prompted for password to install
        // additional tools when they launch Xcode. This will likely be more streamlined.
        .arg("--no-superuser")
        .arg("--experimental-unxip")
        // Need to inherit stdio to allow the user to enter credentials when prompted by xcodes.
        .stdin(Stdio::inherit())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .output()
        .expect("Failed to execute command");

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        eprintln!("Command failed. Error:\n{}", stderr);
    }

    println!("Successfully installed Xcode: {}", version_string_clone);
}

fn ensure_full_semver(version: &str) -> String {
    // Check if the version string already has two dots
    if version.matches('.').count() < 2 {
        // If not, assume it's missing the patch version and append ".0"
        format!("{}.0", version)
    } else {
        version.to_string()
    }
}
