import "../src/IHub.sol";

contract MockHub is IHub {

    mapping (address => mapping (address => uint256)) public limits;
    mapping (address => address) public tokenToUser;
    mapping (address => address) public userToToken;

    function setTokenToUser(address token, address user) external {
        tokenToUser[token] = user;
        userToToken[user] = token;
    }

    function signup() external {
        emit Signup(msg.sender, 0x0000000000000000000000000000000000000001);
    }

    function organizationSignup() external {
        emit OrganizationSignup(msg.sender);
    }
    
    function trust(address trustee, uint256 amount) external {
        limits[msg.sender][trustee] = amount;
        emit Trust(msg.sender, trustee, amount);
    }

}