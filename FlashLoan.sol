pragma solidity 0.8.10;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/aave/aave-v3-core/blob/master/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
contract FlashLoan is FlashLoanSimpleReceiverBase, Ownable {

    constructor (address _poolAddress) FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_poolAddress)) {
    }

    address assetAddress;
    error NotEnoughFunds();

    function executeOperation(
    address asset,
    uint256 amount,
    uint256 premium,
    address initiator,
    bytes calldata params
  ) external virtual returns (bool) {
    IERC20 token = IERC20(asset);
    uint256 debt = amount + premium;
    if (token.balanceOf(address(this)) < debt) revert NotEnoughFunds();
    token.approve(address(POOL), debt);
    return true;
  }

  function flashloan(address _assetAddress) external {
    uint256 amount = 1 ether;
    assetAddress = _assetAddress;
    address recieverAddress = address(this);
    bytes memory params = '';
    uint16 referralCode = 0;
    POOL.flashLoanSimple(recieverAddress, assetAddress, amount, params, referralCode);
    }

    function withdraw() external onlyOwner {
        IERC20 token = IERC20(assetAddress);
        token.transfer(owner(), token.balanceOf(address(this)));
    }

}
