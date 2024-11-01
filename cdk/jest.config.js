const testDir = '<rootDir>/test';
const testPattern = '**/*.test.ts';
module.exports = {
  testEnvironment: 'node',
  roots: [testDir],
  testMatch: [testPattern],
  transform: {
    '^.+\\.tsx?$': 'ts-jest'
  }
};
