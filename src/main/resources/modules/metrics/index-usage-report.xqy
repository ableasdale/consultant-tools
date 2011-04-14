xquery version "1.0-ml";

(:
 : Get the Forest in-memory usage 
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

declare function local:get-index-usage(){
element cluster {
 for $forest in $support/forest-status
 order by $forest/host-id, sum(fn:data($forest/stands/stand/memory-size)) descending
 return (
  element forest{attribute host {$forest/host-id}, $forest/forest-name, element in-mem-mb {sum(fn:data($forest/stands/stand/memory-size))}}
 )
}
};

local:get-index-usage()
