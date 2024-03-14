// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, stdJson} from "forge-std/Script.sol";
import {LibUpgradeableProxy} from "upgradeable-proxy-utils/LibUpgradeableProxy.sol";
import {DelegationManager} from "eigenlayer-contracts/src/contracts/core/DelegationManager.sol";
import {StrategyManager} from "eigenlayer-contracts/src/contracts/core/StrategyManager.sol";
import {StrategyBaseTVLLimits} from "eigenlayer-contracts/src/contracts/strategies/StrategyBaseTVLLimits.sol";
import {Slasher} from "eigenlayer-contracts/src/contracts/core/Slasher.sol";
import {PauserRegistry} from "eigenlayer-contracts/src/contracts/permissions/PauserRegistry.sol";
import {DelayedWithdrawalRouter} from "eigenlayer-contracts/src/contracts/pods/DelayedWithdrawalRouter.sol";
import {EigenPodManager} from "eigenlayer-contracts/src/contracts/pods/EigenPodManager.sol";
import {EigenPod} from "eigenlayer-contracts/src/contracts/pods/EigenPod.sol";
import {BeaconChainOracle} from "eigenlayer-contracts/src/contracts/pods/BeaconChainOracle.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {Timelock} from "../src/Timelock.sol";

contract Deploy is Script {
    using stdJson for string;

    uint256 internal chain;
    string internal root = vm.projectRoot();
    string internal configDir = string.concat(root, "/config/");
    string internal configFile;

    mapping(string => address) public strategyFor;
    address[] public strategies;

    error InvalidChain();

    function setUp() public {
        chain = block.chainid;
    }

    function run() public virtual {
        if (chain == 1) {
            configFile = string.concat(configDir, "mainnet.json");
        } else if (chain == 5) {
            configFile = string.concat(configDir, "goerli.json");
        } else if (chain == 1700) {
            configFile = string.concat(configDir, "holesky.json");
        } else if (chain == 31337) {
            configFile = string.concat(configDir, "local.json");
            vm.startBroadcast();
            deploy();
            vm.stopBroadcast();
        } else {
            try vm.activeFork() returns (uint256) {
                revert InvalidChain();
            } catch {
                /// Testing env
                deploy();
            }
        }
    }

    function deploy() public {}
    /// hack to get compiler to compile the artifacts
    function _precompileProxyContracts() private pure {
        bytes memory dummy;
        dummy = type(StrategyManager).creationCode;
        dummy = type(StrategyBaseTVLLimits).creationCode;
        dummy = type(EigenPodManager).creationCode;
        dummy = type(EigenPod).creationCode;
        dummy = type(BeaconChainOracle).creationCode;
        dummy = type(DelayedWithdrawalRouter).creationCode;
        dummy = type(DelegationManager).creationCode;
        dummy = type(Slasher).creationCode;
        dummy = type(PauserRegistry).creationCode;
        dummy = type(Timelock).creationCode;
        dummy = type(ProxyAdmin).creationCode;
    }
}
