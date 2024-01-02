import { runThrowingCommand } from '../utils/command.js';

export const disableSimulatorHardwareKeyboard = async () => {
  await runThrowingCommand(
    `
    echo "Killing simulator"
    set +e

    killall Simulator

    echo "Disabling hardware keyboard"
    defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool false
    `
  );
};
