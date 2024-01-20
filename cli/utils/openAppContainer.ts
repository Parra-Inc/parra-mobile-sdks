import { runThrowingCommand } from './command.js';

export type OpenAppContainerOptions = {
  bundleId: string;
};

export const openAppContainer = async (options: OpenAppContainerOptions) => {
  const { bundleId } = options;

  if (!bundleId) {
    throw new Error('Missing bundleId');
  }

  runThrowingCommand(
    `open \`xcrun simctl get_app_container booted ${bundleId} data\` -a Finder`
  );
};

export const openAppContainerForDemoApp = async () => {
  await openAppContainer({ bundleId: 'com.parra.parra-ios-sdk-demo' });
};

export const openAppContainerForTestRunnerApp = async () => {
  await openAppContainer({ bundleId: 'com.parra.ParraTests.Runner' });
};
