const BTTAddress = "TNuoKL1ni8aoshfFL1ASca1Gou9RXwAzfn";
const proposalAuthority = "TGHXNib6pkKjdvwn95Z7E9qA5HFRCc9D4J";
const reviewAuthority = "TGHXNib6pkKjdvwn95Z7E9qA5HFRCc9D4J";
var MerkleDistributor = artifacts.require("MerkleDistributor.sol");

module.exports = async function(deployer) {
  
  deployer.deploy(MerkleDistributor, proposalAuthority, reviewAuthority, BTTAddress);
};
