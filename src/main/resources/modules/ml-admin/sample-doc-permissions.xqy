xquery version "1.0-ml";
 
import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

declare variable $INTERVALS as xs:string+ := ("1", "5000", "100000", "1500000", "7500000", "9000000");

declare function local:collate-permissions($doc) {
	functx:distinct-deep($doc/sec:permission)
};

declare function local:get-permissions($startidx as xs:string) {
element permissions-doc {
for $uri in cts:uris($startidx ,("document", "limit=1000"), (), (), () )
	return xdmp:document-get-permissions($uri)
}
};

for $interval in $INTERVALS
return
element item {attribute interval{$interval},
	local:collate-permissions(local:get-permissions($interval))
}
