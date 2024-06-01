import React, { useState } from "react";
import "../styles/PagesCss/Faq.css";
import Accordion from "../components/Accordion";

import { questions } from "../components/ApiFaq";

function Faq() {
  const [data] = useState(questions);
  return (
    <>
      <section className="mainFaq" id="Faq">
        <div className="titleFaq">
          <h1>Frequently Asked Questions</h1>
        </div>
        <div className="contentFaq">
          <div className="accordion">
            {data.map((item) => {
              return (
                <Accordion
                  key={item.id}
                  question={item.question}
                  answer={item.answer}
                />
              );
            })}
          </div>
        </div>
      </section>
    </>
  );
}

export default Faq;
