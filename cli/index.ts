import { readdirSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { createRequire } from 'module';
const require = createRequire(import.meta.url);

import { program, Option, Command } from 'commander';
import Logger from './utils/logger/logger.js';
import { ParraCliCommandGenerator } from './types.js';

// Commands issued to the CLI should provide args in the following format:
// $ <scope> [options]
// For example, to build tests, the command would be: $ tests --build
// Individual commands should be implemented as their own files in the commands directory.
// Commands created this way will be automatically added to the CLI.

const logger = new Logger('cli');

export const commonOptions = [
  new Option(
    '-l, --log-level [string]',
    'The verbosity level to use for logger output.'
  )
    .choices(['debug', 'info', 'warn', 'error', 'silent'])
    .conflicts('silent')
    .default('info')
    .makeOptionMandatory(true),
  new Option('--silent', 'Do not output any logs')
    .implies({
      'log-level': 'silent',
    })
    .default(false)
    .conflicts('log-level'),
];

const commandsDirName = 'commands';
const __filename = fileURLToPath(import.meta.url);
const normalizedPath = join(dirname(__filename), commandsDirName);

// Create a command for each file in the commands directory.
const commands = readdirSync(normalizedPath).reduce((acc, file) => {
  if (!file.endsWith('.ts')) {
    logger.warn(
      `Skipping loading command at ${file} because it is not a TypeScript file.`
    );

    return acc;
  }

  const module = require(`./${commandsDirName}/${file}`);
  if (!module.command || typeof module.command !== 'function') {
    logger.warn(
      `Skipping loading command at ${file} because it does not export a command function.`
    );

    return acc;
  }

  const commandWithDefaults = (module.command as ParraCliCommandGenerator)(
    logger
  )
    .showHelpAfterError(true)
    .addHelpCommand(true)
    .passThroughOptions(true);

  return [...acc, commandWithDefaults];
}, [] as Command[]);

let finalProgram = program
  .name('🦜🦜🦜 Parra CLI 🦜🦜🦜')
  .description(
    `
    A set of tools for working with Parra. This includes running tests and creating releases. 
    
    These scripts are intended to be run both locally and from within a CI environment, and should
    always be run from the root of the Parra repository.
    `
  )
  .version(process.env.npm_package_version, '-v, --version')
  .allowUnknownOption(true)
  .enablePositionalOptions()
  .action((args) => {
    console.log(`+++++++++++ ${JSON.stringify(args)} +++++++++++}`);
  })
  .addHelpCommand(true, 'Opens this help menu.');

for (const option of commonOptions) {
  finalProgram = finalProgram.addOption(option);
}

for (const command of commands) {
  finalProgram = finalProgram.addCommand(command);
}

finalProgram.parse();
