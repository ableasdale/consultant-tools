(: generic markup module :)

(:
declare variable $attr-set1 as attribute()+ := (attribute class {'heading'}, attribute title {'foo'});
declare variable $attr-set2 as attribute()+ := (attribute class {'heading'}, attribute title {'foo'}, $attr-set1);
declare variable $head-td-names as xs:string+ := ("Match Type","Score","Confidence","Org Name","Id");
:)


 (:--------------------------------------------
 :  Convenience functions for generating xhtml table elements:
  --------------------------------------------:)

declare function local:element($element-name as xs:string, $elem-value-seq as xs:string+) as element()*{
    for $value in $elem-value-seq
    return
    element {$element-name} {$value}
};

declare function local:element($element-name as xs:string, $elem-value as xs:string, $attrs as attribute()+) as element()*{
    element {$element-name} {$attrs, $elem-value} 
};

declare function local:response($element as element()*) as element()* {
    element response {$element} 
};

declare function local:table($element as element()*) as element()* {
    element table {$element} 
};

declare function local:tr($element as element()*) as element()* {
    element tr {$element}
};

declare function local:td($elem-value-seq as xs:string+) as element()*{
    local:element("td", $elem-value-seq)
};

declare function local:td($elem-value-seq as xs:string+, $attrs as attribute()+) as element()*{
    local:element("td", $elem-value-seq, $attrs)
};

declare function local:th($elem-value-seq as xs:string+) as element()*{
    local:element("th", $elem-value-seq)
};

declare function local:th($elem-value-seq as xs:string+, $attrs as attribute()+) as element()*{
    local:element("th", $elem-value-seq, $attrs)
};