import React from "react";
import "../styles/Team.css";
import { Swiper, SwiperSlide } from "swiper/react";

// Import Swiper styles
import "swiper/css";
import "swiper/css/pagination";

// import required modules
import { Pagination } from "swiper/modules";

function Team() {
  return (
    <>
      <link
        rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
      />
      <section className="bodyTeam" id="team">
        <div className="textTeam">
          <h1>Developer Team</h1>
          <p>
            The development team excels in collaboration, tackling complex
            problems with innovative solutions. Their expertise and dedication
            ensure project success, meeting deadlines and exceeding
            expectations. Teamwork and creativity drive their remarkable
            achievements.
          </p>
        </div>
        <div className="teamContent">
          <Swiper
            slidesPerView={3}
            spaceBetween={30}
            pagination={{
              clickable: true,
            }}
            modules={[Pagination]}
            className="mySwiper"
          >
             <SwiperSlide>
              
             </SwiperSlide>
            <SwiperSlide>
              <div className="teamCard">
                <div className="cardContent">
                  <div className="imageTeam">
                    <img src={require("../assets/perfilCayo.jpg")} />
                  </div>
                  <div className="social-media">
                    <i class="fa-brands fa-x-twitter"></i>
                    <i class="fa-brands fa-github"></i>
                    <i class="fa-brands fa-linkedin-in"></i>
                    <i class="fa-brands fa-discord"></i>
                  </div>
                  <div className="teamJob">
                    <h1 className="name">Cayo Tarcisio</h1>
                    <h1 className="job">Frontend Developer</h1>
                    <p className="description">
                      A front-end developer creates visually appealing and
                      user-friendly interfaces, ensuring seamless interaction
                      and responsive design for websites.
                    </p>
                  </div>
                </div>
              </div>
            </SwiperSlide>
            <SwiperSlide>
              <div className="teamCard">
                <div className="cardContent">
                  <div className="imageTeam">
                  <img src={require("../assets/perfilCayo.jpg")} />
                  </div>
                  <div className="social-media">
                    <i class="fa-brands fa-x-twitter"></i>
                    <i class="fa-brands fa-github"></i>
                    <i class="fa-brands fa-linkedin-in"></i>
                    <i class="fa-brands fa-discord"></i>
                  </div>
                  <div className="teamJob">
                    <h1 className="name">Cayo Tarcisio</h1>
                    <h1 className="job">Frontend Developer</h1>
                    <p className="description">
                      A front-end developer creates visually appealing and
                      user-friendly interfaces, ensuring seamless interaction
                      and responsive design for websites.
                    </p>
                  </div>
                </div>
              </div>
            </SwiperSlide>
            <SwiperSlide>
              <div className="teamCard">
                <div className="cardContent">
                  <div className="imageTeam">
                  <img src={require("../assets/perfilCayo.jpg")} />
                  </div>
                  <div className="social-media">
                    <i class="fa-brands fa-x-twitter"></i>
                    <i class="fa-brands fa-github"></i>
                    <i class="fa-brands fa-linkedin-in"></i>
                    <i class="fa-brands fa-discord"></i>
                  </div>
                  <div className="teamJob">
                    <h1 className="name">Cayo Tarcisio</h1>
                    <h1 className="job">Frontend Developer</h1>
                    <p className="description">
                      A front-end developer creates visually appealing and
                      user-friendly interfaces, ensuring seamless interaction
                      and responsive design for websites.
                    </p>
                  </div>
                </div>
              </div>
            </SwiperSlide>
            <SwiperSlide>
              <div className="teamCard">
                <div className="cardContent">
                  <div className="imageTeam">
                  <img src={require("../assets/perfilCayo.jpg")} />
                  </div>
                  <div className="social-media">
                    <i class="fa-brands fa-x-twitter"></i>
                    <i class="fa-brands fa-github"></i>
                    <i class="fa-brands fa-linkedin-in"></i>
                    <i class="fa-brands fa-discord"></i>
                  </div>
                  <div className="teamJob">
                    <h1 className="name">Cayo Tarcisio</h1>
                    <h1 className="job">Frontend Developer</h1>
                    <p className="description">
                      A front-end developer creates visually appealing and
                      user-friendly interfaces, ensuring seamless interaction
                      and responsive design for websites.
                    </p>
                  </div>
                </div>
              </div>
            </SwiperSlide>
            <SwiperSlide>
              <div className="teamCard">
                <div className="cardContent">
                  <div className="imageTeam">
                  <img src={require("../assets/perfilCayo.jpg")} />
                  </div>
                  <div className="social-media">
                    <i class="fa-brands fa-x-twitter"></i>
                    <i class="fa-brands fa-github"></i>
                    <i class="fa-brands fa-linkedin-in"></i>
                    <i class="fa-brands fa-discord"></i>
                  </div>
                  <div className="teamJob">
                    <div className="teamName">
                      <h1>Cayo Tarcisio</h1>
                    </div>
                    <div className="teamJob">
                      <h1>Frontend Developer</h1>
                    </div>
                    <div className="teamDescription">
                      <p>
                        A front-end developer creates visually appealing and
                        user-friendly interfaces, ensuring seamless interaction
                        and responsive design for websites.
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </SwiperSlide>
            <SwiperSlide>
              
             </SwiperSlide>
          </Swiper>
        </div>
      </section>
    </>
  );
}

export default Team;
