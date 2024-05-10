import React from 'react'
import { useState } from 'react';
import '../styles/NavBar.css'
import TridentName from '../assets/nametrident.png'

function NavBar() {
    // adding the states 
    const [isActive, setIsActive] = useState(false);
    //add the active class
    const toggleActiveClass = () => {
      setIsActive(!isActive);
    };
    //clean up function to remove the active class
    const removeActive = () => {
      setIsActive(false)
    }
    return (
          <nav className="navbar">
            {/* logo */}
            <a href='#home' className='logo-wrap'>
                <img className="logo" src={TridentName} />
            </a>
            <ul className={`navMenu ${isActive ? 'active' : ''}`}>
              <li onClick={removeActive}>
                <a href='#home' className="navLink">About</a>
              </li>
              <li onClick={removeActive}>
                <a href='#home' className="navLink">Team</a>
              </li>
              <li onClick={removeActive}>
                <a href='#home' className="navLink">FAQ</a>
              </li>
              <li onClick={removeActive}>
                <a href='#home' className="navLink">Contact</a>
              </li>
              <li onClick={removeActive}>
                <a href='/shop' className="navLink">
                    <button className='btn-launch'>Launch App</button>
                </a>
              </li>
            </ul>
            <div className={`hamburger ${isActive ? 'active' : ''}`} onClick={toggleActiveClass}>
              <span className="bar"></span>
              <span className="bar"></span>
              <span className="bar"></span>
            </div>
          </nav>
        
    );
  }

export default NavBar