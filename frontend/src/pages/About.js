import React from "react";
import "../styles/PagesCss/About.css";
import Digital from "../assets/digital.png";
import NavAbout from "../components/NavAbout";

function About() {
  return (
    <>
      <div className="main-about" id="about">
        <div className="image">
          <img src={Digital} />
        </div>
        <section className="content">
          <div className="subContent">
            <h1>Go to market fast, scale even faster</h1>

            <p>
              When launching a product, time is of the essence. Save time,
              money, and resources by using Trinsic's IDtech infrastructure
              rather than building your own.
            </p>

            <a className="learn" href="">
              Learn more ⭢
            </a>

            <NavAbout />
          </div>
        </section>
      </div>
    </>
  );
}

export default About;
