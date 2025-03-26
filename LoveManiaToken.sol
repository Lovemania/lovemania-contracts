// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LoveMania is ERC20, ERC20Permit, Ownable {
    uint256 private constant _initialSupply = 1e9;
    uint256 public taxFee = 5;
    address public revenueAddress;

    event Transfer(address indexed from, address indexed to, uint256 amount, uint256 amountAfterTax, uint256 fee);

    constructor(address initialOwner) ERC20("LoveMania", "LMNA") ERC20Permit("LoveMania") Ownable(initialOwner) {
        revenueAddress = initialOwner;
        _mint(initialOwner, _initialSupply * 10**decimals());
    }

    function setTaxFee(uint256 _fee) public onlyOwner {
        require(_fee <= 10, "Max fee is 10%");
        taxFee = _fee;
    }

    function _update(address sender, address recipient, uint256 amount) internal override {
        uint256 fee = (amount * taxFee) / 100;
        uint256 amountAfterTax = amount - fee;
        super._update(sender, revenueAddress, fee);
        super._update(sender, recipient, amountAfterTax);
        emit Transfer(sender, recipient, amount, amountAfterTax, fee);
    }
}
