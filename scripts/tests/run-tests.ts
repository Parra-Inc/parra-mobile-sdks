import { runCommand } from '../utils/command.js';
import Logger from '../utils/logger/logger.js';
import { TestWithoutBuildingOptions, CommonXcodeBuildOptions } from './types.js';
import { loadTestWithoutBuildingOptionsFromEnvironment } from './utils.js';
import { testWithoutBuilding } from './xcode-build.js';

export type RunTestsOptions = Omit<
  TestWithoutBuildingOptions,
  keyof CommonXcodeBuildOptions
>;

const logger = new Logger('build-tests');

export const runTests = async (options: RunTestsOptions) => {
  logger.info('Running tests...');

  const envOptions = await loadTestWithoutBuildingOptionsFromEnvironment();
  logger.debug('Finished loading options from environment');

  await runCommand(`rm -rf ${options.resultBundlePath}`);

  const fullOptions: TestWithoutBuildingOptions = {
    ...envOptions,
    ...options,
  };

  await testWithoutBuilding(fullOptions);
};
