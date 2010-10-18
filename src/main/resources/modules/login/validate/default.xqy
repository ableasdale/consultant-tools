(:~
: Manages user validation 
:
: @author Alex Bleasdale
: @version 1.0
:)
xquery version "1.0-ml";
import module namespace login = "http://www.xmlmachines.com/login" at "/xq/modules/common_module.xqy";

let $user := xdmp:get-request-field ("user", ""),
    $password := xdmp:get-request-field ("password", "")
return
if (login:validateLogin($user,$password)) then
let $session-field := xdmp:set-session-field("login-status", "valid")
return
xdmp:redirect-response("/default.xqy")
else
let $session-field := xdmp:set-session-field("login-status", "invalid")
return
xdmp:redirect-response("/login")

