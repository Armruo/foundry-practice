pragma solidity >=0.8.25 <0.9.0;

import "forge-std/src/Test.sol";

error Unauthorized();

/**
 * @title 验证“智能合约只能由所有者调用”编写的测试
 */
contract OwnerUpOnly {
    address public immutable owner;
    uint256 public count;

    constructor() {
        owner = msg.sender;
    }

    function increment() external {
        if (msg.sender != owner) {
            revert Unauthorized();
        }
        count++;
    }
}

contract OwnerUpOnlyTest is Test {
    OwnerUpOnly upOnly;

    function setUp() public {
        upOnly = new OwnerUpOnly();
    }

    function testIncrementAsOwner() public {
        assertEq(upOnly.count(), 0);
        upOnly.increment();
        assertEq(upOnly.count(), 1);
    }

    // 不是所有者的人不能增加计数
    function testFailIncrementAsNotOwner() public {
        vm.prank(address(0)); // cheatcode【prank】会将我们的身份改为零地址再进行下一句
        upOnly.increment();
    }

    // Notice that we replaced `testFail` with `test`
    function testIncrementAsNotOwner() public {
        // cheatcode【expectRevert】：make sure that we reverted because we are not the owner
        vm.expectRevert(Unauthorized.selector);
        vm.prank(address(0));
        upOnly.increment();
    }
}
