import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const RaymondNFTModule = buildModule("RaymondNFTModule", (m) => {

  const raymondNFT = m.contract("RaymondNFT", [
    "Raymond",   // name
    "RAY"        // symbol
  ]);

  return { raymondNFT };
});

export default RaymondNFTModule;