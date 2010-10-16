(:xdmp:document-insert("1.xml", <foo/>):)

declare function local:create-entry ($user as xs:string, $description as xs:string){
element item {
    element userName {$user},
    element dateTime {current-dateTime()},
    element description {$description}
}
};

declare function local:list-entries($user as xs:string){
element items {
    element item {'TODO'}
}
};

declare function local:list-entries-by-date($user as xs:string, $date as xs:date){

};

declare function local:get-current-doc-uri() as xs:string{
    fn:concat(current-date(),".xml")
};


declare function local:insert($user){
if (exists(doc(local:get-current-doc-uri()))) then (
    xdmp:node-insert-after( 
        doc(local:get-current-doc-uri())/items/item[position() = last()],
        local:create-entry ($user, "test")
    )
) else (
xdmp:document-insert(
    local:get-current-doc-uri(),
    element items {
        local:create-entry ($user, "test")
    },
    (),
    $user
)  
)
};

local:insert("test")