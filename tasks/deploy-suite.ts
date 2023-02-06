import "@nomiclabs/hardhat-etherscan"
import "@nomiclabs/hardhat-waffle"
import { BigNumber, Contract } from "ethers"
import { task, types } from "hardhat/config"
import "hardhat-deploy"
import "hardhat-deploy-ethers"
import { DeployOptions } from "hardhat-deploy/dist/types"
import {
    SpacetimeToken,
    SpacetimeDAO,
    SpacetimeERC721,
    SpacetimeClearingHouse
} from "../typechain-types";
import { spacetimeClearingHouse } from "../typechain-types/contracts"

task(`deploy-suite`, `Deploy entire suite of contracts`).setAction(async (taskArgs, hre) => {
    const { ethers, run, deployments } = hre
    const { deploy: deployContract } = deployments

    console.log("Starting")
    const provider = new ethers.providers.JsonRpcProvider(
        "https://api.hyperspace.node.glif.io/rpc/v1",
        3141
    )
    const deployer = new hre.ethers.Wallet(process.env.PRIVATE_KEY as string, provider)

    const [signer] = await ethers.getSigners()

    console.log("Awaiting provider ready")
    await provider.ready

    console.log("Awaiting fee data")

    let maxPriorityFee: BigNumber | null = null
    let attempt = 0
    while (maxPriorityFee == null) {
        try {
            maxPriorityFee = (await provider.getFeeData()).maxPriorityFeePerGas
        } catch (e) {
            attempt++
            if (attempt > 100) {
                break
            }
        }
    }

    const deploy = async (name: string, args: any[] = []) => {
        const deployResult = await deployContract(name, {
            from: deployer.address,
            args,
            // since it's difficult to estimate the gas before f4 address is launched, it's safer to manually set
            // a large gasLimit. This should be addressed in the following releases.
            gasLimit: 1000000000, // BlockGasLimit / 10
            // since Ethereum's legacy transaction format is not supported on FVM, we need to specify
            // maxPriorityFeePerGas to instruct hardhat to use EIP-1559 tx format
            maxPriorityFeePerGas: maxPriorityFee ?? undefined,
            log: true,
        })
        console.log(`${name} at address ${deployResult.address}`)

        return new hre.ethers.Contract(deployResult.address, deployResult.abi, signer)
    }

    console.log("Awaiting deploys")

    const spacetimeToken = (await deploy("SpacetimeToken")) as SpacetimeToken
    const spacetimeClearingHouse = (await deploy("SpacetimeClearingHouse")) as SpacetimeClearingHouse
    const spacetimeERC721= (await deploy("SpacetimeERC721", [spacetimeToken.address, spacetimeClearingHouse.address])) as SpacetimeERC721
    const spacetimeDao = (await deploy("SpacetimeDAO", [spacetimeToken.address, spacetimeERC721.address])) as SpacetimeDAO
    console.log('Granting minter role');
    await spacetimeToken.grantRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("MINTER_ROLE")), spacetimeERC721.address, {
        gasLimit: 10000000,
        maxPriorityFeePerGas: maxPriorityFee?.toString(),
    });
    await spacetimeERC721.grantRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("MINTER_ROLE")), spacetimeDao.address, {
        gasLimit: 10000000,
        maxPriorityFeePerGas: maxPriorityFee?.toString(),
    });
    await spacetimeToken.grantRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("MINTER_ROLE")), spacetimeDao.address, {
        gasLimit: 10000000,
        maxPriorityFeePerGas: maxPriorityFee?.toString(),
    });

    console.log('Granting pauser role');
    await spacetimeToken.grantRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("PAUSER_ROLE")), spacetimeERC721.address, {
        gasLimit: 10000000,
        maxPriorityFeePerGas: maxPriorityFee?.toString(),
    });
    await spacetimeToken.grantRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("PAUSER_ROLE")), spacetimeDao.address, {
        gasLimit: 10000000,
        maxPriorityFeePerGas: maxPriorityFee?.toString(),
    });
    console.info({
        spacetimeDao: spacetimeDao.address,
        spacetimeToken: spacetimeToken.address,
        spacetimeERC721: spacetimeERC721.address,
        spacetimeClearingHouse: spacetimeClearingHouse.address
    })
})

export default {}
