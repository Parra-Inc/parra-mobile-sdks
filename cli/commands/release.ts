import { Command } from 'commander';
import Logger from '../utils/logger/logger.js';

export const command = (logger: Logger): Command => {
  return new Command('release')
    .description(
      'Helper scripts for releasing and publishing new versions of the library.'
    )
    .action(async (options) => {
      Logger.setGlobalLogLevel(options.silent ? 'silent' : options.logLevel);

      try {
        logger.success('Done!');
      } catch (error) {
        console.error(error);

        process.exit(1);
      }
    });
};
