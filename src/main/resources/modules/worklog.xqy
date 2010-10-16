
declare function local:create-entry ($user as xs:string, $description as xs:string){
element item {
    element userName {$user},
    element dateTime {current-dateTime()},
    element description {$description}
}
};

declare function local:list-entries($user as xs:string){
    doc(local:get-current-doc-uri($user))
};

declare function local:list-entries-by-date($user as xs:string, $date as xs:date){

};

declare function local:get-current-doc-uri($user as xs:string) as xs:string{
    fn:concat("/",$user,"/",current-date(),".xml")
};


declare function local:insert($user){
if (exists(doc(local:get-current-doc-uri($user)))) then (
    xdmp:node-insert-after( 
        doc(local:get-current-doc-uri($user))/items/item[position() = last()],
        local:create-entry ($user, "test")
    )
) else (
xdmp:document-insert(
    local:get-current-doc-uri($user),
    element items {
        local:create-entry ($user, "test")
    },
    (),
    $user
)  
)
};
local:list-entries("alex")
(:local:insert("test") :)