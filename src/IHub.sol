// SPDX-License-Identifier: AGPL
pragma solidity ^0.8.0;

interface IHub {

    function signup() external;
    function organizationSignup() external;

    function tokenToUser(address token) external returns (address);
    function userToToken(address token) external returns (address);
    function limits(address truster, address trustee) external returns (uint256);

    function trust(address trustee, uint256 amount) external;

}