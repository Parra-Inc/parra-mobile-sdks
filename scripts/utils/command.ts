import { ChildProcess, exec } from 'child_process';
import Logger from './logger/logger.js';
import { CommandOptions, DEFAULT_COMMAND_OPTIONS } from './types.js';

const logger = new Logger('Command');

export class CommandResult {
  constructor(
    public readonly stdout: string,
    public readonly stderr: string,
    public readonly childProcess: ChildProcess
  ) { }
}

const execAsync = async (command: string, options: CommandOptions) => {
  const localLogger = options.commandLogger || logger;
  if (options.commandLogger) {
    localLogger.debug(`Executing command: ${command}`);
  }

  return new Promise<CommandResult>((resolve, reject) => {
    const childProcess = exec(command, options);

    let stdOutOutput = '';
    let stdErrOutput = '';

    childProcess.stdout.on('data', (data) => {
      logger.raw(false, data);
      stdOutOutput += data;

      if (localLogger) {
        localLogger.raw(false, data);
      }
    });

    childProcess.stderr.on('data', (data) => {
      stdErrOutput += data;

      if (localLogger) {
        localLogger.raw(true, data);
      } else {
        logger.raw(true, data);
      }
    });

    childProcess.on('close', (code, signal) => {
      if (code === null) {
        // If you're seeing this, it's possible that the maxBuffer size for exec was exceeded.
        reject(new Error(`Command failed with signal ${signal}`));

        return;
      }

      if (code !== 0 || (options.throwForStdErr && !!stdErrOutput)) {
        if (code === 0) {
          reject(
            new Error(`Command failed with stderr output: ${stdErrOutput}`)
          );
        } else {
          reject(new Error(`Command failed with code ${code}`));
        }
      } else {
        resolve(new CommandResult(stdOutOutput, stdErrOutput, childProcess));
      }
    });
  });
};

/**
 * Invoke the provided command and return the stdout and stderr output.
 */
export const runCommand = async (
  command: string,
  options: Partial<CommandOptions> = DEFAULT_COMMAND_OPTIONS
): Promise<CommandResult> => {
  const { throwForStdErr, ...rest } = options;

  return execAsync(command, {
    ...DEFAULT_COMMAND_OPTIONS,
    throwForStdErr: !!throwForStdErr,
    ...rest,
  });
};

/**
 * Invoke the provided command and throw an exception if output is piped to stderr.
 */
export const runThrowingCommand = async (
  command: string,
  options: Partial<CommandOptions> = DEFAULT_COMMAND_OPTIONS
): Promise<string | undefined> => {
  const { stdout } = await runCommand(command, {
    ...DEFAULT_COMMAND_OPTIONS,
    ...options,
    throwForStdErr: true,
  });

  return stdout;
};
