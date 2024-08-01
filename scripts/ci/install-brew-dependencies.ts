import { runThrowingCommand } from '../utils/command.js';

export const installBrewDependencies = async () => {
  await runThrowingCommand(
    `
    echo "Installing Homebrew dependencies..."

    # Don't check for and install updates for taps on every brew command.
    export HOMEBREW_NO_AUTO_UPDATE=1

    # Speed up by skipping cleanup tasks after install.
    export HOMEBREW_NO_INSTALL_CLEANUP=1
    
    export HOMEBREW_NO_INSTALL_UPGRADE=1

    export HOMEBREW_NO_ANALYTICS=1

    

    echo "Installing applesimutils..."
    # Used for scripts that query for specific simulators via simctl.
    brew install wix/brew/applesimutils


    echo "Installing xcbeautify..."
    # Used for pretty printing xcodebuild output.
    brew install xcbeautify --quiet
    `
  );
};
