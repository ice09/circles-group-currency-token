pragma abicoder v2;

import "forge-std/Test.sol";
import "../src/GroupCurrencyToken.sol";
import "../src/IHub.sol";
import "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract GroupCurrencyTokenTest is Test {

    uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;        
    uint256 trusterPrivateKey = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    uint256 trusteePrivateKey = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;

    function testMintGCT() external {
        Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        vm.startPrank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

        IHub hub = IHub(0x29b9a7fBb8995b2423a71cC17cf9810798F6C543);
        GroupCurrencyToken gct = new GroupCurrencyToken(address(hub), 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 0, "GCT", "GCT");
        address token = address(hub.userToToken(0x249fA3ecD95a53F742707D53688FCafbBd072f33));
        emit log_named_address("token", token);
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