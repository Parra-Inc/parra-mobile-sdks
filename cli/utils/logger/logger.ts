/* eslint-disable @typescript-eslint/no-explicit-any */
// Any is permissible here since we are just forwarding to console.log/etc which support any.

import chalk, { ChalkInstance } from 'chalk';
import { DEFAULT_LOGGER_OPTIONS, LogLevel, LoggerOptions } from './types.js';

const DEFAULT_LOG_LEVEL = process.env.CI ? LogLevel.Debug : LogLevel.Info;

export default class Logger {
  constructor(
    private readonly name: string,
    private readonly options: LoggerOptions = DEFAULT_LOGGER_OPTIONS
  ) {}

  static globalLevel: LogLevel = DEFAULT_LOG_LEVEL;

  static setGlobalLogLevel(raw: string) {
    this.globalLevel = Logger.levelForSlug(raw);
  }

  public success(message: any, ...optionalParams: any[]): void {
    this.log(message, LogLevel.Success, console.log, optionalParams);
  }

  public debug(message: any, ...optionalParams: any[]): void {
    this.log(message, LogLevel.Debug, console.log, optionalParams);
  }

  public info(message: any, ...optionalParams: any[]): void {
    this.log(message, LogLevel.Info, console.log, optionalParams);
  }

  public warn(message: any, ...optionalParams: any[]): void {
    this.log(message, LogLevel.Warn, console.warn, optionalParams);
  }

  public error(message: any, ...optionalParams: any[]): void {
    this.log(message, LogLevel.Error, console.error, optionalParams);
  }

  /**
   * A special logger function that outputs the message without any formatting, except for coloring
   * error logs. This still respects the enabled flag or other settings. This is useful for display live
   * output from a child process.
   */
  public raw(isError: boolean, message: any, ...optionalParams: any[]): void {
    if (this.options.enabled && Logger.globalLevel !== LogLevel.Silent) {
      // Stream to stderr if it's an error and we are at least at the warn level.
      if (isError && Logger.globalLevel <= LogLevel.Error) {
        process.stderr.write(
          this.getChalkForLevel(LogLevel.Warn)(message, ...optionalParams)
        );
      }

      // Stream all non-error logs to stdout as long as the logger is enabled. These are to
      // be considered debug level logs.
      if (!isError && Logger.globalLevel < LogLevel.Info) {
        process.stdout.write(message, ...optionalParams);
      }
    }
  }

  private log(
    message: any,
    level: LogLevel,
    logFunction: (message: any, ...optionalParams: any[]) => void,
    ...optionalParams: any[]
  ): void {
    const { chalkEnabled, enabled } = this.options;

    if (!enabled || !this.shouldLog(level)) {
      return;
    }

    const levelChalk = this.getChalkForLevel(level);
    const slug = levelChalk(this.slugForLevel(level));
    const fullMessage = [message, ...optionalParams].join('\n').trim();

    if (chalkEnabled) {
      const prefix = `[${this.name.toUpperCase()}][${levelChalk(slug)}]`;

      logFunction(prefix, levelChalk(fullMessage));
    } else {
      const prefix = `[${this.name.toUpperCase()}][${slug}]`;

      logFunction(prefix, fullMessage);
    }
  }

  private getChalkForLevel(level: LogLevel): ChalkInstance {
    switch (level) {
      case LogLevel.Success:
        return chalk.greenBright;
      case LogLevel.Debug:
        return chalk.white;
      case LogLevel.Info:
        return chalk.blueBright;
      case LogLevel.Warn:
        return chalk.yellowBright;
      case LogLevel.Error:
        return chalk.redBright;
    }
  }

  private shouldLog(level: LogLevel): boolean {
    return level >= Logger.globalLevel;
  }

  private slugForLevel(level: LogLevel): string {
    switch (level) {
      case LogLevel.Success:
        return 'SUCCESS 🚀';
      case LogLevel.Debug:
        return 'DEBUG';
      case LogLevel.Info:
        return 'INFO';
      case LogLevel.Warn:
        return 'WARN';
      case LogLevel.Error:
        return 'ERROR';
      case LogLevel.Silent:
        return 'SILENT';
    }
  }

  private static levelForSlug(slug: string): LogLevel {
    switch (slug?.toUpperCase()) {
      case 'SUCCESS':
        return LogLevel.Success;
      case 'DEBUG':
        return LogLevel.Debug;
      case 'INFO':
        return LogLevel.Info;
      case 'WARN':
        return LogLevel.Warn;
      case 'ERROR':
        return LogLevel.Error;
      case 'SILENT':
        return LogLevel.Silent;
      default:
        return DEFAULT_LOG_LEVEL;
    }
  }
}
