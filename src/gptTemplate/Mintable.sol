// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

// 可增发的BRC20代币SL
contract SL is ERC20Upgradeable, OwnableUpgradeable, PausableUpgradeable {
     function initialize() public initializer {
          __ERC20_init("SL", "SL");
          __Ownable_init();
          __Pausable_init();

          unit256 initialSupply = 1 * 10 ** 18;
          _mint(msg.sender, initialSupply);
     }

     function mint(address to unit256 amount) public onlyOwner{
          _mint(to, amount)
     }

     function _transfer(address from, address to, uint256 amount) internal override {
        super._transfer(from, to, amount);
    }

     


     

}