xquery version "1.0-ml";

(:~
 : The most basic usage of the search API - useful for demonstrating what 
 : information can be gained "out of the box".
 :
 :)
declare namespace meta = "http://www.springer.com/app/meta";

import module namespace search =
  "http://marklogic.com/appservices/search"
  at "/MarkLogic/appservices/search/search.xqy";

let $term := xdmp:get-request-field("q")

return
search:search($term)