xquery version "1.0-ml";

(::

COMMON XHTML CONTENT :: TODO - MOVE TO A SEPARATE MODULE 

::)


declare namespace xhtml = "http://www.w3.org/1999/xhtml";
import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

declare function local:build-page($html as element()){
xdmp:set-response-content-type("application/xhtml+xml; charset=utf-8"),
'<?xml version="1.0" encoding="UTF-8"?>',
'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
$html
};

declare function local:html-page-enclosure($content as element()) as element(html){
element html {attribute lang {"en"}, attribute xml:lang {"en"},
    local:generate-page-head(),
    element body {$content}
}
};

declare function local:generate-page-head() as element(head){
element head {
    element title {fn:concat("Report generated on: ", current-dateTime())},
    (:element link {attribute rel{"stylesheet"}, attribute type{"text/css"}, attribute href {"report.css"}}:)
    element style {attribute type {"text/css"},local:css()}    
}
};

declare function local:css() as xs:string{
"body {font-family:Verdana; font-size:80%;}
table {border-collapse: collapse; border:1px solid black;}
table th {background:grey; padding:1em;}
table tr {padding:1em;}
table td {border:1px dotted grey;}
table td.roles {font-family: Courier New;}
table td.roles strong {color:#800;}
.odd {background-color:white;}
.even {background-color:#e1e1e1;}"
};

declare function local:get-tr-class($pos as xs:integer) as xs:string{
if ($pos mod 2 = 0) 
    then ("even") 
    else ("odd")
};

(:: END COMMON ::)





declare function local:tabulate-roles($doc){
 for $node in $doc/info/role-info
 return local:tabulate-role($node)
};

declare function local:tabulate-role($role as element(role-info)){
element table {attribute border {"1"},
 element tr {
   element th {"Role Name"},
   element th {"Role description"},
   element th {"Roles"}
 },
 for $list at $pos in $role/sec:role
 return 
 element tr {attribute class {local:get-tr-class($pos)},
  element td {$list/sec:role-name/text()},
  element td {$list/sec:description/text()},
  element td {attribute class {"roles"}, local:process-role-ids($list/sec:role-ids), element strong {concat("Total: ",count($list/sec:role-ids/sec:role-id))}}
}
} 
};

declare function local:process-role-ids($list as element(sec:role-ids)){
for $item in $list/sec:role-id
return fn:concat(local:map-role-id-to-name($item), " | ")
};

declare function local:map-role-id-to-name($role-id){
fn:root($role-id)/info/role-info/sec:role[sec:role-id = $role-id]/sec:role-name[1]/text()
};



local:build-page(
functx:change-element-ns-deep(
local:html-page-enclosure(
element div {attribute id {"content"},
    element h1 {concat("All users and roles for ", count(doc()), " hosts")},
    for $doc in doc()
        return 
        (element h2 {"Host: ", $doc/info/server-name/text(), fn:concat(" (last modified: ",
xdmp:document-properties(xdmp:node-uri($doc))/prop:properties/prop:last-modified/text(), ")")}, local:tabulate-roles($doc))
    }
), "http://www.w3.org/1999/xhtml", ""))
