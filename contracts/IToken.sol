// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;
interface Token {
    function transfer(address dst, uint256 sad) external returns (bool);
    function balanceOf(address guy) external view returns (uint256);
}