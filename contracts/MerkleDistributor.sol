// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.5.8;
import "./IToken.sol";

// File: MerkleDistributor.sol

// MerkleDistributor for airdrop to BTFS staker
contract MerkleDistributor {

    bytes32[] public merkleRoots;
    bytes32 public pendingMerkleRoot;
    uint256 public lastRoot;

    // admin address which can propose adding a new merkle root
    address public proposalAuthority;
    // admin address which approves or rejects a proposed merkle root
    address public reviewAuthority;
    // the address of airdrop token
    address public tokenAddress;
    address public owner;

    struct statistics {
        uint256 total;
        uint256 claimed;
    }

    // Record the claim information of each period
    statistics[] public claimInfo;

    event Claimed(
        uint256 merkleIndex,
        uint256 index,
        address account,
        uint256 amount
    );

    // This is a packed array of booleans.
    mapping(uint256 => mapping(uint256 => uint256)) private claimedBitMap;

    constructor(address _proposalAuthority, address _reviewAuthority, address token) public {
        proposalAuthority = _proposalAuthority;
        reviewAuthority = _reviewAuthority;
        tokenAddress = token;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    function upgradeOwner(address newOwner) external onlyOwner {
      require(newOwner != owner && newOwner != address(0), "invalid newOwner");
      owner = newOwner;
    }

    function setToken(address _token) external onlyOwner {
        tokenAddress = _token;
    }

    function setProposalAuthority(address _account) public {
        require(msg.sender == proposalAuthority);
        proposalAuthority = _account;
    }

    function setReviewAuthority(address _account) public {
        require(msg.sender == reviewAuthority);
        reviewAuthority = _account;
    }

    // set the total amount of airdrop this period
    function setTotalAmount(uint256 totalAmount) external onlyOwner {
        statistics record;
        record.total = totalAmount;
        record.claimed = 0;
        claimInfo.push(record);
    }

    // Each week, the proposal authority calls to submit the merkle root for a new airdrop.
    function proposewMerkleRoot(bytes32 _merkleRoot) public {
        require(msg.sender == proposalAuthority);
        require(pendingMerkleRoot == 0x00);
        require(merkleRoots.length < 52);
        require(block.timestamp > lastRoot + 604800);
        pendingMerkleRoot = _merkleRoot;
    }

    // After validating the correctness of the pending merkle root, the reviewing authority
    // calls to confirm it and the distribution may begin.
    function reviewPendingMerkleRoot(bool _approved) public {
        require(msg.sender == reviewAuthority);
        require(pendingMerkleRoot != 0x00);
        if (_approved) {
            merkleRoots.push(pendingMerkleRoot);
            lastRoot = block.timestamp / 604800 * 604800;
        }
        delete pendingMerkleRoot;
    }

    function isClaimed(uint256 merkleIndex, uint256 index) public view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[merkleIndex][claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 merkleIndex, uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[merkleIndex][claimedWordIndex] = claimedBitMap[merkleIndex][claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(uint256 merkleIndex, uint256 index, uint256 amount, bytes32[] calldata merkleProof) external {
        require(merkleIndex < merkleRoots.length, "MerkleDistributor: Invalid merkleIndex");
        require(!isClaimed(merkleIndex, index), "MerkleDistributor: Drop already claimed.");

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, msg.sender, amount));
        require(verify(merkleProof, merkleRoots[merkleIndex], node), "MerkleDistributor: Invalid proof.");

        // Mark it claimed and send the token.
        _setClaimed(merkleIndex, index);

        claimInfo[merkleIndex].claimed = claimInfo[merkleIndex].claimed.add(amount);

        // transfer airdrop to msg.sender
        require(Token(tokenAddress).transfer(msg.sender, amount), "send airdrop error");

        emit Claimed(merkleIndex, index, msg.sender, amount);
    }

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash == root;
    }

}
