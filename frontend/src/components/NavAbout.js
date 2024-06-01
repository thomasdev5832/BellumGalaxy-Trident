import React from "react";
import "../styles/ComponentsCss/NavAbout.css";

function NavAbout() {
  return (
    <>
      <div className="navAbout">
        <ul className="menuAbout">
          <li className="pro">
            <a>Protocols and Standards</a>
          </li>
          <li className="tri">
            <a>Trinsic Infrastrucutre</a>
          </li>
          <li className="app">
            <a>Application Layer</a>
          </li>
          <li className="id">
            <a>ID-tech Products</a>
          </li>
        </ul>
      </div>
    </>
  );
}

export default NavAbout;
