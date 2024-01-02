import { Command, Option } from 'commander';
import Logger from '../utils/logger/logger.js';
import {
  disableSimulatorHardwareKeyboard,
  installBrewDependencies,
} from '../ci/index.js';

export const command = (logger: Logger): Command => {
  return new Command('ci')
    .description(
      'Helper scripts specifically indended for use in CI environments.'
    )
    .addOption(
      new Option(
        '-d, --disable-simulator-hardware-keyboard',
        'Disables the setting for the iOS Simulator to prevent automatically connecting to the hardware keyboard.'
      )
    )
    .addOption(
      new Option(
        '-b, --install-brew-dependencies',
        'Installs dependencies using Homebrew.'
      )
    )
    .action(async (options) => {
      const {
        disableSimulatorHardwareKeyboard: disableKeyboard,
        installBrewDependencies: brewInstall,
      } = options;

      if (brewInstall) {
        await installBrewDependencies();
      }

      if (disableKeyboard) {
        await disableSimulatorHardwareKeyboard();
      }

      Logger.setGlobalLogLevel(options.silent ? 'silent' : options.logLevel);

      try {
        logger.success('Done!');
      } catch (error) {
        console.error(error);

        process.exit(1);
      }
    });
};
