// SPDX-License-Identifier: AGPL
pragma solidity ^0.8.0;

interface IHub {

    event Signup(address indexed user, address token);
    event OrganizationSignup(address indexed organization);
    event Trust(address indexed canSendTo, address indexed user, uint256 limit);
    event HubTransfer(address indexed from, address indexed to, uint256 amount);

    function signup() external;
    function organizationSignup() external;

    function tokenToUser(address token) external returns (address);
    function userToToken(address token) external returns (address);
    function limits(address truster, address trustee) external returns (uint256);

    function trust(address trustee, uint256 amount) external;

}