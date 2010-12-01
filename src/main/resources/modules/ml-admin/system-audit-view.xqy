xquery version "1.0-ml";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

(:declare namespace sec = "http://www.marklogic.com/security";:)

declare function local:html-page-enclosure($content as element()) {
xdmp:set-response-content-type("text/html; charset=utf-8"),
(:'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',:)
element html {attribute lang {"en"}, attribute xml:lang {"en"},
    local:generate-page-head(),
    element body {$content}
}
};



declare function local:generate-page-head(){
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

declare function local:list-users($user-info-element as element(user-info)) as element(){
element table {
    element tr {
        element th {"User Name"},
        element th {"Description"},
        element th {"Roles"}
    },
    for $user at $pos in $user-info-element/user
    return
    element tr {attribute class {local:get-class($pos)},
        element td {$user/sec:user-name/text()},
        element td {$user/sec:description/text()},
        element td {attribute class {"roles"}, 
            for $role in $user/roles/sec:role-name
            return fn:concat($role/text(), ", "),
            element strong {fn:concat("Total: ",count($user/roles/role), " roles")}
        }
    }
}
};

declare function local:get-class($pos as xs:integer) as xs:string{
if ($pos mod 2 = 0) 
then ("even") 
else ("odd")
};

functx:change-element-ns-deep(
local:html-page-enclosure(
element div {attribute id {"content"},
    for $doc in doc()
        return 
        (element h2 {"Host: ", $doc/info/server-name/text()}, local:list-users($doc/info/user-info))
    }
), "http://www.w3.org/1999/xhtml", "")