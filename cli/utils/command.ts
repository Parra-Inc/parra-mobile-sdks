import { ChildProcess, ExecOptions, exec } from 'child_process';
import Logger from './logger/logger.js';

const logger = new Logger('Command');

export class CommandResult {
  constructor(
    public readonly stdout: string,
    public readonly stderr: string,
    public readonly childProcess: ChildProcess
  ) {}
}

const execAsync = async (
  command: string,
  options: {
    /// If set, throws if stderr is not empty. Defaults to false. since many commands write
    /// to stderr even when they succeed.
    throwForStdErr: boolean;
    encoding: BufferEncoding;
  } & ExecOptions
) => {
  return new Promise<CommandResult>((resolve, reject) => {
    const childProcess = exec(command, options);

    let stdOutOutput = '';
    let stdErrOutput = '';

    childProcess.stdout.on('data', (data) => {
      logger.raw(false, data);
      stdOutOutput += data;
    });

    childProcess.stderr.on('data', (data) => {
      stdErrOutput += data;

      logger.raw(true, data);
    });

    childProcess.on('close', (code) => {
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
  { throwForStdErr }: { throwForStdErr?: boolean } & ExecOptions = {
    throwForStdErr: false,
    maxBuffer: 1024 * 1024 * 100, // 100 MB
  }
): Promise<CommandResult> => {
  return execAsync(command, {
    throwForStdErr: !!throwForStdErr,
    encoding: 'utf8',
  });
};

/**
 * Invoke the provided command and throw an exception if output is piped to stderr.
 */
export const runThrowingCommand = async (
  command: string
): Promise<string | undefined> => {
  const { stdout } = await runCommand(command, { throwForStdErr: true });

  return stdout;
};
