import "./App.scss";

import { useState, useEffect } from "react";

import { getContractWithSigner } from "./helpers/contract";
import { connectWallet, getCurrentWalletConnected } from "./helpers/wallet";
require("dotenv").config();

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
            <span>{data.address}</span>(Ratio: <span>{data.ratio}</span>)
          </div>
        ))
      : "";

  const startContest = async () => {
    var addressArr = Object.entries(attenders).map(([key, val]) => val.address);
    var ratioArr = Object.entries(attenders).map(([key, val]) =>
      parseInt(val.ratio)
    );

    try {
      await airDrop.initContest(
        addressArr,
        ratioArr,
        parseInt(process.env.REACT_APP_END_AIRDROP_AT)
      );
    } catch (error) {}
  };

  const claimBNBs = async () => {
    await airDrop.claimBNBs();
  };

  const stopAirDrop = async () => {
    await airDrop.stopAirDrop();
  };

  return (
    <div className="app flex flex-column main-container">
      <div className="app-attenders">{generateTable()}</div>
      <div className="app-inputs">
        <input
          value={address}
          name="address"
          type="text"
          onChange={onChangeHandler}
          className="form-control"
        />
        <input
          value={ratio}
          name="ratio"
          type="number"
          onChange={onChangeHandler}
          className="form-control"
        />
        <button className="btn btn-primary" onClick={onAddHandler}>
          Add
        </button>
      </div>
      <div className="app-controllers">
        <button className="btn btn-primary" onClick={startContest}>
          Start Contest
        </button>
        <button className="btn btn-info" onClick={stopAirDrop}>
          Stop Contest
        </button>
        <button className="btn btn-success" onClick={claimBNBs}>
          Claim
        </button>
      </div>
    </div>
  );
};

export default App;
