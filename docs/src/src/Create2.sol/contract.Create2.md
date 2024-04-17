# Create2
[Git Source](https://github.com/Armruo/foundry_first_project/blob/cb23cede88e4925cf081cdecc223353f14793e5d/src/Create2.sol)


## Functions
### deploy

部署函数


```solidity
function deploy(bytes32 salt, bytes memory creationCode) external payable returns (address addr);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`salt`|`bytes32`|用于计算最终地址。基本上可以是想要的任何随机值。|
|`creationCode`|`bytes`|所要部署合约的创建代码|


### computeAddress

注意：传递给此函数的所有参数都是32字节长，Solidity 中的地址长度为20字节；
它们都要作为32字节值存储在内存中，solidity前12字节被替换为0
因此，指向实际地址时需要跳过12字节


```solidity
function computeAddress(bytes32 salt, bytes32 creationCodeHash) external view returns (address addr);
```

## Errors
### Create2EmptyBytecode
旨在对工厂部署执行一些合理性检查，并在触发时回滚整个交易


```solidity
error Create2EmptyBytecode();
```

### Create2FailedDeployment

```solidity
error Create2FailedDeployment();
```

