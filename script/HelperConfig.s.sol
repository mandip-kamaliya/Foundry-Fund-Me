
// SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
contract HelperConfig is Script{
    MockV3Aggregator MockPriceFeed;
    Networkconfig public activeNetworkconfig;
    uint8 public constant DECIMAL = 8;
    int256 public constant INITIAL_PRICE=2000e8;
    struct Networkconfig {
        address priceFeed; 
    }
    function getsepoliaethconfig() public pure returns(Networkconfig memory){
        Networkconfig memory sepoliaconfig= Networkconfig({
            priceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaconfig;
    }
    function getanvilconfig() public  returns(Networkconfig memory){
        if(activeNetworkconfig.priceFeed != address(0)){
            return activeNetworkconfig;
        }
        vm.startBroadcast();
        MockPriceFeed=new MockV3Aggregator(DECIMAL,INITIAL_PRICE);
        vm.stopBroadcast();
        Networkconfig memory anvilconfig=Networkconfig({
            priceFeed:address(MockPriceFeed)
        });
        return anvilconfig;

    }
    constructor(){
        if(block.chainid == 11155111){
            activeNetworkconfig=getsepoliaethconfig();
        }
    else{
        activeNetworkconfig=getanvilconfig();
    }    
    }
}
