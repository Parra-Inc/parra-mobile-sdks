#!/usr/bin/env node

const util = require('util');
const yargs = require('yargs/yargs')
const { hideBin } = require('yargs/helpers')
const exec = util.promisify(require('child_process').exec);

const libraryMap = new Map([
    ['core', 'ParraCore'],
    ['feedback', 'ParraFeedback'],
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
const targetName = libraryMap.get(library);
const podSpec = `${targetName}.podspec`;
const libraryEnvVersion = `PARRA_${String(library).toUpperCase()}_VERSION`;
const libraryEnvTag = `PARRA_${String(library).toUpperCase()}_TAG`;
const gitTag = `parra-${library}-${tag}`;

(async () => {
    try {
        console.log((await exec('bundle install')).stdout);

        console.log((await exec(`ruby ./scripts/set-framework-version.rb ${targetName} ${tag}`)).stdout);

        console.log((await exec('pod repo update')).stdout);

        console.log(`[PARRA CLI] Preparing to release version: ${tag} of ${podSpec}`);

        const status = await (await exec('git status -s')).stdout;
        if (status.length > 0) {
            console.log((await exec(`git add -A && git commit -m "Release v${tag}"`)).stdout);
        }

        console.log((await exec(`git push --set-upstream origin ${gitTag}`)).stdout);
        console.log(await exec(`git tag "${gitTag}"`));

        const { stdout, stderr } = await exec(
            `${libraryEnvTag}="${gitTag}" ${libraryEnvVersion}="${tag}" pod trunk push ${podSpec} --allow-warnings`
        );
        console.error(stderr);
        console.log(stdout);

        console.log((await exec('git push --tags')).stdout);

        console.log(`[PARRA CLI] successfully published release version: ${tag} of ${podSpec}`);
    } catch (error) {
        console.log((await exec(`git tag -d ${gitTag}`)).stdout);

        console.error(error);
        throw error;
    }
})();
