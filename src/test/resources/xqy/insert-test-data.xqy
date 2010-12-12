xquery version "1.0-ml";

xdmp:set-request-time-limit(3500);

declare variable $TEST-URI-NAME as xs:string external;
declare variable $COLLECTIONS as xs:string := "latest";

declare function local:insert-content() {
for $uri in (1 to 100)
return
xdmp:document-insert( concat("/",$TEST-URI-NAME,"/",xs:string($uri),".xml"),
<content>
    <date>{fn:current-dateTime()}</date>
    <item>{$uri}</item>
</content>,(),$COLLECTIONS)
};

local:insert-content()