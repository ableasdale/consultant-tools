xquery version "1.0-ml";

import module namespace worklog = "http://www.xmlmachines.com/worklog" at "/worklog/lib-worklog.xqy";


declare variable $user as xs:string := xdmp:get-request-field("user", "alex");

(
worklog:insert($user)
(:,
xdmp:redirect-response("/worklog"):)
),
<pre>creating worklog entry for: {$user}</pre>