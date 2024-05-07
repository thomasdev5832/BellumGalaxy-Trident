import React, { useState, useEffect } from 'react';
import Game from '../components/Game';
import '../styles/Store.css';

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

function Store() {
  
  const featuredGames = [
    { title: 'STAR WARS Jedi: Fallen Order™', price: 99.99, image: gameImage1 },
    { title: 'Gray Zone Warfare', price: 109.99, image: gameImage2 },
    { title: 'Battlefield 2042', price: 79.99, image: gameImage3 },
    { title: 'Counter-Strike 2', price: 79.99, image: gameImage4 },
  ];

  const games = [
    { title: 'FC24', price: 59.99, image: gameImage5 },
    { title: 'MADDEN 24', price: 49.99, image: gameImage6 },
    { title: 'Forza Horizon 4', price: 39.99, image: gameImage7 },
    { title: 'Sea of Thieves', price: 29.99, image: gameImage8 },
    { title: 'Rust', price: 29.99, image: gameImage9 },
    { title: 'Valheim', price: 29.99, image: gameImage10 },
    { title: 'HELLDIVERS™ 2', price: 29.99, image: gameImage11 },
    { title: 'Warframe', price: 29.99, image: gameImage12 },
  ];

  const [currentSlide, setCurrentSlide] = useState(0);

  const nextSlide = () => {
    setCurrentSlide((currentSlide + 1) % featuredGames.length);
  };

  const prevSlide = () => {
    setCurrentSlide((currentSlide - 1 + featuredGames.length) % featuredGames.length);
  };

  useEffect(() => {
    // Configurar o intervalo para alternar slides automaticamente a cada 5 segundos
    const interval = setInterval(() => {
      nextSlide();
    }, 5000); // 5000 milissegundos = 5 segundos

    // Limpeza: Limpar o intervalo ao desmontar o componente
    return () => {
      clearInterval(interval);
    };
  }, [currentSlide]); // Dependência para reiniciar o intervalo quando currentSlide muda



  return (
    <div className="store">
      
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
            <button onClick={prevSlide}>&lt;</button> 
            <Game {...featuredGames[currentSlide]} />
            <button onClick={nextSlide}>&gt;</button>
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