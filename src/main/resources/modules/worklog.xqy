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

declare function local:insert($user){

xdmp:document-insert(
    fn:concat(current-date(), ".xml"),
    local:create-entry ($user, "test"), 
    (),
    $user
)  
};

local:insert("alex")

(:
local:create-entry("alex", "test")
:)
