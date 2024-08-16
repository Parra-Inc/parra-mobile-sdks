use crate::types::dependency::SemanticVersion;
use semver::{Version, VersionReq};
use std::process::Command;
use std::process::Stdio;
use std::vec;

#[derive(Debug, PartialEq)]
pub enum DerivedDependency {
    Xcode,
    SimulatorRuntime,
}

/// xcodegen is expected to be installed on the system by homebrew since it is a
/// project dependency. Other brew dependencies like xcodes and aria2 are installed
/// manually at this point since they are not always used.
pub fn install_missing_dependencies(
    desired_xcode_version: SemanticVersion,
    desired_ios_runtime_version: SemanticVersion,
) {
    install_brew_dependencies();
    install_xcode(desired_xcode_version, desired_ios_runtime_version);
}

pub fn check_for_missing_dependencies(
    min_xcode_version: SemanticVersion,
    desired_ios_runtime_version: SemanticVersion,
) -> Vec<DerivedDependency> {
    let mut missing_deps = Vec::<DerivedDependency>::new();

    match is_xcode_version_valid(min_xcode_version) {
        Some(is_valid) => {
            if !is_valid {
                // Xcode is installed but it's the wrong version
                missing_deps.push(DerivedDependency::Xcode);
            }

            // Regardless of Xcode being installed, check if a valid runtime is installed.
            if !is_simulator_version_valid(desired_ios_runtime_version) {
                missing_deps.push(DerivedDependency::SimulatorRuntime);
            }
        }
        None => {
            missing_deps.push(DerivedDependency::Xcode);
            missing_deps.push(DerivedDependency::SimulatorRuntime);
        }
    }

    return missing_deps;
}

fn is_simulator_version_valid(min_version: SemanticVersion) -> bool {
    // xcrun simctl list devices | grep "\-\- iOS" | awk '{print $3}'
    // First command: `xcrun simctl list devices`
    let list_devices = Command::new("xcrun")
        .arg("simctl")
        .arg("list")
        .arg("devices")
        .stdout(Stdio::piped())
        .spawn()
        .expect("Failed to list iOS runtimes");

    // Second command: `grep "\-\- iOS"`
    let grep_for_ios_runtimes = Command::new("grep")
        .arg("\\-\\- iOS")
        .stdin(Stdio::from(
            list_devices
                .stdout
                .expect("Failed to get search for iOS runtime"),
        ))
        .stdout(Stdio::piped())
        .spawn()
        .expect("Failed to execute grep -- iOS");

    // Third command: `awk '{print $3}'`
    let format_results = Command::new("awk")
        .arg("{print $3}")
        .stdin(Stdio::from(
            grep_for_ios_runtimes
                .stdout
                .expect("Failed to format matching iOS runtimes"),
        ))
        .stdout(Stdio::piped())
        .spawn()
        .expect("Failed to execute awk '{print $3}'");

    // Capture the final output
    let output = format_results
        .wait_with_output()
        .expect("Failed to read stdout of third command");

    if !output.status.success() {
        return false;
    }

    return String::from_utf8_lossy(&output.stdout)
        .lines()
        .map(|line| {
            let components: Vec<&str> = line.trim().split(".").collect();
            let [major, minor] = components[..] else {
                panic!("Major or minor component missing")
            };

            SemanticVersion {
                major: major
                    .parse()
                    .expect("Major version component wasn't a valid int8"),
                minor: minor
                    .parse()
                    .expect("Minor version component wasn't a valid int8"),
                patch: 0,
            }
        })
        .any(|version| {
            return version.major > min_version.major
                || (version.major == min_version.major
                    && version.minor >= min_version.minor);
        });
}

/// Returns true if Xcode is installed and valid version, false if installed and invalid version
/// and None if Xcode isn't installed.
fn is_xcode_version_valid(min_version: SemanticVersion) -> Option<bool> {
    let output = Command::new("xcodebuild")
        .arg("-version")
        .stderr(Stdio::null())
        .output()
        .expect("Failed to execute xcodebuild -version");

    if !output.status.success() {
        return None;
    }

    let stdout = String::from_utf8_lossy(&output.stdout);

    let min_version_string = format!(
        "{}.{}.{}",
        min_version.major, min_version.minor, min_version.patch
    );

    let min_version_req =
        match VersionReq::parse(&format!(">={}", min_version_string)) {
            Ok(req) => req,
            Err(_) => return Some(false), // Return false if the minimum version string is invalid
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
                        println!(
                            "Xcode version: {} is already installed",
                            version
                        );

                        return Some(true);
                    }
                }
            }
        }
    }

    println!("No installed Xcode version meets the minimum requirement");

    return Some(false);
}

fn install_brew_dependencies() {
    let dependencies = vec!["xcodes", "aria2"];

    println!("Installing Homebrew dependencies: {:?}", dependencies);

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

fn install_xcode(
    xcode_version: SemanticVersion,
    runtime_version: SemanticVersion,
) {
    let xcode_version_string = format!(
        "{}.{}.{}",
        xcode_version.major, xcode_version.minor, xcode_version.patch
    );
    let version_string_clone = xcode_version_string.clone();

    println!("Installing Xcode version: {:?}", xcode_version_string);

    //  and if fail retry without

    let xcode_install_output = Command::new("xcodes")
        .arg("install")
        .arg(xcode_version_string)
        // Will skip prompting for password but will result in user being prompted for password to install
        // additional tools when they launch Xcode. This will likely be more streamlined.
        .arg("--no-superuser")
        .arg("--experimental-unxip")
        // .arg("--select")
        // Need to inherit stdio to allow the user to enter credentials when prompted by xcodes.
        .stdin(Stdio::inherit())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .output()
        .expect("Failed to execute Xcode install command");

    if !xcode_install_output.status.success() {
        let stderr = String::from_utf8_lossy(&xcode_install_output.stderr);
        eprintln!("Xcode install failed. Error:\n{}", stderr);

        return;
    }

    println!("Successfully installed Xcode: {}", version_string_clone);

    let runtime_version_string =
        format!("{}.{}", runtime_version.major, runtime_version.minor);
    let runtime_version_string_clone = runtime_version_string.clone();

    let latest_matching_runtime = Command::new("sh")
        .arg("-c")
        .arg(format!(
            "xcodes runtimes | grep \"iOS {}\" | tail -n 1",
            runtime_version_string
        ))
        .output()
        .expect("Failed to execute command");

    let binding = String::from_utf8_lossy(&latest_matching_runtime.stdout);
    let runtime_to_install = binding.trim();

    println!("Installing iOS {} runtime", runtime_to_install);

    let xcode_runtime_install_output = Command::new("xcodes")
        .arg("runtimes")
        .arg("install")
        .arg(runtime_to_install)
        // Need to inherit stdio to allow the user to enter credentials when prompted by xcodes.
        .stdin(Stdio::inherit())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .output();

    match xcode_runtime_install_output {
        Ok(output) => {
            if !output.status.success() {
                let stderr =
                    String::from_utf8_lossy(&xcode_install_output.stderr);

                eprintln!("iOS runtime install failed. Error:\n{}", stderr);
            }
        }
        Err(error) => {
            eprintln!(
                "Failed to execute Xcode runtime install command. Error: {}",
                error
            )
        }
    }

    println!(
        "Successfully installed iOS {} runtime",
        runtime_version_string_clone
    );
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
