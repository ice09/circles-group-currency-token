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
        GroupCurrencyTokenFactory gctf = new GroupCurrencyTokenFactory();
        IHub hub = IHub(0x29b9a7fBb8995b2423a71cC17cf9810798F6C543);

        vm.recordLogs();
        
        hub.signup();
        // Create GCT
        gctf.createGroupCurrencyToken(address(hub), 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 0, "GCT", "GCT");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        address memberToken = abi.decode(entries[2].data, (address));
        gct = GroupCurrencyToken(address(uint160(uint256(entries[4].topics[1]))));
        gct.addMemberToken(memberToken);
        address[] memory cols = new address[](1);
        cols[0] = abi.decode(entries[2].data, (address));
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 50000000000000000000;
        
        ERC20 tokenCtr = ERC20(memberToken);
        tokenCtr.transfer(address(gct), 50000000000000000000);
        gct.mint(cols, tokens);
        
        vm.stopPrank();
        _testMintGCT();
    }

    function _testMintGCT() public {
        vm.startPrank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

        IHub hub = IHub(0x29b9a7fBb8995b2423a71cC17cf9810798F6C543);
        address token = address(hub.userToToken(0x249fA3ecD95a53F742707D53688FCafbBd072f33));
        //emit log_named_address("token", token);
        ERC20 tokenCtr = ERC20(token);
        gct.addMemberToken(token);
        address[] memory cols = new address[](1);
        cols[0] = token;
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 50;
        vm.stopPrank();
        
        vm.startPrank(0x249fA3ecD95a53F742707D53688FCafbBd072f33);
        tokenCtr.transfer(address(gct), 50);
        gct.mint(cols, tokens);
    }
}