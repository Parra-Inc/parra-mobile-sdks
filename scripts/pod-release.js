#!/usr/bin/env node

const util = require('util');
const yargs = require('yargs/yargs')
const { hideBin } = require('yargs/helpers')
const exec = util.promisify(require('child_process').exec);

const libraryMap = new Map([
    ['core', 'ParraCore.podspec'],
    ['feedback', 'ParraFeedback.podspec'],
]);
const libraries = Array.from(libraryMap.keys());

const argv = yargs(hideBin(process.argv))
    .version(false)
    .option('library', {
        alias: 'l',
        type: 'string',
        description: 'The Parra library that you want to release an update for.',
        choices: libraries,
        demandOption: true,
    })
    .option('tag', { // can't use --version or -v since they interfer with npm's version arg.
        alias: 't',
        type: 'string',
        description: 'The tag/version of the supplied library that you want to release.',
        demandOption: true,
    })
    .help()
    .argv

const { library, tag } = argv;
const podSpec = libraryMap.get(library);
const libraryEnvVersion = `PARRA_${String(library).toUpperCase()}_VERSION`;
const libraryEnvTag = `PARRA_${String(library).toUpperCase()}_TAG`;
const gitTag = `parra-${library}-${tag}`;

console.log(`[PARRA CLI] Preparing to release version: ${tag} of ${podSpec}`);

(async () => {
    try {        
        console.log((await exec('pod repo update')).stdout);

        const status = await (await exec('git status -s')).stdout;
        if (status.length > 0) {
            console.log((await exec(`git add -A && git commit -m "Release v${version}"`)).stdout);
        }

        console.log(await exec(`git tag "${gitTag}"`));
        console.log((await exec('git push')).stdout);
        console.log((await exec('git push --tags')).stdout);
        
        console.log(await exec(`${libraryEnvTag}="${gitTag}" ${libraryEnvVersion}="${tag}" pod trunk push ${podSpec}`));


        console.log(`[PARRA CLI] successfully published release version: ${tag} of ${podSpec}`);
    } catch (error) {
        console.error(error);
        throw error;
    }
})();
