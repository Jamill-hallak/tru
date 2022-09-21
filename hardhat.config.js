require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
let secret = require("./secret")
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
   networks:{
      rinkeby:{
        url :secret.url,
        accounts :[secret.key]
      }
   },
   etherscan :{
    apiKey:"FUAA38A3W8P165DS3GSRDDHDKHU3AVXBKK"
   }
};
