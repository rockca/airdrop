const BTTAddress = "TBWmwfchWFCcyASCytK2NAhHbWGwaJStLo";
const proposalAuthority = "TGHXNib6pkKjdvwn95Z7E9qA5HFRCc9D4J";
const reviewAuthority = "TGHXNib6pkKjdvwn95Z7E9qA5HFRCc9D4J";
var MerkleDistributor = artifacts.require("MerkleDistributor.sol");

module.exports = async function(deployer) {
  
  deployer.deploy(MerkleDistributor, proposalAuthority, reviewAuthority, BTTAddress);
};
