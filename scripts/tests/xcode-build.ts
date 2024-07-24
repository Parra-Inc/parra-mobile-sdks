import { runCommand } from '../utils/command.js';
import Logger from '../utils/logger/logger.js';
import { BuildForTestingOptions, TestWithoutBuildingOptions } from './types.js';
import {
  buildWithoutTestingArgStringFromOptions,
  testWithoutBuildingArgStringFromOptions,
} from './utils.js';

const logger = new Logger('xcode-build');
const isCI = !!process.env.CI;

export const buildForTesting = async (
  options: BuildForTestingOptions
): Promise<void> => {
  const { derivedDataPath } = options;
  const args = await buildWithoutTestingArgStringFromOptions(options);

  await runXcodeBuildCommand(
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

  await runXcodeBuildCommand(
    'test-without-building',
    args,
    derivedDataPath,
    `| ${commandSuffix}`
  );
};

const runXcodeBuildCommand = async (
  command: string,
  args: string,
  derivedDataPath: string,
  commandSuffix: string = ''
): Promise<void> => {
  // Don't print args in CI. They contain sensitive information.
  if (isCI) {
    logger.debug(`Running command: xcodebuild ${command}`);
  } else {
    logger.debug(`Running command: xcodebuild ${command} ${args}`);
  }

  await runCommand(
    `
    set -xo pipefail;
    
    export CONFIGURATION_BUILD_DIR="${derivedDataPath}";
    # Disable buffering to ensure that logs are printed in real time.
    NSUnbufferedIO=YES set -o pipefail \
        && xcodebuild ${command} ${args} ${commandSuffix}
    `
  );
};
