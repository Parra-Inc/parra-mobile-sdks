import { Command } from 'commander';
import Logger from './utils/logger/logger.js';

/**
 * A common interface for all CLI command functions contained within this directory.
 */
export type ParraCliCommandGenerator = (logger: Logger) => Command;
