import { runCommand } from '../utils/command.js';
import Logger from '../utils/logger/logger.js';
import { ReleaseOptions } from './types.js';
import { loadReleaseOptionsFromEnvironment } from './utils.js';

const logger = new Logger('build-tests');

export const createRelease = async (options: ReleaseOptions) => {
    const envOptions = await loadReleaseOptionsFromEnvironment();
    logger.debug('Finished loading options from environment');

    const fullOptions: ReleaseOptions = {
        ...envOptions,
        ...options,
    };

    const { tag } = fullOptions;

    logger.info(`Tagging new release: ${tag}`);

    // Commit any existing changes. If there are none, create an empty commit.
    await runCommand(`git commit --allow-empty -m "Releasing version: ${tag}"`);

    await runCommand(`git tag ${tag}`);

    // Push the commit
    await runCommand(`git push`);

    // Push the tag
    await runCommand(`git push origin ${tag}`);
};
