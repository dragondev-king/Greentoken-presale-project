import "./App.scss";

import { useState, useEffect } from "react";
import { ethers } from "ethers";
import axios from "axios";

import { getContractWithSigner } from "./helpers/contract";
import { connectWallet, getCurrentWalletConnected } from "./helpers/wallet";

const App = () => {
  const [walletAddress, setWalletAddress] = useState("");
  const [walletStatus, setWalletStatus] = useState("");
  const [addresses, setAddresses] = useState([]);
  const [attenders, setAttenders] = useState([]);
  const [address, setAddress] = useState("");
  const [ratio, setRatio] = useState(1);
  const [airDrop, setAirDrop] = useState();

  useEffect(() => {
    const initDatas = async () => {
      if (window.ethereum) {
        const { address, status } = await getCurrentWalletConnected();

        setWalletAddress(address);
        setWalletStatus(status);

        onChangeWalletListener();
        onConnectWalletHandler();

        const value = getContractWithSigner();
        console.log(value);
        setAirDrop(value);
      }
    };

    initDatas();
  }, []);

  const onConnectWalletHandler = async () => {
    const walletResponse = await connectWallet();

    setWalletStatus(walletResponse.status);
    setWalletAddress(walletResponse.address);
  };

  const onChangeWalletListener = () => {
    if (window.ethereum) {
      window.ethereum.on("accountsChanged", (accounts) => {
        if (accounts.length) {
          setWalletAddress(accounts[0]);
          setWalletStatus("Connected");
        } else {
          setWalletAddress("");
          setWalletStatus("Connect Metamask");
        }
      });

      window.ethereum.on("chainChanged", (chainId) => {
        onConnectWalletHandler();
      });
    } else {
      setWalletStatus(
        <p>
          🦊 You must install Metamask, a virtual Ethereum wallet, in your
          browser.(https://metamask.io/download.html)
        </p>
      );
    }
  };

  const onChangeHandler = (e) => {
    e.preventDefault();
    const { value, name } = e.target;

    switch (name) {
      case "address":
        setAddress(value);
        break;
      case "ratio":
        setRatio(value);
        break;
      default:
        break;
    }
  };

  const onAddHandler = () => {
    setAttenders([
      ...attenders,
      {
        address,
        ratio,
      },
    ]);
    setRatio(1);
    setAddress("");
  };

  const generateTable = () =>
    attenders.length
      ? attenders.map((data, index) => (
          <div key={index} className="app-attenders-item">
            <span>{data.address}</span>:<span>{data.ratio}</span>
          </div>
        ))
      : "";

  const startContest = async () => {
    var addressArr = Object.entries(attenders).map(([key, val]) => val.address);
    var ratioArr = Object.entries(attenders).map(([key, val]) =>
      parseInt(val.ratio)
    );

    console.log(addressArr);
    console.log(ratioArr);
    console.log(airDrop.address);

    const result = await airDrop.initContest(addressArr, ratioArr);

    console.log("con", result);
  };

  const claimBNBs = async () => {
    const result = await airDrop.claimBNBs();
    console.log("claim", result);
  };

  const stopAirDrop = async () => {
    const result = await airDrop.stopAirDrop();
    console.log("stop", result);
  };
  return (
    <div className="app flex flex-column">
      <div className="app-attenders">{generateTable()}</div>
      <div className="app-inputs">
        <input
          value={address}
          name="address"
          type="text"
          onChange={onChangeHandler}
        />
        <input
          value={ratio}
          name="ratio"
          type="number"
          onChange={onChangeHandler}
        />
        <button onClick={onAddHandler}>Add</button>
      </div>
      <div className="app-controllers">
        <button onClick={startContest}>Start Contest</button>
        <button onClick={stopAirDrop}>Stop Contest</button>
        <button onClick={claimBNBs}>Claim</button>
      </div>
    </div>
  );
};

export default App;
