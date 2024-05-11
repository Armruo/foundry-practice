// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";
import "@thirdweb-dev/contracts/base/Staking20Base.sol";

contract StakeContract {
    SLToken public token;
    mapping(address => uint256) public stakes;
    mapping(address => uint256) public lastStakeTime;
    mapping(address => uint256) public lastClaimTime;
    mapping(address => uint256) public claimableRewards;

    uint256 public pledgeRate; // Pledge rate in percentage (e.g., 20%)
    uint256 public feeRate; // Fee rate for non-whitelisted addresses in percentage (e.g., 0.5%)
    address public feeWhitelist; // Address that is exempt from fees

    // Event to log staking
    event Staked(address indexed staker, uint256 amount);
    
    // Event to log unstaking
    event Unstaked(address indexed staker, uint256 amount);

    // Event to log reward claim
    event RewardClaimed(address indexed staker, uint256 amount);

    constructor(address _tokenAddress, uint256 _pledgeRate, uint256 _feeRate, address _feeWhitelist) {
        token = BRC20(_tokenAddress);
        pledgeRate = _pledgeRate;
        feeRate = _feeRate;
        feeWhitelist = _feeWhitelist;
    }

    // Function to stake tokens
    function stake(uint256 _amount) external {
        require(_amount > 0, "Invalid amount");

        // Transfer tokens to stake contract
        token.transferFrom(msg.sender, address(this), _amount);
        
        // Calculate rewards
        uint256 rewards = calculateRewards(msg.sender);

        // Update stakes
        stakes[msg.sender] += _amount;
        lastStakeTime[msg.sender] = block.timestamp;
        lastClaimTime[msg.sender] = block.timestamp;
        claimableRewards[msg.sender] += rewards;

        emit Staked(msg.sender, _amount);
    }

    // Function to withdraw staked tokens
    function unstake(uint256 _amount) external {
        require(stakes[msg.sender] >= _amount, "Insufficient staked amount");

        // Calculate rewards
        uint256 rewards = calculateRewards(msg.sender);

        // Update stakes
        stakes[msg.sender] -= _amount;
        lastStakeTime[msg.sender] = block.timestamp;
        lastClaimTime[msg.sender] = block.timestamp;
        claimableRewards[msg.sender] += rewards;

        // Transfer staked tokens back to the staker
        token.transfer(msg.sender, _amount);

        emit Unstaked(msg.sender, _amount);
    }

    // Function to calculate rewards
    function calculateRewards(address _staker) internal view returns (uint256) {
        uint256 timeSinceLastClaim = block.timestamp - lastClaimTime[_staker];
        uint256 stakedAmount = stakes[_staker];
        uint256 rewards = (stakedAmount * pledgeRate * timeSinceLastClaim) / (365 days * 100);

        return rewards;
    }

    // Function to claim rewards
    function claimRewards() external {
        uint256 rewards = calculateRewards(msg.sender);

        require(rewards > 0, "No rewards to claim");

        // Update last claim time and claimable rewards
        lastClaimTime[msg.sender] = block.timestamp;
        claimableRewards[msg.sender] = 0;

        // Transfer rewards to the staker
        token.transfer(msg.sender, rewards);

        emit RewardClaimed(msg.sender, rewards);
    }

    // Function to charge fees for transactions
    function _chargeFees(address _from, address _to, uint256 _amount) internal {
        if (_from != feeWhitelist && _to != feeWhitelist) {
            uint256 fee = (_amount * feeRate) / 10000; // Fee rate is in basis points
            token.transferFrom(_from, address(this), fee);
        }
    }

    // Override transfer function to charge fees
    function transfer(address _to, uint256 _value) external returns (bool) {
        _chargeFees(msg.sender, _to, _value);
        return token.transfer(_to, _value);
    }

    // Override transferFrom function to charge fees
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        _chargeFees(_from, _to, _value);
        return token.transferFrom(_from, _to, _value);
    }
}