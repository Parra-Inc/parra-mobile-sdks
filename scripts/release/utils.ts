import { ReleaseOptions } from "./types.js";

export const loadReleaseOptionsFromEnvironment =
    async (): Promise<ReleaseOptions> => {
        const env = process.env;

        return {
            tag: env.PARRA_RELEASE_VERSION,
        };
    };

