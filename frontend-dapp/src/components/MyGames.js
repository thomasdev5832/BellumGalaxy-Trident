import React from 'react';
import '../styles/MyGames.css';

function MyGames({ title, value, image, category, rating }) {
  return (
    <div className="game">
      <img src={image} alt={`${title} cover`} className="game-image" />
      <div className="game-info">
        <h2 className="game-title">{title}</h2>
        <div className="game-rating-wrap">
          <p className="game-rating">
            <span>{rating}/5</span>
            Rating
          </p>
        </div>
      </div>
      <div className="game-category">{category}</div>
      <div className="game-price-and-buy-button-wrap">
        <div className="game-price">{value}</div>
        <button className="buy-button">Market soon</button>
      </div>
    </div>
  );
}

export default MyGames;

