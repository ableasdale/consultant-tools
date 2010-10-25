xquery version "1.0-ml";
module namespace markup="http://www.xmlmachines.com/markup";

(:declare default element namespace="http://www.w3.org/1999/xhtml":)

(:
declare variable $attr-set1 as attribute()+ := (attribute class {'heading'}, attribute title {'foo'});
declare variable $attr-set2 as attribute()+ := (attribute class {'heading'}, attribute title {'foo'}, $attr-set1);
declare variable $head-td-names as xs:string+ := ("Match Type","Score","Confidence","Org Name","Id");
:)


 (:--------------------------------------------
 :  Convenience functions for generating xhtml table elements:
  --------------------------------------------:)

declare function markup:element($element-name as xs:string, $elem-value-seq as xs:string+) as element()*{
    for $value in $elem-value-seq
    return
    element {$element-name} {$value}
};

(:declare function markup:element-group($element-group-name ):)

declare function markup:add-processing-instruction() {
  
};
declare function markup:xhtml-page($head as element(head), $body as element(body)){
(
    xdmp:set-response-content-type("text/html"),
    '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
    markup:html-element($head,$body)
)
};

declare function markup:html-element($head as element(head), $body as element(body)) as element(html){
element html {
        attribute xmlns {"http://www.w3.org/1999/xhtml"},
        attribute lang {"en"},
    $head,
    $body
}
};

declare function markup:html-basic-head($title as xs:string) as element(head){
element head {
    element title {$title}
}
};

(:$header as element(),, $footer as element():)
declare function markup:html-body($main as element()) {
element body {
    element div {
        attribute id {"container"},
        element div {
            attribute id {"header"}
        },
        element div {
            attribute id {"main"},
            $main
        }, 
        element div {
            attribute id {"footer"}
        }
    }
}
};

declare function markup:element($element-name as xs:string, $elem-value as xs:string, $attrs as attribute()+) as element()*{
    element {$element-name} {$attrs, $elem-value} 
};

declare function markup:response($element as element()*) as element()* {
    element response {$element} 
};

declare function markup:table($element as element()*) as element()* {
    element table {$element} 
};

declare function markup:tr($element as element()*) as element()* {
    element tr {$element}
};

declare function markup:td($elem-value-seq as xs:string+) as element()*{
    markup:element("td", $elem-value-seq)
};

declare function markup:td($elem-value-seq as xs:string+, $attrs as attribute()+) as element()*{
    markup:element("td", $elem-value-seq, $attrs)
};

declare function markup:th($elem-value-seq as xs:string+) as element()*{
    markup:element("th", $elem-value-seq)
};

declare function markup:th($elem-value-seq as xs:string+, $attrs as attribute()+) as element()*{
    markup:element("th", $elem-value-seq, $attrs)
};