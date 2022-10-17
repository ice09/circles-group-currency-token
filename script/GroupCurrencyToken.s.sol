pragma abicoder v2;

import "forge-std/Script.sol";
import "../src/GroupCurrencyTokenFactory.sol";
import "../src/GroupCurrencyToken.sol";
import "../src/IHub.sol";
import "openzeppelin-contracts/token/ERC20/ERC20.sol";


contract GroupCurrencyTokenDeploy is Script {
    function run() external {
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;        
        uint256 trusterPrivateKey = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
        uint256 trusteePrivateKey = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;

        // Setup & Deploy
        vm.startBroadcast(deployerPrivateKey);
        GroupCurrencyTokenFactory gctf = new GroupCurrencyTokenFactory();
        IHub hub = IHub(0x29b9a7fBb8995b2423a71cC17cf9810798F6C543);

        vm.recordLogs();    
        hub.signup();

        // Create GCT
        gctf.createGroupCurrencyToken(address(hub), 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 0, "GCT", "GCT");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        GroupCurrencyToken gct = GroupCurrencyToken(address(uint160(uint256(entries[4].topics[1]))));
        address memberToken = abi.decode(entries[2].data, (address));
        gct.addMemberToken(memberToken);
        address[] memory cols = new address[](1);
        cols[0] = abi.decode(entries[2].data, (address));
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 50000000000000000000;
        ERC20 tokenCtr = ERC20(memberToken);
        tokenCtr.transfer(address(gct), 50000000000000000000);
        gct.mint(cols, tokens);
        vm.stopBroadcast();
    }
}