import React, { useState } from "react";
import "../styles/ComponentsCss/Accordion.css";
import { BiMinusCircle } from "react-icons/bi";
import { MdAdd } from "react-icons/md";

function Accordion(props) {
  const [isExpanded, setIsExpanded] = useState(false);

  const toggleExpansion = () => {
    setIsExpanded(!isExpanded);
  };

  return (
    <div className="accordion_box" onClick={toggleExpansion}>
      <div className="ques-icon-div">
        <div className="icon-div">
          {isExpanded ? (
            <BiMinusCircle style={{ marginRight: "1em" }} />
          ) : (
            <MdAdd style={{ marginRight: "1em" }} />
          )}
        </div>
      </div>
      <div className="ques-ans-div">
        <div className="questionFaq">
          <h1>{props.question}</h1>
        </div>
        <div className="answerFaq">{isExpanded && <p>{props.answer}</p>}</div>
      </div>
    </div>
  );
}

export default Accordion;
