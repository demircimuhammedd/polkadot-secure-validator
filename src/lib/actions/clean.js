const chalk = require('chalk');
const process = require('process');

const config = require('../config.js');
const { Platform } = require('../platform.js');
const { Application } = require('../application.js');


module.exports = {
  do: async (cmd) => {
    const cfg = config.read(cmd.config);

    console.log(chalk.yellow('Cleaning application...'));
    const app = new Application(cfg);
    try {
      await app.clean();
    } catch (e) {
      console.log(chalk.red(`Could not clean application: ${e.message}`));
      process.exit(-1);
    }
    console.log(chalk.green('Done'));

    console.log(chalk.yellow('Cleaning platform...'));
    const platform = new Platform(cfg);
    try {
      await platform.clean();
    } catch (e) {
      console.log(chalk.red(`Could not clean platform: ${e.message}`));
      process.exit(-1);
    }
    console.log(chalk.green('Done'));
  }
}
