import { Command, Option } from 'commander';
import Logger from '../utils/logger/logger.js';
import { ReleaseOptions } from '../release/types.js';
import { createRelease } from '../release/release.js';

export const command = (logger: Logger): Command => {
  return new Command('release')
    .description(
      'Helper scripts for releasing and publishing new versions of the library.'
    )
    .addOption(
      new Option(
        '-t, --tag <tag>',
        'Builds Parra in preparation for running tests without actually running them.'
      )
        .env('PARRA_RELEASE_VERSION')
        .makeOptionMandatory(true)
    )
    .action(async (options) => {
      const { tag } = options as ReleaseOptions;

      Logger.setGlobalLogLevel(options.silent ? 'silent' : options.logLevel);

      try {
        if (tag) {
          await createRelease(options);
        }

        logger.success('Done!');
      } catch (error) {
        console.error(error);

        process.exit(1);
      }
    });
};
