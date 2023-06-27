// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

contract OptimizedDistribute {

    /// Use immutables as we don't need to change the values later
    address immutable contributor1;
    address immutable contributor2;
    address immutable contributor3;
    address immutable contributor4;
    uint256 immutable distributeTime;
    uint256 immutable distributeAmount;

    constructor(address[4] memory _contributors) payable {
        /// Pprecalculate everything
        contributor1 = _contributors[0];
        contributor2 = _contributors[1];
        contributor3 = _contributors[2];
        contributor4 = _contributors[3];
        distributeTime = block.timestamp + 1 weeks;
        distributeAmount = msg.value / 4;
    }

    function distribute() external {
        require(
            block.timestamp > distributeTime,
            "cannot distribute yet"
        );

        /// Use selfdestroy for the last address, which is cheaper
        payable(contributor1).send(distributeAmount);
        payable(contributor2).send(distributeAmount);
        payable(contributor3).send(distributeAmount);
        selfdestruct(payable(contributor4));
    }
}