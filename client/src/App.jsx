

import DPetitionerJson from './contracts/DPetitioner.json'
import React from "react";
import "./App.css";
import { Routes, Route } from "react-router-dom";
import Home from "./pages/Home";
import Proposal from "./pages/Proposal";
import Logo from "./images/Moralis.png";
import { Button } from "@web3uikit/core";
import { useState, useEffect } from "react";
import Web3 from "web3";

const App = () => {
  const [account, setAccount] = useState("0x0")
  const [loading, setLoading] = useState(true);
  const [DPetitioner, setDPetitioner] = useState(null);
  var acctemp = account;
  async function loadWeb3(){

    if(window.ethereum){
      window.web3 = new Web3(window.ethereum)
      await window.ethereum.enable()
      window.ethereum.on("accountsChanged", (accounts)=> {
        if(accounts.length>0){
          console.log("account set")
          setAccount(accounts[0])
        }
      })
    }
    else if(window.web3){
      window.web3 = new Web3(window.web3.currentProvider)
    }else{
      window.alert('Non-Ethereum browser detected. You should consider trying Metamask!')
    }
  }
  async function  loadBlockchainData(){
    const web3 = window.web3
    const accounts = await web3.eth.getAccounts()
    setAccount(accounts[0])
    acctemp = accounts[0];
    const networkId = await web3.eth.net.getId();

    const DPetitionerData = DPetitionerJson.networks[networkId]
    if(DPetitionerData){
      console.log("DPetitioner data if statement")
      const tempContract = new web3.eth.Contract(DPetitionerJson.abi, DPetitionerData.address)
      setDPetitioner(tempContract);
      console.log("account", acctemp)
      tempContract.methods.addVoter(acctemp, "Ayush", "Shaw", 0).call();
      console.log(tempContract.methods.name().call())
    }else{
      window.alert('DPetitioner contract not deployed to detected network.')
    }

    console.log(accounts)
  }
  useEffect(()=>{
    // alert("Welcome")
    loadWeb3().then(async (E)=>{
      await loadBlockchainData();
      setLoading(false)
    })
    
  }, [])

  return (
    <>
    <h1>Hello World</h1>
    <h2>{account}</h2>
    
      <div className="header">
        <img width="160px" src={Logo} alt="logo" />
        <Button />
      </div>
      {/* <Home></Home> */}
      <Routes>
        <Route path="/" element={<Home contract={DPetitioner} />} />
        <Route path="/proposal" element={<Proposal />} />
      </Routes>
    </>
  );
};

export default App;