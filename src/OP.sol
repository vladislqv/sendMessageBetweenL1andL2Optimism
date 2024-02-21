// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface ICrossDomainMessenger {
    function xDomainMessageSender() external view returns (address);

    function sendMessage(
        address target,
        bytes calldata message,
        uint32 gasLimit
    ) external;
}

contract Greeter {
    // ETH SEPOLIA MESSENGER - L1 0x58Cc85b8D04EA49cC6DBd3CbFFd00B4B8D6cb3ef
    // OP SEPOLIA MESSENGER - L2 0x4200000000000000000000000000000000000007
    address public immutable MESSENGER;
    address public remote_greeter;
    mapping(address => string) public greetings;

    constructor(address messenger) {
        MESSENGER = messenger;
    }

    function set_remote_greeter(address _remote_greeter) external {
        remote_greeter = _remote_greeter;
    }

    function set(address sender, string calldata greeting) external {
        require(msg.sender == MESSENGER, "Greeter: only messenger");
        require(
            ICrossDomainMessenger(MESSENGER).xDomainMessageSender() ==
                remote_greeter,
            "Greeter: only remote greeter"
        );
        greetings[sender] = greeting;
    }

    function send(string calldata greeting) external {
        ICrossDomainMessenger(MESSENGER).sendMessage({
            target: remote_greeter,
            message: abi.encodeCall(this.set, (msg.sender, greeting)),
            gasLimit: 200000
        });
    }
}
