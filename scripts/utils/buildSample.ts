import { BuildForTestingOptions } from '../tests/types.js';
import { loadBuildForTestingOptionsFromEnvironment } from '../tests/utils.js';
import { build } from '../tests/xcode-build.js';
import { runCommand } from './command.js';
import Logger from './logger/logger.js';
import { LogLevel } from './logger/types.js';

const logger = new Logger('Sample builder', { level: LogLevel.Debug });

export const runBuildSample = async () => {

    logger.info("Resolving package dependencies...");
    await runCommand('cd sample; xcodebuild -resolvePackageDependencies', { commandLogger: logger });

    const options = await loadBuildForTestingOptionsFromEnvironment();
    logger.debug('Finished loading options from environment');

    const allowProvisioning = !!options.authenticationKeyPath;

    const fullOptions: BuildForTestingOptions = {
        ...options,
        allowProvisioningUpdates: allowProvisioning,
        allowProvisioningDeviceRegistration: allowProvisioning,
        scheme: 'ParraDemoApp',
        project: 'sample/ParraDemoApp.xcodeproj',
    };

    logger.info("Building sample app...");

    await build(fullOptions);

    logger.info(`Installing app on booted device`);
    await runCommand(`xcrun simctl install booted "build/unit-tests/derivedData/Build/Products/Debug-iphonesimulator/ParraDemoApp.app"`, { commandLogger: logger })
    logger.info(`Launching app...`);
    await runCommand(`xcrun simctl launch booted "com.parra.parra-ios-client"`, { commandLogger: logger })
}