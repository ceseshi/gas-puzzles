// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

contract OptimizedArraySum {
    // Do not modify this
    uint256[] array;

    // Do not modify this
    function setArray(uint256[] memory _array) external {
        require(_array.length <= 10, 'too long');
        array = _array;
    }

    /// Use a named return variable, less execution steps
    function getArraySum() external view returns (uint256 sum) {
        /// As the gas test does not initialize the array, it would be better not to cache the length, but we know it's better to do it
        uint256 length = array.length;
        for (uint256 i = 0; i < length;) {
            sum += array[i];
            unchecked { i++; }
        }
    }
}