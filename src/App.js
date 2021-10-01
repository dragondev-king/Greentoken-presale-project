import "./App.css";

import { useState, useEffect } from "react";
import { ethers } from "ethers";
import axios from "axios";

import { mintNFT } from "./helpers/interact";
import {
  getTokenIdsOfWallet,
  getCurrentTotalSupply,
  getCurrentMaxSupply,
  getCurrentMaxMint,
  getOccupiedIds,
} from "./helpers/contract";
import { connectWallet, getCurrentWalletConnected } from "./helpers/wallet";

const App = () => {
  const [walletAddress, setWalletAddress] = useState("");
  const [soldOutCounts, setSoldOutCounts] = useState(0);
  const [maxSupply, setMaxSupply] = useState(0);
  const [maxMint, setMaxMint] = useState(0);
  const [initialIds, setInitialIds] = useState([]);

  const [status, setStatus] = useState("");
  const [error, setError] = useState("");

  const [newMint, setNewMint] = useState([]);
  const [mintCount, setMintCount] = useState(1);
  const [mintLoading, setMintLoading] = useState(false);

  const [metadatas, setMetadatas] = useState([]);

  const [collapseExpanded, setCollapseExpanded] = useState(false);

  useEffect(() => {
    const initDatas = async () => {
      if (window.ethereum) {
        const { address, status } = await getCurrentWalletConnected();

        setWalletAddress(address);
        setStatus(status);

        onChangeWalletListener();
        onConnectWalletHandler();

        let totalSupply = await getCurrentTotalSupply();
        setSoldOutCounts(totalSupply);

        let maxSupply = await getCurrentMaxSupply();
        setMaxSupply(maxSupply);

        let maxMint = await getCurrentMaxMint();
        setMaxMint(maxMint);

        const initIds = generateInitIds();
        setInitialIds(initIds);
      }
    };

    initDatas();

    window.addEventListener("resize", getWindowWidth);
    return () => window.removeEventListener("resize", getWindowWidth);
  }, []);

  // Fetch CA Ids of the Wallet
  useEffect(() => {
    const getIdsFromWallet = async () => {
      if (!!walletAddress) {
        let tokenIdsOfWallet = await getTokenIdsOfWallet(walletAddress);

        fetchMetaDatas(tokenIdsOfWallet);
      }
    };

    getIdsFromWallet();
  }, [walletAddress]);

  useEffect(() => {
    const getSoldOuts = async () => {
      if (window.ethereum) {
        let totalSupply = await getCurrentTotalSupply();

        setSoldOutCounts(totalSupply);

        if (newMint[0] && newMint[0].toLowerCase() === walletAddress) {
          let tokenIdsOfWallet = await getTokenIdsOfWallet(walletAddress);

          fetchMetaDatas(tokenIdsOfWallet);
        }
      }
    };

    getSoldOuts();
  }, [newMint]);

  // When the width of the website exceeds 1024px, hide sidebar
  const getWindowWidth = () => {
    const { innerWidth: width } = window;
    if (width > 1024) {
      setCollapseExpanded(false);
    }
  };

  const onCollapseExpandHandler = () => {
    setCollapseExpanded(!collapseExpanded);
  };

  const onAlertClickHandler = () => {
    setError("");
  };

  const onConnectWalletHandler = async () => {
    const walletResponse = await connectWallet();

    setStatus(walletResponse.status);
    setWalletAddress(walletResponse.address);
  };

  const onChangeWalletListener = () => {
    if (window.ethereum) {
      window.ethereum.on("accountsChanged", (accounts) => {
        if (accounts.length) {
          setWalletAddress(accounts[0]);
          setStatus("Get your CryptoAthletes pack, 0.05ETH");
        } else {
          setWalletAddress("");
          setStatus("Connect Metamask");
        }
      });

      window.ethereum.on("chainChanged", (chainId) => {
        onConnectWalletHandler();
      });
    } else {
      setStatus(
        <p>
          🦊 You must install Metamask, a virtual Ethereum wallet, in your
          browser.(https://metamask.io/download.html)
        </p>
      );
    }
  };

  const fetchMetaDatas = async (ids) => {
    let metadatas = [];

    for (let i = 0; i < ids.length; i++) {
      await axios
        .get(
          `https://gateway.pinata.cloud/ipfs/Qmd3cb8TsvPWFJuyyKD3KYjn7Sh7Ht8q3CUvsZtPz7n9Qw/CAhooper${ids[i]}.json`
        )
        .then((response) => {
          metadatas.push(response.data);
        })
        .catch((err) => {
          console.log(err);
        });
    }

    setMetadatas(metadatas);
  };

  const onMintCountChangeHandler = (e) => {
    let value =
      e.target.value > maxMint
        ? maxMint
        : e.target.value < 1
        ? 1
        : e.target.value;

    setMintCount(value);
  };

  const generateInitIds = () => {
    let initIds = [];

    for (let i = 0; i < 10020; i++) {
      initIds.push(i + 1);
    }

    return initIds;
  };

  const getDiffArray = (source, target) => {
    return source.filter((index) => {
      let tempArray = [];
      for (let i = 0; i < target.length; i++) {
        tempArray.push(ethers.BigNumber.from(target[i]).toNumber());
      }

      return tempArray.indexOf(index) < 0;
    });
  };

  const getRandomIds = async () => {
    let customIds = [];
    const occupied = await getOccupiedIds();
    const diffIds = getDiffArray(initialIds, occupied);

    while (customIds.length < mintCount) {
      const id = Math.floor(Math.random() * diffIds.length);
      const index = diffIds[id];
      customIds.push(index);
    }

    return customIds;
  };

  const onMintHandler = async () => {
    if (!!walletAddress) {
      setMintLoading(true);
      const randomIds = await getRandomIds();

      const { _, status } = await mintNFT(
        walletAddress,
        setMintLoading,
        setNewMint,
        randomIds
      );

      if (status.indexOf("insufficient fund") >= 0) {
        setError("You don't have enough eths to mint CA!");
      }
    }
  };

  return <div>123123s</div>;
};

export default App;
