import { ethers } from "ethers"
import { getContractWithSigner } from "./contract"

export const mintNFT = async (
  walletAddress,
  setMintLoading,
  setNewMint,
  randomIds
) => {
  const contract = getContractWithSigner()

  contract.on("CreateCryptoAthletes(address, uint256)", (to, newId) => {
    const address = ethers.utils.getAddress(to)
    const newMintId = ethers.BigNumber.from(newId).toNumber()

    setNewMint([address, newMintId])
  })

  try {
    let txhash = await contract.mint(walletAddress, randomIds, {
      value: ethers.BigNumber.from(1e9).mul(
        ethers.BigNumber.from(1e9).mul(5).div(100).mul(randomIds.length)
      ),
      from: walletAddress,
    })

    let res = await txhash.wait()
    setMintLoading(false)

    if (res.transactionHash) {
      return {
        success: true,
        status: `Successfully minted ${randomIds.length} Crypty Athletes.`,
      }
    } else {
      return {
        success: false,
        status: "Transaction failed",
      }
    }
  } catch (err) {
    setMintLoading(false)
    return {
      success: false,
      status: err.message,
    }
  }
}
