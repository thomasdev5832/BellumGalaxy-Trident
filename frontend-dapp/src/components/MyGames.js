import React from 'react';
import '../styles/Game.css';

function MyGames({
  title,
  image,
  category,
  subcategory,
  rating,
  description,
  downloads,
}) {
  return (
    <div className="game">
      <img src={image} alt={title} className="game-image" />
      <h3 className="game-title">{title}</h3>
      <p className="game-category">
        {category} &gt; {subcategory}
      </p>

      <p className="game-description">{description}</p>
      <div className="rating-and-downloads-wrap">
        <div className="game-rating-wrap">
          <p className="game-rating">
            <span>{rating}/10</span>
            Rating
          </p>
        </div>
      </div>

      <div className="game-price-and-buy-button-wrap">
      </div>
    </div>
  );
}

export default MyGames;

