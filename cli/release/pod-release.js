#!/usr/bin/env node

// const argv = yargs(hideBin(process.argv))
//     .version(false)
//     .option('tag', { // can't use --version or -v since they interfer with npm's version arg.
//         alias: 't',
//         type: 'string',
//         description: 'The tag/version that you want to release.',
//         demandOption: true,
//     })
//     .help()
//     .argv

// const { tag } = argv;
// const podSpec = `Parra.podspec`;
// const gitTag = `parra-${tag}`;

// (async () => {
//     try {
//         console.log((await exec('bundle install')).stdout);

//         console.log((await exec(`ruby ./scripts/ci/set-framework-version.rb ${tag}`)).stdout);

//         console.log((await exec('pod repo update')).stdout);

//         console.log(`[PARRA CLI] Preparing to release version: ${tag} of ${podSpec}`);

//         const status = await (await exec('git status -s')).stdout;
//         if (status.length > 0) {
//             console.log((await exec(`git add -A && git commit -m "Release v${tag}"`)).stdout);
//         }

//         console.log(await exec(`git tag "${gitTag}"`));
//         console.log((await exec('git push')).stdout);
//         console.log((await exec('git push --tags')).stdout);

//         const { stdout, stderr } = await exec(
//             `PARRA_TAG="${gitTag}" PARRA_VERSION="${tag}" pod trunk push ${podSpec} --allow-warnings`
//         );
//         console.error(stderr);
//         console.log(stdout);

//         console.log(`[PARRA CLI] successfully published release version: ${tag} of ${podSpec}`);
//     } catch (error) {
//         console.error(error);
//         throw error;
//     }
// })();
