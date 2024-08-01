import { BuildForTestingOptions } from '../tests/types.js';
import { loadBuildForTestingOptionsFromEnvironment } from '../tests/utils.js';
import { buildForTesting } from '../tests/xcode-build.js';
import { runCommand } from './command.js';
import Logger from './logger/logger.js';
import { LogLevel } from './logger/types.js';

const logger = new Logger('Sample builder', { level: LogLevel.Debug });

export const runBuildSample = async () => {

    logger.info("Resolving package dependencies...");
    await runCommand('cd sample; xcodebuild -resolvePackageDependencies');

    const options = await loadBuildForTestingOptionsFromEnvironment();
    logger.debug('Finished loading options from environment');

    const allowProvisioning = !!options.authenticationKeyPath;

    const fullOptions: BuildForTestingOptions = {
        ...options,
        allowProvisioningUpdates: allowProvisioning,
        allowProvisioningDeviceRegistration: allowProvisioning,
        scheme: 'ParraDemo',
        project: 'sample/ParraDemo.xcodeproj',
    };

    logger.info("Building sample app...");

    await buildForTesting(fullOptions);

    const sim = await runCommand(`./scripts/bin/obtain-simulator-device-id.sh "${process.env.PARRA_TEST_DEVICE_NAME}" "${process.env.PARRA_TEST_DEVICE_OS_VERSION}"`)
    const deviceId = sim.stdout;

    logger.info(`Booting device: ${deviceId}`);
    await runCommand(`xcrun simctl boot "${deviceId}" --arch=arm64`);

    logger.info(`Installing app on booted device`);
    await runCommand(`xcrun simctl install booted "build/unit-tests/derivedData/Build/Products/Debug-iphonesimulator/ParraDemo.app"`)
    logger.info(`Launching app...`);
    await runCommand(`xcrun simctl launch booted "com.parra.parra-ios-client"`)
}