const ignorePatternsForDirectories = (dirs) => {
  return dirs.map((dir) => `**/${dir}/*`);
};

module.exports = {
  root: true,
  env: {
    browser: false,
    es2021: true,
  },
  extends: ['eslint:recommended', 'plugin:@typescript-eslint/recommended'],
  overrides: [
    {
      env: {
        node: true,
      },
      files: ['.eslintrc.{js,cjs}'],
      parserOptions: {
        sourceType: 'script',
      },
    },
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  plugins: ['@typescript-eslint', 'unused-imports'],
  rules: {
    'no-unused-vars': 'off', // or "@typescript-eslint/no-unused-vars": "off",
    '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
  },
  ignorePatterns: [
    ...ignorePatternsForDirectories([
      'node_modules',
      'build',
      'dist',
      'vendor',
    ]),
  ],
};
