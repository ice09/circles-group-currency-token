// SPDX-License-Identifier: AGPL
pragma solidity ^0.8.0;

interface IHub {

    function organizationSignup() external;
    function limits(address truster, address trustee) external returns (uint256);
    function tokenToUser(address token) external returns (address);
    function trust(address trustee, uint256 amount) external;

}