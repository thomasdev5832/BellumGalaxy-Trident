import react from "react";
import "../styles/PagesCss/Contact.css";
import LogoBellum from "../assets/logoBellum.png";

function Contact() {
  return (
    <>
      <link
        rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
      />
      <section className="bodyContact" id="Contact">
        <div className="ContactTitle">
          <p>Welcome to</p>
          <h1>Bellum Galaxy</h1>
        </div>
        <div className="ContactContent">
        <div className="ContactImage">
          <img src={LogoBellum} alt="Image at Logo Bellum Galaxy" />
        </div>
        <div className="ContactText">
          <p>
            A rede de distribuição de jogos, com foco em jogos de ação e
            aventura, que oferece a melhor experiência de jogos para seus
            jogadores.
          </p>
        </div>
          <div className="ContactSocial">
              <a class="fa-brands fa-x-twitter" target="_blank" href="https://x.com/bellumgalaxy"/>
              <a class="fa-brands fa-github" target="_blank" href="https://github.com/BellumGalaxy/"/>
              <a class="fa-brands fa-linkedin-in" target="_blank" href="https://www.linkedin.com/company/bellum-galaxy/"/>
              <a class="fa-brands fa-discord" target="_blank" href="https://discord.com/invite/H2UpdzbbRJ"/>
        </div>
        
        <div className="ContactWeb">
          <a target="_blank" href="https://bellumgalaxy.com/">Visit our Website ⭢</a>
        </div>
        </div>
      </section>
    </>
  );
}

export default Contact;
