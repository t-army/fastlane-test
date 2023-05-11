#!/usr/bin/env node

/**
 * This script runs some trivial checks to identify possible
 * issues related to the project configuration and suggest ways to solve them.
 */

const {spawnSync} = require('child_process');
const chalk = require('chalk');
const checkDependencies = require('check-dependencies');

const exec = (command, cwd) => {
  const task = spawnSync(command, {shell: true, cwd});
  if (task.status != 0) {
    throw new Error(task.stderr.toString());
  }
  return task.stdout.toString();
};

const NO = (message, suggestion) => {
  console.log(`🔴 ${message}`);
  if (suggestion) console.log(`└──> ${suggestion}`);
};
const YES = message => console.log(`🟢 ${message}`);
const g = text => chalk.bold.green(text);
const r = text => chalk.bold.red(text);

const checkNodeExists = () => {
  try {
    exec('node --version');
    YES(`Your ${g`node`} is ready to go.`);
  } catch (e) {
    NO(`You don't have ${r`node`}.`, `Install ${g`node`} first.`);
  }
};

const checkYarnExists = () => {
  try {
    exec('yarn --version');
    YES(`Your ${g`yarn`} is ready to go.`);
  } catch (e) {
    NO(`You don't have ${r`yarn`}.`, `Install ${g`yarn`} first.`);
  }
};

const checkRubyExists = () => {
  try {
    exec('ruby --version');
    YES(`Your ${g`ruby`} is ready to go.`);
  } catch (e) {
    NO(`You don't have ${r`ruby`}.`, `Install ${g`ruby`} first.`);
  }
};

const checkBundlerExists = () => {
  try {
    exec('bundle --version');
    YES(`Your ${g`bundler`} is ready to go.`);
  } catch (e) {
    NO(`You don't have ${r`bundler`}.`, `Install ${g`bundler`} first.`);
  }
};

const checkBundlerDependenciesAreUpToDate = () => {
  try {
    exec('bundle check');
    YES(`Your ${g`bundler dependencies`} are ready to go.`);
  } catch (e) {
    NO(`Your ${r`bundle dependencies`} are out of sync.`, `Run ${g`yarn install:all`} or ${g`bundle install`} first.`);
  }
};

const checkNodeDependenciesAreUpToDate = async () => {
  const res = await checkDependencies();

  if (res.error.length > 0) {
    NO(`Your ${r`node dependencies`} are out of sync.`, `Run ${g`yarn install:all`} or ${g`yarn install`} first.`);
  } else {
    YES(`Your ${g`node dependencies`} match the ones specifed in package.json.`);
  }
};

const main = async () => {
  checkNodeExists();
  checkYarnExists();
  checkRubyExists();
  checkBundlerExists();

  checkBundlerDependenciesAreUpToDate();
  await checkNodeDependenciesAreUpToDate();
};

main();
