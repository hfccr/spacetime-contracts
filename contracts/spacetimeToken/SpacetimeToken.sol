// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract SpacetimeToken is ERC20PresetMinterPauser {
    constructor() ERC20PresetMinterPauser("Spacetime", "SPT") {}

    function permissionlessTransferFrom(address from, address to, uint256 amount) public {
        require(hasRole(keccak256("MINTER"), msg.sender), "Permission not granted");
        _transfer(from, to, amount);
    }
}
