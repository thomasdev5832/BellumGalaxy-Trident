import React from 'react'
import { useState } from 'react';
import '../styles/NavBarDApp.css'
import Trident from '../assets/trident.png'

function NavBarDApp() {
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
            <div className={`hamburger ${isActive ? 'active' : ''}`} onClick={toggleActiveClass}>
              <span className="bar"></span>
              <span className="bar"></span>
              <span className="bar"></span>
            </div>
            <a href='/' className='logo-wrap'>
                <img className="logo" src={Trident} />
            </a>
            <ul className={`navMenu ${isActive ? 'active' : ''}`}>
              <li onClick={removeActive}>
                <a href='/store' className="navLink">Store</a>
              </li>
              <li onClick={removeActive}>
                <a href='/dashboard' className="navLink">Dashboard</a>
              </li>
              <li onClick={removeActive}>
                <a href='/' className="navLink">🤍</a>
              </li>
              <li onClick={removeActive}>
                <a href='/' className="navLink">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24">
                    <path stroke="currentColor" strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Zm0 0a8.949 8.949 0 0 0 4.951-1.488A3.987 3.987 0 0 0 13 16h-2a3.987 3.987 0 0 0-3.951 3.512A8.948 8.948 0 0 0 12 21Zm3-11a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/>
                </svg>

                </a>
              </li>
              
            </ul>
            <a href='#' className="navLink">
                    <button className='btn-launch'>Connect</button>
                </a>
            
          </nav>
        
    );
  }

export default NavBarDApp