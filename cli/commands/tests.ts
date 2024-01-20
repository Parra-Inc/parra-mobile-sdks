import { Command, Option } from 'commander';
import Logger from '../utils/logger/logger.js';
import { buildTests, runTests } from '../tests/index.js';

export const command = (logger: Logger): Command => {
  return new Command('tests')
    .description('Build and run tests for the Parra iOS SDK.')
    .addOption(
      new Option(
        '-b, --build',
        'Builds Parra in preparation for running tests without actually running them.'
      ).env('PARRA_TEST_OPTION_BUILD')
    )
    .addOption(
      new Option('-r, --run', "Runs Parra's test suites").env(
        'PARRA_TEST_OPTION_RUN'
      )
    )
    .addOption(
      new Option('-c --coverage', 'Enable code coverage')
        .env('PARRA_TEST_OPTION_COVERAGE')
        .implies({ run: true })
    )
    .addOption(
      new Option(
        '-o --output-directory',
        'The location to store testing artifacts'
      )
        .env('PARRA_TEST_OUTPUT_DIRECTORY')
        .makeOptionMandatory(true)
        .default('artifacts')
    )
    .action(async (options) => {
      const { build, run } = options;

      Logger.setGlobalLogLevel(options.silent ? 'silent' : options.logLevel);

      try {
        if (build) {
          await buildTests();
        }

        // Not else-if because we want to both build and run tests if both flags are provided.
        if (run) {
          await runTests({ enableCodeCoverage: true, resultBundlePath: '' });
        }

        logger.success('Done!');
      } catch (error) {
        console.error(error);

        process.exit(1);
      }
    });
};
