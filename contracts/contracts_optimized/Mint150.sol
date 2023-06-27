//SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// You may not modify this contract or the openzeppelin contracts
contract NotRareToken is ERC721 {
	mapping(address => bool) private alreadyMinted;

	uint256 private totalSupply;

	constructor() ERC721("NotRareToken", "NRT") {}

	function mint() external {
		totalSupply++;
		_safeMint(msg.sender, totalSupply);
		alreadyMinted[msg.sender] = true;
	}
}

contract OptimizedAttacker {

	constructor(address victim) {

		/// The owner has already minted a random number of tokens between 1 and 5
		/// Its address is the first hardhat account
		uint256 ownerBalance = NotRareToken(victim).balanceOf(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

		/// We will start from the next index available up to 150
		uint256 idx;
		uint256 last;

		unchecked {
		 	idx = ownerBalance + 1;
			last = idx + 150;
		}

		/**
		Separate the mints from the transfers, because if we did mint-transfer-mint-transfer, the self balance in storage would be changing 0-1-0-1-1-0-1,
		which is much more expensive than doing 0-1-2-3-4-5 and then 5-4-3-2-1-0
		*/
		while (idx < last) {
			NotRareToken(victim).mint();
			unchecked {
				idx++;
			}
		}

		/// Transfer assets to us
		unchecked { idx = ownerBalance + 1; }

		while (idx < last) {
			NotRareToken(victim).transferFrom(address(this), msg.sender, idx);
			unchecked {
				idx++;
			}
		}
	}
}
