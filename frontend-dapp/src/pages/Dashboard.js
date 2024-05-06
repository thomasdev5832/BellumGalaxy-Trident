import React from 'react';
import '../styles/Dashboard.css';
import Game from '../components/Game';

const games = [
  { id: 1, title: 'FC24', price: 59.99, image: require('../assets/game-images/game-05.jpg') },
  { id: 2, title: 'MADDEN 24', price: 49.99, image: require('../assets/game-images/game-06.jpg') },
  { id: 3, title: 'Forza Horizon 4', price: 39.99, image: require('../assets/game-images/game-07.jpg') },
  { id: 4, title: 'Sea of Thieves', price: 29.99, image: require('../assets/game-images/game-08.jpg') },
  { id: 5, title: 'Rust', price: 29.99, image: require('../assets/game-images/game-09.jpg') },
  { id: 6, title: 'Valheim', price: 29.99, image: require('../assets/game-images/game-10.jpg') },
  { id: 7, title: 'HELLDIVERS™ 2', price: 29.99, image: require('../assets/game-images/game-11.jpg') },
  { id: 8, title: 'Warframe', price: 29.99, image: require('../assets/game-images/game-12.jpg') },
];

function generateHash() {
  const hexChars = '0123456789abcdef';
  let hash = '0x';
  for (let i = 0; i < 40; i++) { // Endereço Ethereum tem 40 caracteres após '0x'
    const randomIndex = Math.floor(Math.random() * hexChars.length);
    hash += hexChars[randomIndex];
  }
  return hash;
}

function maskHash(hash) {
  const prefix = hash.slice(0, 4);
  const suffix = hash.slice(-4);
  return `${prefix}...${suffix}`; 
}

const transactions = [
  { id: 1, date: '2024-04-01', type: 'BUY', gameTitle: 'FC24', price: 59.99, hash: generateHash() },
  { id: 2, date: '2024-03-25', type: 'SELL', gameTitle: 'Rust', price: 29.99, hash: generateHash() },
  { id: 3, date: '2024-03-30', type: 'SWAP', gameTitle: 'Forza Horizon 4', price: 39.99, hash: generateHash() },
  { id: 4, date: '2024-04-05', type: 'BUY', gameTitle: 'Sea of Thieves', price: 29.99, hash: generateHash() },
  { id: 5, date: '2024-04-10', type: 'SELL', gameTitle: 'Valheim', price: 25.99, hash: generateHash() },
  { id: 6, date: '2024-04-12', type: 'BUY', gameTitle: 'Warframe', price: 19.99, hash: generateHash() },
  { id: 7, date: '2024-04-15', type: 'SWAP', gameTitle: 'MADDEN 24', price: 49.99, hash: generateHash() },
  { id: 8, date: '2024-04-18', type: 'SELL', gameTitle: 'HELLDIVERS™ 2', price: 39.99, hash: generateHash() },
  { id: 9, date: '2024-04-20', type: 'BUY', gameTitle: 'Valorant', price: 0.00, hash: generateHash() },
  { id: 10, date: '2024-04-25', type: 'SWAP', gameTitle: 'Genshin Impact', price: 0.00, hash: generateHash() },
];


function Dashboard() {
  return (
    <div className="dashboard">
      <h2>My Games</h2>
      <div className="game-list">
        {games.map((game) => (
          <Game key={game.id} title={game.title} price={game.price} image={game.image} />
        ))}
      </div>
      
      <div className="transaction-list">
        <h2>Transactions</h2>
        <table className="transaction-table">
          <thead>
            <tr>
              <th>Date</th>
              <th>Type</th>
              <th>Game</th>
              <th>Price</th>
              <th>Hash</th>
            </tr>
          </thead>
          <tbody>
            {transactions.map((transaction) => (
              <tr key={transaction.id}>
                <td>{transaction.date}</td>
                <td>{transaction.type}</td>
                <td>{transaction.gameTitle}</td>
                <td>${transaction.price.toFixed(2)}</td>
                <td className='hash-wrap'>{maskHash(transaction.hash)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

    </div>
  );
}

export default Dashboard;
