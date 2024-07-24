/**
 * Common to all commands
 */
export type XcodeBuildOptions = {
  derivedDataPath: string;

  project: string;
  scheme: string;
  configuration: string;
  destination: string;
};

const DEFAULT_XCODE_BUILD_OPTIONS: XcodeBuildOptions = {
  configuration: 'Debug',
  scheme: 'Parra',
  project: 'Parra.xcodeproj',
  destination: 'platform=iOS Simulator,name=iPhone 15,OS=17.4',
  derivedDataPath: 'build/unit-tests/derivedData',
};

export type BuildForTestingEnvOptions = XcodeBuildOptions & {
  /**
   * Must be a relative path when passed here. It will be converted to an absolute path before being
   * passed to `xcodebuild`. Also must be a path to a file containing a private key obtained from ASC.
   */
  authenticationKeyPath?: string;
  authenticationKeyId?: string;
  authenticationKeyIssuerId?: string;
};

export type BuildForTestingOptions = BuildForTestingEnvOptions & {
  allowProvisioningUpdates: boolean;
  allowProvisioningDeviceRegistration: boolean;
};

export const DEFAULT_BUILD_FOR_TESTING_ENV_OPTIONS: BuildForTestingEnvOptions =
  {
    ...DEFAULT_XCODE_BUILD_OPTIONS,
    authenticationKeyPath: 'artifacts/asc-key.p8',
  };

export type TestWithoutBuildingEnvOptions = XcodeBuildOptions;

export type TestWithoutBuildingOptions = TestWithoutBuildingEnvOptions & {
  // -parallel-testing-enabled yes \
  // -parallel-testing-worker-count 2 \
  // -maximum-parallel-testing-workers 4 \

  enableCodeCoverage?: boolean;
  resultBundlePath: string;
};

export const DEFAULT_TEST_WITHOUT_BUILDING_ENV_OPTIONS: TestWithoutBuildingEnvOptions =
  DEFAULT_XCODE_BUILD_OPTIONS;
