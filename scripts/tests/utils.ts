import { runThrowingCommand } from '../utils/command.js';
import {
  XcodeBuildOptions,
  BuildForTestingOptions,
  DEFAULT_BUILD_FOR_TESTING_ENV_OPTIONS,
  DEFAULT_TEST_WITHOUT_BUILDING_ENV_OPTIONS,
  TestWithoutBuildingEnvOptions,
  TestWithoutBuildingOptions,
  CommonXcodeBuildOptions,
} from './types.js';

export const loadBuildForTestingOptionsFromEnvironment =
  async (): Promise<XcodeBuildOptions> => {
    const env = process.env;
    const defaults = DEFAULT_BUILD_FOR_TESTING_ENV_OPTIONS;

    // If an App Store Connect authentication key is provideded, we need to:
    // 1. Ensure that other required environment variables are provided.
    // 2. Decode the key, since it is stored in base64 in CircleCI.
    // 3. Convert the relative path to an absolute path, since `xcodebuild` requires an absolute path.
    let authentication: Pick<
      XcodeBuildOptions,
      | 'authenticationKeyPath'
      | 'authenticationKeyId'
      | 'authenticationKeyIssuerId'
    > = {};
    const ascApiKey = env.PARRA_ASC_API_KEY;

    if (ascApiKey) {
      if (!env.PARRA_ASC_API_KEY_ID) {
        throw new Error(
          'PARRA_ASC_API_KEY_ID is required when PARRA_ASC_API_KEY is provided.'
        );
      }

      if (!env.PARRA_ASC_API_ISSUER_ID) {
        throw new Error(
          'PARRA_ASC_API_ISSUER_ID is required when PARRA_ASC_API_KEY is provided.'
        );
      }

      const absoluteAuthenticationKeyPath = `${process.cwd()}/${defaults.authenticationKeyPath}`;

      await runThrowingCommand(
        `echo "${ascApiKey}" | base64 --decode > ${absoluteAuthenticationKeyPath}`
      );

      authentication = {
        authenticationKeyId: env.PARRA_ASC_API_KEY_ID,
        authenticationKeyIssuerId: env.PARRA_ASC_API_ISSUER_ID,
        authenticationKeyPath: absoluteAuthenticationKeyPath,
      };
    }

    return {
      ...loadCommonXcodeBuildOptionsFromEnvironment(),
      ...authentication,
    };
  };

export const loadTestWithoutBuildingOptionsFromEnvironment =
  async (): Promise<TestWithoutBuildingEnvOptions> => {
    // Tests do not currently load anything non-standard from the environment.
    return loadCommonXcodeBuildOptionsFromEnvironment();
  };

export const loadCommonXcodeBuildOptionsFromEnvironment =
  (): CommonXcodeBuildOptions => {
    const env = process.env;
    const defaults = DEFAULT_TEST_WITHOUT_BUILDING_ENV_OPTIONS;

    return {
      project: env.PARRA_TEST_PROJECT_NAME || defaults.project,
      scheme: env.PARRA_TEST_SCHEME_NAME || defaults.scheme,
      configuration: env.PARRA_TEST_CONFIGURATION || defaults.configuration,
      destination: env.PARRA_TEST_DESTINATION || defaults.destination,
      derivedDataPath:
        env.PARRA_TEST_DERIVED_DATA_DIRECTORY || defaults.derivedDataPath,
    };
  };

export const buildWithoutTestingArgStringFromOptions = async (
  options: BuildForTestingOptions
): Promise<string> => {
  const {
    allowProvisioningUpdates,
    allowProvisioningDeviceRegistration,
    authenticationKeyPath,
    authenticationKeyId,
    authenticationKeyIssuerId,
  } = options;

  const args = commonArgsFromOptions(options);

  if (
    authenticationKeyPath &&
    authenticationKeyId &&
    authenticationKeyIssuerId
  ) {
    args.push(`-authenticationKeyPath "${authenticationKeyPath}"`);
    args.push(`-authenticationKeyID "${authenticationKeyId}"`);
    args.push(`-authenticationKeyIssuerID "${authenticationKeyIssuerId}"`);

    // These flags can't be used if the authentication flags are not provided.
    if (allowProvisioningUpdates) {
      args.push('-allowProvisioningUpdates');
    }

    if (allowProvisioningDeviceRegistration) {
      args.push('-allowProvisioningDeviceRegistration');
    }
  }

  return args.join(' ');
};

export const testWithoutBuildingArgStringFromOptions = async (
  options: TestWithoutBuildingOptions
): Promise<string> => {
  const { enableCodeCoverage, resultBundlePath } = options;
  const args = commonArgsFromOptions(options);

  if (enableCodeCoverage) {
    args.push('-enableCodeCoverage YES');
  }

  if (resultBundlePath) {
    args.push(`-resultBundlePath "${resultBundlePath}"`);
  }

  return args.join(' ');
};

const commonArgsFromOptions = (options: CommonXcodeBuildOptions) => {
  const { project, scheme, configuration, destination, derivedDataPath } =
    options;

  return [
    `-project "${project}"`,
    `-scheme "${scheme}"`,
    `-configuration "${configuration}"`,
    `-destination "${destination}"`,
    `-derivedDataPath "${derivedDataPath}"`,
  ];
};
