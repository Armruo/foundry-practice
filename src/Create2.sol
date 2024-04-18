// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

contract Create2 {
    /**
     * 旨在对工厂部署执行一些合理性检查，并在触发时回滚整个交易
     */
    error Create2EmptyBytecode(); // 传递给deploy函数的字节码为空 触发
    error Create2FailedDeployment(); // 部署由于任何原因失败 触发

    /**
     * 部署函数
     * @param salt 用于计算最终地址。基本上可以是想要的任何随机值。
     * @param creationCode 所要部署合约的创建代码
     */
    function deploy(bytes32 salt, bytes memory creationCode) external payable returns (address addr) {
        // 回滚语句
        if (creationCode.length == 0) {
            revert Create2EmptyBytecode();
        }

        // 从内联汇编中调用 CREATE2操作码（https://docs.soliditylang.org/en/latest/yul.html#evm-dialect）
        assembly {
            addr :=
                create2(
                    callvalue(), // 作为交易的一部分发送到工厂合约的ETH数量。可将其视为 msg.value 的低级版本。
                    // 字节码所在内存范围。接受一个对 bytes 变量 bytecode 在内存中的位置的引用，
                    // 并跳过 32字节（十六进制中的 0x20）以指向实际的字节码。
                    add(creationCode, 0x20),
                    mload(creationCode), // 字节码所在内存范围。
                    salt
                )
        }

        // 若由于任何原因部署失败，则回滚整个交易（此时CREATE2操作码返回一个0地址）
        if (addr == address(0)) {
            revert Create2FailedDeployment();
        }
    }

    /**
     * 注意：传递给此函数的所有参数都是32字节长，Solidity 中的地址长度为20字节；
     * 它们都要作为32字节值存储在内存中，solidity前12字节被替换为0
     * 因此，指向实际地址时需要跳过12字节
     */
    function computeAddress(bytes32 salt, bytes32 creationCodeHash) external view returns (address addr) {
        address contractAddress = address(this);

        // 使用 内联汇编 来通过 执行与CREATE2操作码相同的计算 来计算地址
        // 参考CREATE2操作码用于计算地址的公式：
        // keccak256(0xff ++ address ++ salt ++ keccak256(bytecode))[12:]
        assembly {
            // 将空闲内存指针加载到内存中。这是指向内存数组中下一个空闲内存槽的指针。
            // 了解更多信息：https://docs.soliditylang.org/en/latest/assembly.html#memory-management
            let ptr := mload(0x40)

            mstore(add(ptr, 0x40), creationCodeHash) // 将 bytecodeHash 存储在由 ptr + 0x40 指向的内存位置，即 ptr+ 64 字节。
            mstore(add(ptr, 0x20), salt) // 将 salt 存储在由 ptr + 0x20 指向的内存位置
            mstore(ptr, contractAddress) // 将 contractAddress 存储在由 ptr 指向的内存位置。

            let start := add(ptr, 0x0b) // 创建一个名为 start 的新变量，指向内存位置 ptr + 0x0b ，即 ptr + 11 字节。
            // 使用mstore8操作码在内存位置存储单个字节。
            mstore8(start, 0xff) // 这里将值0xff存储在由 start 指向的内存位置，它占据内存槽的第 12 个字节。

            // 所有值都打包到对应的正确内存位置后。
            // 可以在从 start 开始的内存槽上调用 keccak256，第二个参数传内存槽的长度
            // 这将返回一个32字节的哈希，截断以获得最终地址
            addr := keccak256(start, 85)
        }
    }
}
