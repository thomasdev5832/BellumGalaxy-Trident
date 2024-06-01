import "./App.css";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Store from "./pages/Store";
import NavBarDApp from "./components/NavBarDApp";
import Dashboard from "./pages/Dashboard";
import Footer from "./components/Footer";

import { DynamicContextProvider } from "@dynamic-labs/sdk-react-core";
import { EthersExtension } from "@dynamic-labs/ethers-v5";
import { EthereumWalletConnectors } from "@dynamic-labs/ethereum";

const evmNetworks = [
  {
    blockExplorerUrls: ["https://sepolia.etherscan.io"],
    chainId: 11155111,
    chainName: "Sepolia",
    iconUrls: ["https://app.dynamic.xyz/assets/networks/eth.svg"],
    name: "Sepolia",
    nativeCurrency: {
      decimals: 18,
      name: "Ether",
      symbol: "ETH",
    },
    networkId: 11155111,
    rpcUrls: ["https://eth-sepolia.public.blastapi.io"],
    vanityName: "Sepolia",
  },
  {
    blockExplorerUrls: ["https://sepolia-optimism.etherscan.io/"],
    chainId: 11155420,
    chainName: "OP Sepolia",
    iconUrls: ["https://app.dynamic.xyz/assets/networks/eth.svg"],
    name: "OP Sepolia",
    nativeCurrency: {
      decimals: 18,
      name: "Ether",
      symbol: "ETH",
    },
    networkId: 11155420,
    rpcUrls: ["https://opt-sepolia.g.alchemy.com/v2/NAJutcGPzT9SZcptHOOwt9oFQ85jSHc8"],
    vanityName: "OP Sepolia",
  },
];

function App() {
  return (
    <div className="App">
      <DynamicContextProvider
        theme="dark"
        settings={{
          environmentId: process.env.REACT_APP_CLIENT_ID,
          overrides: { evmNetworks },
          appName: "Trident",
          alletConnectorExtensions: [EthersExtension],
          walletConnectors: [EthereumWalletConnectors],
        }}
      >
        <BrowserRouter>
          <NavBarDApp />
          <Routes>
            <Route path="/" element={<Store />} />
            <Route path="/store" element={<Store />} />
            <Route path="/dashboard" element={<Dashboard />} />
          </Routes>
          <Footer />
        </BrowserRouter>
      </DynamicContextProvider>
    </div>
  );
}

export default App;
