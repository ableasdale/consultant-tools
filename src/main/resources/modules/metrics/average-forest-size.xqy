xquery version "1.0-ml";

(:
 : Example: calculate the average size of a forest
 :)

declare default element namespace "http://marklogic.com/xdmp/status/forest";

declare variable $path as xs:string := 'C:\Users\Public\Documents\ML_status_only_support_dump_20110118';

declare variable $support as document-node()* := xdmp:document-get (
 $path,
   <options xmlns="xdmp:document-get">
    <format>xml</format>
  <repair>full</repair>
   </options>
);

declare function local:calculate-average-forest-size($forest-path as xs:string, $num-forests as xs:integer) as xs:double {
 let $my-stands := $support//stands[stand/path/text()[starts-with(. , $forest-path)]]
 return sum( $my-stands/stand/disk-size/xs:int(text()) ) div $num-forests
};

local:calculate-average-forest-size("/var/opt/MarkLogic/Forests/Documents", 1)
