import React from "react";
import "../styles/NavAbout.css";

function NavAbout() {
  return (
    <>
      <div className="navAbout">
        <ul className="menuAbout">
          <li className="pro">
            <a href="">Protocols and Standards</a>
          </li>
          <li className="tri">
            <a href="">Trinsic Infrastrucutre</a>
          </li>
          <li className="app">
            <a href="">Application Layer</a>
          </li>
          <li className="id">
            <a href="">ID-tech Products</a>
          </li>
        </ul>
      </div>
    </>
  );
}

export default NavAbout;
