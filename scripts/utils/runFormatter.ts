import { runCommand } from './command.js';

export const runFormatter = async () => {
  await runCommand('swiftformat --config .swiftformat --cache ignore .');
};
