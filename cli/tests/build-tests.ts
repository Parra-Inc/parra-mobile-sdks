import Logger from '../utils/logger/logger.js';
import { BuildForTestingOptions } from './types.js';
import { loadBuildForTestingOptionsFromEnvironment } from './utils.js';
import { buildForTesting } from './xcode-build.js';

const logger = new Logger('build-tests');

export const buildTests = async () => {
  logger.info('Starting build for testing...');

  const options = await loadBuildForTestingOptionsFromEnvironment();
  logger.debug('Finished loading options from environment');

  const allowProvisioning = !!options.authenticationKeyPath;

  const fullOptions: BuildForTestingOptions = {
    ...options,
    allowProvisioningUpdates: allowProvisioning,
    allowProvisioningDeviceRegistration: allowProvisioning,
  };

  await buildForTesting(fullOptions);
};
