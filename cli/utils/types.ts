import { ExecOptions } from 'child_process';

export type CommandOptions = {
  encoding: BufferEncoding;
  throwForStdErr: boolean;
} & ExecOptions;

export const DEFAULT_COMMAND_OPTIONS: CommandOptions = {
  encoding: 'utf8',
  maxBuffer: 1024 * 1024 * 100, // 100 MiB
  /// If set, throws if stderr is not empty. Defaults to false. since many commands write
  /// to stderr even when they succeed.
  throwForStdErr: false,
};
