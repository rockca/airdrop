# airdrop

## Compile

This is a Tronbox project using the truffle plugin (for tests as this used to be truffle-based). 

```sh
tronbox compile
```

## Deploy

before deploy, you must change the private key in sample-env, and then run 
```sh
source sample-env
```
second, change the proposalAuthority and reviewAuthority in 2_deploy_contracts.js to your own address.

can specify the network to choose the network you want to deploy in tronbox.js. you can add --reset to redeploy contract.
```sh
tronbox migrate --network <network>
```

## Operation

deploy contracts will generate one contract:MerkleDistributor


1. call MerkleDistributor:proposewMerkleRoot(root) to propose pending root from proposalAuthority
2. call MerkleDistributor:reviewPendingMerkleRoot(1) to review the pending root to root from reviewAuthority
3. call MerkleDistributor:setTotalAmount to set the total airdrop of this period
4. transfer enough WBTT to MerkleDistributor for airdrop

