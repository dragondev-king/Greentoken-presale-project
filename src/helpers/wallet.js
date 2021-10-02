import detectEthereumProvider from "@metamask/detect-provider";
require("dotenv").config();

export const connectWallet = async () => {
  const provider = await detectEthereumProvider();

  if (provider) {
    try {
      const walletChainId = await provider.request({
        method: "eth_chainId",
      });
      if (
        parseInt(walletChainId) === parseInt(process.env.REACT_APP_CHAIN_ID)
      ) {
        const addressArray = await provider.request({
          method: "eth_requestAccounts",
        });

        if (addressArray.length) {
          return {
            address: addressArray[0],
            status: "Connected",
          };
        } else {
          return {
            address: "",
            status: "No wallet connected",
          };
        }
      } else {
        provider.request({
          method: "wallet_switchEthereumChain",
          params: [{ chainId: process.env.REACT_APP_CHAIN_ID }],
        });

        return {
          address: "",
          status: "Was on the other chain",
        };
      }
    } catch (err) {
      return {
        address: "",
        status: `😥 ${err.message}`,
      };
    }
  } else {
    console.log(`🦊 You must install Metamask, a virtual Ethereum wallet, in your
            browser.(https://metamask.io/download.html)`);
    return {
      address: "",
      status: "Can't find web3 provider",
    };
  }
};

export const getCurrentWalletConnected = async () => {
  const provider = await detectEthereumProvider();

  if (provider) {
    try {
      const addressArray = await provider.request({
        method: "eth_accounts",
      });

      const walletChainId = await provider.request({
        method: "eth_chainId",
      });

      if (
        addressArray.length &&
        walletChainId === process.env.REACT_APP_CHAIN_ID
      ) {
        return {
          address: addressArray[0],
          status: "Connected",
        };
      } else {
        return {
          address: "",
          status: "Connect Metamask",
        };
      }
    } catch (err) {
      return {
        address: "",
        status: `😥 ${err.message}`,
      };
    }
  } else {
    console.log(`🦊 You must install Metamask, a virtual Ethereum wallet, in your
            browser.(https://metamask.io/download.html)`);
    return {
      address: "",
      status: "Can't find web3 provider",
    };
  }
};
