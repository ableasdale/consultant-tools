xquery version "1.0-ml";
module namespace worklog="http://www.xmlmachines.com/worklog";

declare function worklog:create-entry ($user as xs:string, $description as xs:string){
element item {
    element userName {$user},
    element dateTime {fn:current-dateTime()},
    element description {$description}
}
};

declare function worklog:list-entries($user as xs:string){
    fn:doc(worklog:get-current-doc-uri($user))
};

declare function worklog:list-entries-by-date($user as xs:string, $date as xs:date){

};

declare function worklog:get-current-doc-uri($user as xs:string) as xs:string{
    fn:concat("/",$user,"/",fn:current-date(),".xml")
};


declare function worklog:insert($user){
if (fn:exists(fn:doc(worklog:get-current-doc-uri($user)))) then (
    xdmp:node-insert-after( 
        fn:doc(worklog:get-current-doc-uri($user))/items/item[fn:position() = fn:last()],
        worklog:create-entry ($user, "test")
    )
) else (
xdmp:document-insert(
    worklog:get-current-doc-uri($user),
    element items {
        worklog:create-entry ($user, "test")
    },
    (),
    $user
)  
)
};