pragma abicoder v2;

import "../lib/forge-std/src/Script.sol";
import "../src/GroupCurrencyTokenFactory.sol";
import "../src/GroupCurrencyToken.sol";
import "../src/IHub.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";


contract GroupCurrencyTokenDeploy is Script {

    GroupCurrencyToken gct;

    function run() external {
        // Setup & Deploy
        vm.startPrank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        vm.recordLogs();
        GroupCurrencyTokenFactory gctf = new GroupCurrencyTokenFactory();
        IHub hub = IHub(0x29b9a7fBb8995b2423a71cC17cf9810798F6C543);
        gctf.createGroupCurrencyToken(address(hub), 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 0, "GCT", "GCT");
        
        Vm.Log[] memory entries = vm.getRecordedLogs();
        address token = address(hub.userToToken(0x249fA3ecD95a53F742707D53688FCafbBd072f33));
        gct = GroupCurrencyToken(address(uint160(uint256(entries[1].topics[1]))));
        gct.addMemberToken(token);
        
        address[] memory cols = new address[](1);
        cols[0] = token;
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 50000000000000000000;
        vm.stopPrank();
        
        vm.prank(0x249fA3ecD95a53F742707D53688FCafbBd072f33);
        ERC20(token).transfer(address(gct), 50000000000000000000);

        // new address, not used before
        vm.prank(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
        gct.mint(cols, tokens);
    }

}