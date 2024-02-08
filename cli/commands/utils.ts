import { Command, Option } from 'commander';
import Logger from '../utils/logger/logger.js';
import {
  openAppContainerForDemoApp,
  openAppContainerForTestRunnerApp,
  runFormatter,
} from '../utils/openAppContainer.js';

export const command = (logger: Logger): Command => {
  return new Command('utils')
    .description('A way to invoke miscellaneous utilities and helper scripts.')
    .addOption(
      new Option(
        '-a --open-app-data',
        'Opens a new Finder window to the app data directory for the Parra Demo app in the currently booted simulator.'
      )
    )
    .addOption(
      new Option(
        '-t --open-test-data',
        'Opens a new Finder window to the app data directory for the Parra Test Runner app in the currently booted simulator.'
      )
    )
    .addOption(
      new Option(
        '-f --format',
        'Reformats the entire project using SwiftFormat.'
      )
    )
    .action(async (options) => {
      Logger.setGlobalLogLevel(options.silent ? 'silent' : options.logLevel);
      const { openAppData, openTestData, format } = options;

      try {
        if (openAppData) {
          await openAppContainerForDemoApp();
        }

        if (openTestData) {
          await openAppContainerForTestRunnerApp();
        }

        if (format) {
          await runFormatter();
        }

        logger.success('Done!');
      } catch (error) {
        console.error(error);

        process.exit(1);
      }
    });
};
