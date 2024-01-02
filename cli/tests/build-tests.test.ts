import { buildTests } from './build-tests.js';
import { loadBuildForTestingOptionsFromEnvironment } from './load-build-for-testing-options.js';
import { buildForTesting } from './build-for-testing.js';

jest.mock('./load-build-for-testing-options');
jest.mock('./build-for-testing');

describe('buildTests', () => {
  it('should call the necessary functions with the correct options', async () => {
    const loggerInfoSpy = jest.spyOn(logger, 'info');
    const loggerDebugSpy = jest.spyOn(logger, 'debug');
    const loadBuildForTestingOptionsFromEnvironmentSpy = jest.spyOn(
      loadBuildForTestingOptionsFromEnvironment,
      'default'
    );
    const buildForTestingSpy = jest.spyOn(buildForTesting, 'default');

    await buildTests();

    expect(loggerInfoSpy).toHaveBeenCalledWith('Starting build for testing...');
    expect(loadBuildForTestingOptionsFromEnvironmentSpy).toHaveBeenCalled();
    expect(loggerDebugSpy).toHaveBeenCalledWith(
      'Finished loading options from environment'
    );
    expect(buildForTestingSpy).toHaveBeenCalledWith({
      ...mockOptions,
      allowProvisioningUpdates: true,
      allowProvisioningDeviceRegistration: true,
    });
  });
});
