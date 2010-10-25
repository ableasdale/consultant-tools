xquery version "1.0-ml";
module namespace worklog="http://www.xmlmachines.com/worklog";
import module namespace markup="http://www.xmlmachines.com/markup" at "/xmlmachines/lib-markup.xqy";


declare function worklog:create-entry ($user as xs:string, $description as xs:string){
element item {
    element userName {$user},
    element dateTime {fn:current-dateTime()},
    element description {$description}
}
};

declare function worklog:list-entries($user as xs:string){
    let $worklog := if (fn:empty(worklog:get-current-doc-uri($user))) then (
         element h2 {fn:concat("No workflow available for ",$user)}
    ) else (
        worklog:create-worklog(fn:doc(worklog:get-current-doc-uri($user))/items)
    )
    return
    worklog:build-page($user, $worklog)    
};

declare function worklog:create-worklog($worklog as element(items)){
    markup:table((
        markup:tr((
            markup:th(("User Name", "Date / Time", "Description"))
        )),
        for $item in $worklog/item
        return
        markup:tr((
            markup:td(($item/userName/text())),
            markup:td(($item/dateTime/text())),
            markup:td(($item/description/text()))
        ))
    ))
};

declare function worklog:build-page($user as xs:string, $worklog as element()){    
    markup:xhtml-page(
        markup:html-basic-head(fn:concat( "Worklog for ", $user, " on ", fn:current-dateTime() )), 
        markup:html-body($worklog)
    )
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