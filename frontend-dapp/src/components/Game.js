import React from 'react';
import '../styles/Game.css'; // Styles for the Game component

function Game({ title, price, image }) {
  return (
    <div className="game">
      <img src={image} alt={title} className="game-image" />
      <h3 className="game-title">{title}</h3>
      <p className="game-price">${price.toFixed(2)}</p>
    </div>
  );
}

export default Game;
