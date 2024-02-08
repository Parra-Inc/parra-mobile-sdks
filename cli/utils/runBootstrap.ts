import { runCommand, runThrowingCommand } from './command.js';
import Logger from './logger/logger.js';
import { LogLevel } from './logger/types.js';
import { CommandOptions } from './types.js';

const logger = new Logger('Project Bootstrap', { level: LogLevel.Debug });

export const runBootstrap = async () => {
  logger.info('Bootstrapping project...');

  const commonOptions: Partial<CommandOptions> = {
    commandLogger: logger,
  };

  // Bun

  try {
    const bunVersion = await runThrowingCommand('bun --version', commonOptions);

    logger.info(
      `Bun version: ${bunVersion} is already installed. Skipping installation.`
    );
  } catch {
    logger.error('Bun is not installed. Please install bun before continuing.');

    await runCommand('curl -fsSL https://bun.sh/install | bash', commonOptions);
  }

  await runCommand('bun install --quiet', commonOptions);

  // Gems

  await runCommand('gem install bundler --quiet', commonOptions);
  await runCommand('bundle install', commonOptions);

  // Homebrew

  await runCommand('brew install swiftformat --quiet', commonOptions);
  await runCommand(
    'brew install --cask swiftformat-for-xcode --quiet',
    commonOptions
  );

  logger.success('Project bootstrap complete!');
};
