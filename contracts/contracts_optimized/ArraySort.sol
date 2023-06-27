// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

contract OptimizedArraySort {
    /// Get the input array as memory
    function sortArray(uint256[] memory _data) external pure returns (uint256[] memory) {
        uint256 dataLen = _data.length;

        /// Do not create another working copy, use and return the input array
        for (uint256 i = 0; i < dataLen;) {
            uint256 j;
            unchecked { j = i+1; }
            for (; j < dataLen;) {
                // Cache values
                uint256 _data_i = _data[i];
                uint256 _data_j = _data[j];

                if(_data_i > _data_j) {
                    /// Use tuples to swap values
                    (_data[i], _data[j]) = (_data_j, _data_i);
                }
                unchecked { j++; }
            }
            unchecked { i++; }
        }
        return _data;
    }
}
