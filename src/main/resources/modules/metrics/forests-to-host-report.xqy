xquery version "1.0-ml";

(:
 : Example: Showing which forests are attached to individual hosts in a cluster
 :)

declare default element namespace "http://marklogic.com/xdmp/status/host";

declare variable $path as xs:string := 'C:\Users\Public\Documents\ML_status_only_support_dump_20110118';

declare variable $support as document-node()* := xdmp:document-get (
 $path,
   <options xmlns="xdmp:document-get">
    <format>xml</format>
  <repair>full</repair>
   </options>
);

declare function local:get-attribute-forests (
 $id as xs:integer, 
 $assignments as element(assignments),
 $forest-prefix-name as xs:string
){

 for $assignment in $assignments/assignment
 where (fn:data($assignment/host-id) = $id and starts-with($assignment/forest-name/text(), $forest-prefix-name)) 
 order by $assignment/forest-name
 return
  element forest {attribute host {$assignment/host-id/text()}, $assignment/forest-name/text()}
};

declare function local:show-host-forests($forest-prefix-name as xs:string) as element(hosts) {
 element hosts {
 for $host in $support/host-status
 order by $host/host-name
 return
  element host {attribute name {$host/host-name}, attribute id {$host/host-id},
   local:get-attribute-forests(fn:data($host/host-id), $host/assignments, $forest-prefix-name)
  }
 }
};

local:show-host-forests("Documents")
