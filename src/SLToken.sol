// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SLToken is ERC20, Ownable {
    mapping(address => bool) public feeWhiteList;
    uint256 public feePercentage = 5; // 0.5%

    constructor() ERC20("SL", "SL") {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        if (!feeWhiteList[sender]) {
            uint256 fee = (amount * feePercentage) / 1000;
            super._transfer(sender, address(this), fee);
            amount -= fee;
        }
        super._transfer(sender, recipient, amount);
    }

    function setFeeWhiteList(address _address, bool status) external onlyOwner {
        feeWhiteList[_address] = status;
    }

    function setFeePercentage(uint256 _feePercentage) external onlyOwner {
        feePercentage = _feePercentage;
    }
}

contract StakeContract {
    struct Stake {
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => Stake) public stakers;
    SLToken public slToken;

    constructor(SLToken _slToken) {
        slToken = _slToken;
    }

    function stake(uint256 amount, uint256 lockTime) external {
        require(amount > 0, "Cannot stake 0");
        require(slToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        uint256 unlockTime = block.timestamp + lockTime;
        stakers[msg.sender] = Stake(amount, unlockTime);
    }

    function unstake() external {
        Stake memory userStake = stakers[msg.sender];
        require(userStake.amount > 0, "No stake to withdraw");
        require(block.timestamp >= userStake.unlockTime, "Stake still locked");
        uint256 amount = userStake.amount;
        delete stakers[msg.sender];
        require(slToken.transfer(msg.sender, amount), "Transfer failed");
    }
}
