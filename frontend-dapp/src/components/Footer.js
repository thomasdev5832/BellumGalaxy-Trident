import React from 'react';
import '../styles/Footer.css';
import Trident from '../assets/trident.png';

function Footer() {
  return (
    <section className='footer'>
    <div>
        <img src={Trident}></img>
        <p>© 2024 - Trident - Bellum Galaxy . All rights reserved. All trademarks are property of their respective owners in the US and other countries.
        VAT included in all prices where applicable.</p>
    </div>
  </section>
  )
}

export default Footer