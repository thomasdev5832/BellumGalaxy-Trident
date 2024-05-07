import React from 'react';
import '../styles/Game.css';

function Game({ title, price, image, category, subcategory, rating, description, downloads }) {
  return (
    <div className="game">
      <img src={image} alt={title} className="game-image" />
      <h3 className="game-title">{title}</h3>
      <p className="game-category">{category} &gt; {subcategory}</p> 
      <p className="game-rating">Rating: {rating}/10</p> 
      <p className="game-description">{description}</p> 
      <p className="game-downloads">
      <span>
       {downloads.toLocaleString()}</span>
       Downloads</p> 
       
      <p className="game-price">${price.toFixed(2)}</p>
      
    </div>
  );
}

export default Game;

