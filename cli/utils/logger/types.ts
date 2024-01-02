export enum LogLevel {
  Debug = 10,
  Info = 20,
  // This is weird, but I think I want success logs to basically be the same level as info logs.
  Success = 21,
  Warn = 30,
  Error = 40,
  Silent = 100,
}

/**
 * Options used for all logs emitted by the logger instance.
 */
export type LoggerOptions = {
  chalkEnabled: boolean;
  enabled: boolean;
};

/**
 * The default values for the options provided to the Logger instance.
 */
export const DEFAULT_LOGGER_OPTIONS: LoggerOptions = {
  chalkEnabled: true,
  enabled: true,
};
