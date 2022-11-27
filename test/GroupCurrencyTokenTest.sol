pragma abicoder v2;

import "../lib/forge-std/src/Test.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../src/GroupCurrencyToken.sol";
import "../src/IHub.sol";
import "./MockHub.sol";
import "./MockToken.sol";

contract GroupCurrencyTokenTest is Test {

    event Trust(address indexed _canSendTo, address indexed _user, uint256 _limit);
    event OrganizationSignup(address indexed _organization);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Minted(address indexed _receiver, uint256 _amount, uint256 _mintAmount, uint256 _mintFee);
    event MemberTokenAdded(address indexed _memberToken);
    event MemberTokenRemoved(address indexed _memberToken);
    event DelegatedTrusteeAdded(address indexed _delegatedTrustee);
    event DelegatedTrusteeRemoved(address indexed _delegatedTrustee);

    function testMintingModes() external {
        MockHub mockHub = new MockHub();
        GroupCurrencyToken gct = new GroupCurrencyToken(address(mockHub), address(this), address(this), 0, "GCT", "GCT");
        assertFalse(gct.onlyOwnerCanMint(), "onlyOwnerCanMint should be false.");
        assertFalse(gct.onlyTrustedCanMint(), "onlyTrustedCanMint should be false.");
        gct.setOnlyOwnerCanMint(true);
        assertTrue(gct.onlyOwnerCanMint(), "onlyOwnerCanMint should be true.");
        gct.setOnlyTrustedCanMint(true);
        assertTrue(gct.onlyTrustedCanMint(), "onlyOwnerCanMint should be true.");
        gct.setOnlyOwnerCanMint(false);
        assertFalse(gct.onlyOwnerCanMint(), "onlyOwnerCanMint should be false.");
        gct.setOnlyTrustedCanMint(false);
        assertFalse(gct.onlyTrustedCanMint(), "onlyTrustedCanMint should be false.");
    }

    function testAddMemberTokenEvents() external {
        MockHub mockHub = new MockHub();
        GroupCurrencyToken gct = new GroupCurrencyToken(address(mockHub), address(this), address(this), 0, "GCT", "GCT");

        address user = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        MockToken mockToken = new MockToken("GCT", "GCT", 50);
        mockHub.setTokenToUser(address(mockToken), user);

        vm.expectEmit(true, true, false, true, address(mockHub));
        emit Trust(address(gct), user, 100);
        vm.expectEmit(true, true, false, true, address(gct));
        emit MemberTokenAdded(user);
        
        gct.addMemberToken(address(mockToken));
    }

    function testRemoveMemberTokenEvents() external {
        MockHub mockHub = new MockHub();
        GroupCurrencyToken gct = new GroupCurrencyToken(address(mockHub), address(this), address(this), 0, "GCT", "GCT");

        address user = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        MockToken mockToken = new MockToken("GCT", "GCT", 50);
        mockHub.setTokenToUser(address(mockToken), user);

        gct.addMemberToken(address(mockToken));

        vm.expectEmit(true, true, false, true, address(mockHub));
        emit Trust(address(gct), user, 0);
        vm.expectEmit(true, true, false, true, address(gct));
        emit MemberTokenRemoved(user);

        gct.removeMemberToken(address(mockToken));
    }

    function testAddDelegatedTrusteeEvents() external {
        MockHub mockHub = new MockHub();
        GroupCurrencyToken gct = new GroupCurrencyToken(address(mockHub), address(this), address(this), 0, "GCT", "GCT");

        vm.expectEmit(true, true, false, true, address(gct));
        emit DelegatedTrusteeAdded(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        
        gct.addDelegatedTrustee(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    }

    function testRemoveDelegatedTrusteeEvents() external {
        MockHub mockHub = new MockHub();
        GroupCurrencyToken gct = new GroupCurrencyToken(address(mockHub), address(this), address(this), 0, "GCT", "GCT");

        gct.addDelegatedTrustee(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

        vm.expectEmit(true, true, false, true, address(gct));
        emit DelegatedTrusteeRemoved(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        
        gct.removeDelegatedTrustee(0);
    }

    function testFailOnlyOwnerCanAddDelegatedTrustee() external {
        MockHub mockHub = new MockHub();
        GroupCurrencyToken gct = new GroupCurrencyToken(address(mockHub), address(this), 0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 0, "GCT", "GCT");
        gct.addDelegatedTrustee(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    }

    function testFailOnlyOwnerCanAddMemberToken() external {
        MockHub mockHub = new MockHub();
        GroupCurrencyToken gct = new GroupCurrencyToken(address(mockHub), address(this), 0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 0, "GCT", "GCT");
        gct.addMemberToken(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    }

    function testFailMintingAmountExceedsBalance() external {
        MockHub mockHub = new MockHub();
        GroupCurrencyToken gct = new GroupCurrencyToken(address(mockHub), address(this), address(this), 0, "GCT", "GCT");
        MockToken mockToken = new MockToken("GCT", "GCT", 49);
        gct.addMemberToken(address(mockToken));
        address[] memory cols = new address[](1);
        cols[0] = address(mockToken);
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 50;
        mockToken.transfer(address(gct), 50);
        
        gct.mint(cols, tokens);
    }

    function testFailMintingNoMemberToken() external {
        MockHub mockHub = new MockHub();
        GroupCurrencyToken gct = new GroupCurrencyToken(address(mockHub), address(this), address(this), 0, "GCT", "GCT");
        MockToken mockToken = new MockToken("GCT", "GCT", 50);
        
        address[] memory cols = new address[](1);
        cols[0] = address(mockToken);
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 50;
        mockToken.transfer(address(gct), 50);
        gct.mint(cols, tokens);
    }

    function testFailMintingMemberTokenRemoved() external {
        MockHub mockHub = new MockHub();
        GroupCurrencyToken gct = new GroupCurrencyToken(address(mockHub), address(this), address(this), 0, "GCT", "GCT");
        MockToken mockToken = new MockToken("GCT", "GCT", 50);
        gct.addMemberToken(address(mockToken));
        address[] memory cols = new address[](1);
        cols[0] = address(mockToken);
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 50;
        mockToken.transfer(address(gct), 50);
        gct.removeMemberToken(address(mockToken));
        gct.mint(cols, tokens);
    }

    function testFailMintingNoDelegateTrustee() external {
        MockHub mockHub = new MockHub();
        GroupCurrencyToken gct = new GroupCurrencyToken(address(mockHub), address(this), address(this), 0, "GCT", "GCT");
        MockToken mockToken = new MockToken("GCT", "GCT", 50);
        
        address[] memory cols = new address[](1);
        cols[0] = address(mockToken);
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 50;
        mockToken.transfer(address(gct), 50);
        gct.mint(cols, tokens);
    }

    function testMintingDelegateTrustee() external {
        MockHub mockHub = new MockHub();
        GroupCurrencyToken gct = new GroupCurrencyToken(address(mockHub), address(this), address(this), 0, "GCT", "GCT");
        MockToken mockToken = new MockToken("GCT", "GCT", 50);
        address trustee = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        mockHub.setTokenToUser(address(mockToken), address(this));
        gct.addDelegatedTrustee(trustee);
        vm.prank(trustee);
        mockHub.trust(address(this), 100);
        gct.delegateTrust(0, address(this));

        address[] memory cols = new address[](1);
        cols[0] = address(mockToken);
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 50;
        mockToken.transfer(address(gct), 50);

        setupExpectEmitMinted(address(this), address(gct));

        gct.mint(cols, tokens);
    }

    function testFailMintingNoCollateralInGCT() external {
        MockHub mockHub = new MockHub();
        GroupCurrencyToken gct = new GroupCurrencyToken(address(mockHub), address(this), address(this), 0, "GCT", "GCT");
        MockToken mockToken = new MockToken("GCT", "GCT", 50);
        address trustee = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        mockHub.setTokenToUser(address(mockHub), trustee);
        gct.addMemberToken(address(mockToken));
        address[] memory cols = new address[](1);
        cols[0] = address(mockToken);
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 50;
        
        gct.mint(cols, tokens);
    }

    function testMintingSucceeds() external {
        MockHub mockHub = new MockHub();
        GroupCurrencyToken gct = new GroupCurrencyToken(address(mockHub), address(this), address(this), 0, "GCT", "GCT");
        MockToken mockToken = new MockToken("GCT", "GCT", 50);
        address trustee = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        mockHub.setTokenToUser(address(mockToken), trustee);
        gct.addMemberToken(address(mockToken));
        address[] memory cols = new address[](1);
        cols[0] = address(mockToken);
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 50;
        mockToken.transfer(address(gct), 50);
        
        setupExpectEmitMinted(address(this), address(gct));

        gct.mint(cols, tokens);
    }

    function testMintingSucceedsWithOnlyTrustedCanMint() external {
        MockHub mockHub = new MockHub();
        GroupCurrencyToken gct = new GroupCurrencyToken(address(mockHub), address(this), address(this), 0, "GCT", "GCT");
        MockToken mockToken = new MockToken("GCT", "GCT", 50);
        address trustee = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        mockHub.setTokenToUser(address(mockToken), trustee);
        gct.addMemberToken(address(mockToken));
        gct.setOnlyTrustedCanMint(true);
        address[] memory cols = new address[](1);
        cols[0] = address(mockToken);
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 50;
        mockToken.transfer(address(gct), 50);
        
        mockHub.setTokenToUser(0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
        gct.addMemberToken(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

        setupExpectEmitMinted(0x70997970C51812dc3A010C7d01b50e0d17dc79C8, address(gct));

        vm.prank(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
        gct.mint(cols, tokens);
    }

    function testMintingSucceedsWithOnlyOwnerCanMint() external {
        MockHub mockHub = new MockHub();
        GroupCurrencyToken gct = new GroupCurrencyToken(address(mockHub), address(this), address(this), 0, "GCT", "GCT");
        MockToken mockToken = new MockToken("GCT", "GCT", 50);
        address trustee = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        mockHub.setTokenToUser(address(mockToken), trustee);
        gct.addMemberToken(address(mockToken));
        gct.setOnlyOwnerCanMint(true);
        address[] memory cols = new address[](1);
        cols[0] = address(mockToken);
        uint256[] memory tokens = new uint256[](1);
        tokens[0] = 50;
        mockToken.transfer(address(gct), 50);
    
        setupExpectEmitMinted(address(this), address(gct));

        gct.mint(cols, tokens);
    }

    function setupExpectEmitMinted(address from, address gct) private {
        vm.expectEmit(false, false, false, false);
        emit Transfer(0x0000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000, 0);
        vm.expectEmit(false, false, false, false);
        emit Transfer(0x0000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000, 0);
        
        vm.expectEmit(true, true, false, true, gct);
        emit Minted(from, 50, 50, 0);
    }


}