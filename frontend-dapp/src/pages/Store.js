import React, { useState, useEffect } from 'react';
import Game from '../components/Game';
import '../styles/Store.css';
import { useReadContract } from 'wagmi';
import tridentAbi from '../utils/Trident.json';
import { useDynamicContext } from '@dynamic-labs/sdk-react-core';
import { ethers } from 'ethers';

import gameImage1 from '../assets/game-images/game-01.jpg';
import gameImage2 from '../assets/game-images/game-02.jpg';
import gameImage3 from '../assets/game-images/game-03.jpg';
import gameImage4 from '../assets/game-images/game-04.jpg';
import gameImage5 from '../assets/game-images/game-05.jpg';
import gameImage6 from '../assets/game-images/game-06.jpg';
import gameImage7 from '../assets/game-images/game-07.jpg';
import gameImage8 from '../assets/game-images/game-08.jpg';
import gameImage9 from '../assets/game-images/game-09.jpg';
import gameImage10 from '../assets/game-images/game-10.jpg';
import gameImage11 from '../assets/game-images/game-11.jpg';
import gameImage12 from '../assets/game-images/game-12.jpg';
import bellumGame from '../assets/bellum-game.webp';

function Store() {
  const { primaryWallet } = useDynamicContext();
  const [gameName, setGameName] = useState('');
  const [gamePrice, setGamePrice] = useState('');

  useEffect(() => {
    const fetchData = async () => {
      
      const signer = await primaryWallet?.connector?.ethers?.getSigner();
      
      const provider = new ethers.JsonRpcProvider('https://sepolia.infura.io/v3/efa7ec71610546999a311d56ece1e112');

      const contractAddress = '0x873C0df305D75b078f002a81e2e8571021AC7e13';

      const contract = new ethers.Contract(contractAddress, tridentAbi, provider);

      try {
        
        const result = await contract.getGamesCreated(1);

        setGameName(result[1]);
        setGamePrice(formatPrice(result[4]));

        console.log(result);
      } catch (error) {
        console.error('Erro ao ler dados do contrato:', error);
      }
    };

    fetchData();
  }, []);

  const featuredGames = [
    { 
      title: 'STAR WARS Jedi: Fallen Order™', 
      price: 99.99, 
      image: gameImage1, 
      category: 'Action', 
      subcategory: 'Adventure', 
      rating: 8.5, 
      description: 'Experience the epic journey of a Jedi in this action-packed adventure.', 
      downloads: 1500000 
    },
    { 
      title: 'Gray Zone Warfare', 
      price: 109.99, 
      image: gameImage2, 
      category: 'Strategy', 
      subcategory: 'War', 
      rating: 7.2, 
      description: 'Plan and execute intricate warfare strategies.', 
      downloads: 800000 
    },
    { 
      title: 'Battlefield 2042', 
      price: 79.99, 
      image: gameImage3, 
      category: 'FPS', 
      subcategory: 'Shooter', 
      rating: 7.8, 
      description: 'Experience the chaos of large-scale multiplayer battles.', 
      downloads: 3000000 
    },
    { 
      title: 'Counter-Strike 2', 
      price: 79.99, 
      image: gameImage4, 
      category: 'FPS', 
      subcategory: 'Shooter', 
      rating: 9.1, 
      description: 'Classic multiplayer shooter with new and improved mechanics.', 
      downloads: 4000000 
    },
  ];

  const games = [
    { 
      title: 'FC24', 
      price: 59.99, 
      image: gameImage5, 
      category: 'Sports', 
      subcategory: 'Soccer', 
      rating: 8.0, 
      description: 'Experience the most realistic soccer simulation.', 
      downloads: 2500000 
    },
    { 
      title: 'MADDEN 24', 
      price: 49.99, 
      image: gameImage6, 
      category: 'Sports', 
      subcategory: 'Football', 
      rating: 7.5, 
      description: 'Enjoy the latest in American football simulation.', 
      downloads: 1800000 
    },
    { 
      title: 'Forza Horizon 4', 
      price: 39.99, 
      image: gameImage7, 
      category: 'Racing', 
      subcategory: 'Simulation', 
      rating: 9.2, 
      description: 'Experience the open-world racing adventure.', 
      downloads: 3200000 
    },
    { 
      title: 'Sea of Thieves', 
      price: 29.99, 
      image: gameImage8, 
      category: 'Adventure', 
      subcategory: 'Pirates', 
      rating: 8.3, 
      description: 'Live the life of a pirate in this open-world multiplayer game.', 
      downloads: 2800000 
    },
    { 
      title: 'Rust', 
      price: 29.99, 
      image: gameImage9, 
      category: 'Survival', 
      subcategory: 'Open World', 
      rating: 7.8, 
      description: 'Survive and thrive in a harsh environment.', 
      downloads: 1400000 
    },
    { 
      title: 'Valheim', 
      price: 29.99, 
      image: gameImage10, 
      category: 'Survival', 
      subcategory: 'Vikings', 
      rating: 8.7, 
      description: 'Explore the mystical Viking world in this open-world survival game.', 
      downloads: 1200000 
    },
    { 
      title: 'HELLDIVERS™ 2', 
      price: 29.99, 
      image: gameImage11, 
      category: 'Action', 
      subcategory: 'Shooter', 
      rating: 7.5, 
      description: 'Fight against aliens in this cooperative action shooter.', 
      downloads: 900000 
    },
    { 
      title: 'Warframe', 
      price: 29.99, 
      image: gameImage12, 
      category: 'Action', 
      subcategory: 'MMO', 
      rating: 9.0, 
      description: 'Experience the fast-paced action in this multiplayer MMO.', 
      downloads: 3500000 
    },
  ];

  const [currentSlide, setCurrentSlide] = useState(0);

  const nextSlide = () => {
    setCurrentSlide((currentSlide + 1) % featuredGames.length);
  };

  const prevSlide = () => {
    setCurrentSlide((currentSlide - 1 + featuredGames.length) % featuredGames.length);
  };

  useEffect(() => {
    const interval = setInterval(() => {
      nextSlide();
    }, 5000); 
    return () => {
      clearInterval(interval);
    };
  }, [currentSlide]);

  const formatPrice = (price) => {
    return price.toString().replace(/0+$/, '');
  };

  return (
    <div className="store">
      <div className='main-banner'>
        <div style={{backgroundImage: `${bellumGame}`}} className='main-game'>
          <div className='main-game-info'>
            <h2>{gameName}</h2>
            <p className='game-description'>Embark on an exhilarating journey through the cosmos, where strategic prowess meets boundless exploration.</p>
            <div className='main-game-price-and-button'>
              <p className='game-price'>${gamePrice}</p>
              <div className='game-rating-wrap'>
                <p className="game-rating">
                  <span>
                  9/10
                  </span>
                  Rating
                </p> 
              </div>
              <button className='buy-main-game-button'>
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24">
                  <path stroke="currentColor" strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 4h1.5L9 16m0 0h8m-8 0a2 2 0 1 0 0 4 2 2 0 0 0 0-4Zm8 0a2 2 0 1 0 0 4 2 2 0 0 0 0-4Zm-8.5-3h9.25L19 7h-1M8 7h-.688M13 5v4m-2-2h4"/>
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
      <div className="banner-and-info">
      <section className="platform-info">
          <h2>Game Ownership, Reinvented</h2>
          <p>
          Enter a new era of gaming where you're not just playing — you're a stakeholder. Our platform uses blockchain technology to give you unparalleled control over your digital assets, empowering you to own and manage your digital gaming collection like never before.
            </p>
          <span>Join us and take charge of your gaming journey.</span>
      </section>

        <section className="banner">
          <h2>Featured Games</h2>
          <div className="banner-content">
            <button className='slide-button' onClick={prevSlide}>&lt;</button>
            <Game {...featuredGames[currentSlide]} />
            <button className='slide-button' onClick={nextSlide}>&gt;</button>
          </div>
        </section>
      </div>

      <section className="gallery">
        <h2>Available Games</h2>
        <div className="games-gallery">
          {games.map((game, index) => (
            <Game key={index} {...game} />
          ))}
        </div>
      </section>

      <section className='middle'>

      </section>
    </div>
  );
}

export default Store;