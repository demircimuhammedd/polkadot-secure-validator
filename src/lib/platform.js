const { Terraform } = require('./clients/terraform');


class Platform {
  constructor(cfg) {
    this.config = JSON.parse(JSON.stringify(cfg));

    this.tf = new Terraform(this.config.terraform);
  }

  async sync() {

  }
}

module.exports = {
  Platform
}
