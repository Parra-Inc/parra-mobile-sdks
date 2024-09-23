import { runCommand } from '../utils/command.js';
import Logger from '../utils/logger/logger.js';
import { BuildForTestingOptions, TestWithoutBuildingOptions } from './types.js';
import {
  buildWithoutTestingArgStringFromOptions,
  testWithoutBuildingArgStringFromOptions,
} from './utils.js';

const logger = new Logger('xcode-build');
const isCI = !!process.env.CI;

export const build = async (options: BuildForTestingOptions): Promise<void> => {
  const { derivedDataPath } = options;
  const args = await buildWithoutTestingArgStringFromOptions(options);

  await runXcodeBuildCommand(
    args,
    derivedDataPath,
    '| tee buildlog'
  );
}

export const buildForTesting = async (
  options: BuildForTestingOptions
): Promise<void> => {
  const { derivedDataPath } = options;
  const args = await buildWithoutTestingArgStringFromOptions(options);

  await runXcodeBuildSubcommand(
    'build-for-testing',
    args,
    derivedDataPath,
    '| tee buildlog'
  );
};

export const testWithoutBuilding = async (
  options: TestWithoutBuildingOptions
): Promise<void> => {
  const { derivedDataPath } = options;
  const args = await testWithoutBuildingArgStringFromOptions(options);
  let commandSuffix = 'xcbeautify --junit-report-filename junit-results.xml';

  if (isCI) {
    commandSuffix += ' --is-ci';
  }

  await runXcodeBuildSubcommand(
    'test-without-building',
    args,
    derivedDataPath,
    `2>&1 | ${commandSuffix}`
  );
};

const runXcodeBuildSubcommand = async (
  subcommand: string,
  args: string,
  derivedDataPath: string,
  commandSuffix: string = '2>&1 | xcbeautify'
): Promise<void> => {
  // Don't print args in CI. They contain sensitive information.
  if (isCI) {
    logger.debug(`Running command: xcodebuild ${subcommand}`);
  } else {
    logger.debug(`Running command: xcodebuild ${subcommand} ${args}`);
  }

  await runCommand(
    `
    set -xo pipefail;
    
    export CONFIGURATION_BUILD_DIR="${derivedDataPath}";
    # Disable buffering to ensure that logs are printed in real time.
    NSUnbufferedIO=YES set -o pipefail \
        && xcodebuild ${subcommand} ${args} ${commandSuffix}
    `, {
    commandLogger: logger,
  }
  );
};

export const runXcodeBuildCommand = async (
  args: string,
  derivedDataPath: string,
  commandSuffix: string = '2>&1 | xcbeautify'
): Promise<void> => {
  // Don't print args in CI. They contain sensitive information.
  if (isCI) {
    logger.debug(`Running command: xcodebuild`);
  } else {
    logger.debug(`Running command: xcodebuild`);
  }

  await runCommand(
    `
    set -xo pipefail;
    
    export CONFIGURATION_BUILD_DIR="${derivedDataPath}";
    # Disable buffering to ensure that logs are printed in real time.
    NSUnbufferedIO=YES set -o pipefail \
        && xcodebuild ${args} ${commandSuffix}
    `, {
    commandLogger: logger,
  }
  );
}
