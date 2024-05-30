import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';
import { config } from './utils/config.ts';

import AsyncStorage from '@react-native-async-storage/async-storage'
import { createAsyncStoragePersister } from '@tanstack/query-async-storage-persister'
import { QueryClient } from '@tanstack/react-query'
import { PersistQueryClientProvider } from '@tanstack/react-query-persist-client'
import { WagmiProvider, deserialize, serialize } from 'wagmi'

import { DynamicContextProvider, DynamicWidget } from '@dynamic-labs/sdk-react-core';
import { EthereumWalletConnectors } from "@dynamic-labs/ethereum";

const root = ReactDOM.createRoot(document.getElementById('root'));

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      gcTime: 1_000 * 60 * 60 * 24, // 24 hours
    },
  },
})

const persister = createAsyncStoragePersister({
  serialize,
  storage: AsyncStorage,
  deserialize,
})

const evmNetworks = [
  {
    blockExplorerUrls: ['https://sepolia.etherscan.io'],
    chainId: 11155111,
    chainName: 'Sepolia',
    iconUrls: ['https://app.dynamic.xyz/assets/networks/eth.svg'],
    name: 'Ethereum',
    nativeCurrency: {
      decimals: 18,
      name: 'Ether',
      symbol: 'ETH',
    },
    networkId: 11155111,
    rpcUrls: ['https://eth-sepolia.g.alchemy.com/v2/demo'],
    vanityName: 'Sepolia',
  },
];

root.render(
  <React.StrictMode>
    <DynamicContextProvider
            theme='dark'
            settings={{
              environmentId: process.env.REACT_APP_CLIENT_ID,
              overrides: { evmNetworks },
              appName: 'Trident',
              walletConnectors: [ EthereumWalletConnectors ],
            }}>
      <WagmiProvider config={config}>
        <PersistQueryClientProvider
          client={queryClient}
          persistOptions={{ persister }}
          >
            <App />
        </PersistQueryClientProvider>
      </WagmiProvider>
    </DynamicContextProvider>
  </React.StrictMode>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
