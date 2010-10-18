xquery version "1.0-ml";

declare variable $START as xs:int external;
declare variable $END as xs:int external;

declare function local:get-estimate(){
    fn:concat("returning: ", $START, " to ", $END, " of an estimated ", xdmp:estimate(doc()), " documents")
};

(local:get-estimate(),
doc()[$START to $END])