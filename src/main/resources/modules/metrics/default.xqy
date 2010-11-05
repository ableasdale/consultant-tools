xquery version "1.0-ml";
declare namespace s="http://marklogic.com/xdmp/status/server";
declare namespace h="http://marklogic.com/xdmp/status/host";
declare namespace f="http://marklogic.com/xdmp/status/forest";
(:declare variable $serverName as xs:string external;:)
declare variable $serverName as xs:string := xdmp:get-request-field("server", "localhost");

let $map := map:map()
let $server := xdmp:server()
let $forests := xdmp:database-forests(xdmp:database())
let $stats := for $forest in $forests return xdmp:forest-status($forest)
let $counts := for $forest in $forests return xdmp:forest-counts($forest)
let $_puts := (
  let $lch := fn:sum($stats//f:list-cache-hits)
  let $lcm := fn:sum($stats//f:list-cache-misses)
  let $lchr := fn:sum($stats//f:list-cache-hit-rate)
  let $lcmr := fn:sum($stats//f:list-cache-miss-rate)
  let $ctch := fn:sum($stats//f:compressed-tree-cache-hits)
  let $ctcm := fn:sum($stats//f:compressed-tree-cache-misses)
  let $ctchr := fn:sum($stats//f:compressed-tree-cache-hit-rate)
  let $ctcmr := fn:sum($stats//f:compressed-tree-cache-miss-rate)
  return (
    map:put($map, "lc-hits", $lch),
    map:put($map, "lc-misses", $lcm),
    map:put($map, "lc-ratio", if ($lch + $lcm eq 0) then 0 else $lch div ($lch + $lcm)),
    map:put($map, "lc-hit-rate", $lchr),
    map:put($map, "lc-miss-rate", $lcmr),
    map:put($map, "lc-rate-ratio", if ($lchr + $lcmr eq 0) then 0 else $lchr div ($lchr + $lcmr)),
    map:put($map, "ctc-hits", $ctch),
    map:put($map, "ctc-misses", $ctcm),
    map:put($map, "ctc-ratio", if ($ctch + $ctcm eq 0) then 0 else $ctch div ($ctch + $ctcm)),
    map:put($map, "ctc-hit-rate", $ctchr),
    map:put($map, "ctc-miss-rate", $ctcmr),
    map:put($map, "ctc-rate-ratio", if ($ctchr + $ctcmr eq 0) then 0 else $ctchr div ($ctchr + $ctcmr)),
    map:put($map, "documents", fn:sum($counts//f:document-count)),
    map:put($map, "active-fragments", fn:sum($counts//f:active-fragment-count)),
    map:put($map, "nascent-fragments", fn:sum($counts//f:nascent-fragment-count)),
    map:put($map, "deleted-fragments", fn:sum($counts//f:deleted-fragment-count))
  ),
  for $host in xdmp:hosts()
  let $hs := xdmp:host-status($host)
  let $hostname := fn:tokenize(xdmp:host-name($host), "\.")[1]
  return (
    for $ctcp at $i in $hs/h:compressed-tree-cache-partitions/h:compressed-tree-cache-partition
    let $pre := fn:concat($hostname, ":ctcp", $i, "-")
    let $table := $ctcp/h:partition-table
    let $used := $ctcp/h:partition-used
    let $free := $ctcp/h:partition-free
    let $over := $ctcp/h:partition-overhead
    return (
      map:put($map, fn:concat($pre, "table"), fn:number($ctcp/h:partition-table)),
      map:put($map, fn:concat($pre, "used"), fn:number($ctcp/h:partition-used)),
      map:put($map, fn:concat($pre, "free"), fn:number($ctcp/h:partition-free)),
      map:put($map, fn:concat($pre, "overhead"), fn:number($ctcp/h:partition-overhead))
    ),
    for $etcp at $i in $hs/h:expanded-tree-cache-partitions/h:expanded-tree-cache-partition
    let $pre := fn:concat($hostname, ":etcp", $i, "-")
    let $table := $etcp/h:partition-table
    let $used := $etcp/h:partition-used
    let $free := $etcp/h:partition-free
    let $over := $etcp/h:partition-overhead
    return (
      map:put($map, fn:concat($pre, "busy"), fn:number($etcp/h:partition-busy)),
      map:put($map, fn:concat($pre, "table"), fn:number($etcp/h:partition-table)),
      map:put($map, fn:concat($pre, "used"), fn:number($etcp/h:partition-used)),
      map:put($map, fn:concat($pre, "free"), fn:number($etcp/h:partition-free)),
      map:put($map, fn:concat($pre, "overhead"), fn:number($etcp/h:partition-overhead))
    ),
    for $lcp at $i in $hs/h:list-cache-partitions/h:list-cache-partition
    let $pre := fn:concat($hostname, ":lcp", $i, "-")
    let $table := $lcp/h:partition-table
    let $used := $lcp/h:partition-used
    let $free := $lcp/h:partition-free
    let $over := $lcp/h:partition-overhead
    return (
      map:put($map, fn:concat($pre, "busy"), fn:number($lcp/h:partition-busy)),
      map:put($map, fn:concat($pre, "table"), fn:number($lcp/h:partition-table)),
      map:put($map, fn:concat($pre, "used"), fn:number($lcp/h:partition-used)),
      map:put($map, fn:concat($pre, "free"), fn:number($lcp/h:partition-free)),
      map:put($map, fn:concat($pre, "overhead"), fn:number($lcp/h:partition-overhead))
    ),
    let $s := xdmp:server-status($host, $server)
    let $pre := fn:concat($hostname, ":")
    let $now := fn:current-dateTime()
    let $reqs := $s/s:request-statuses/s:request-status
    let $times := 
      for $time in $reqs/s:start-time
      return ($now - $time) div xs:dayTimeDuration("PT0.001S")
    return (
      map:put($map, fn:concat($pre, "threads"), fn:number($s/s:threads)),
      map:put($map, fn:concat($pre, "requests"), fn:count($reqs)),
      map:put($map, fn:concat($pre, "updates"), fn:count($reqs[s:update eq fn:true()])),
      map:put($map, fn:concat($pre, "average-time"), if ($times) then fn:number(fn:avg($times)) else 0),
      map:put($map, fn:concat($pre, "oldest-time"), if ($times) then fn:max($times) else 0),
      map:put($map, fn:concat($pre, "request-rate"), fn:number($s/s:request-rate)),
      map:put($map, fn:concat($pre, "etc-hits"), fn:number($s/s:expanded-tree-cache-hits)),
      map:put($map, fn:concat($pre, "etc-misses"), fn:number($s/s:expanded-tree-cache-misses)),
      map:put($map, fn:concat($pre, "etc-ratio"), 
        if ($s/s:expanded-tree-cache-misses + $s/s:expanded-tree-cache-hits eq 0) then 0
        else $s/s:expanded-tree-cache-hits div 
         ($s/s:expanded-tree-cache-misses + $s/s:expanded-tree-cache-hits)),
      map:put($map, fn:concat($pre, "etc-hit-rate"), fn:number($s/s:expanded-tree-cache-hit-rate)),
      map:put($map, fn:concat($pre, "etc-miss-rate"), fn:number($s/s:expanded-tree-cache-miss-rate)),
      map:put($map, fn:concat($pre, "etc-rate-ratio"), 
        if ($s/s:expanded-tree-cache-miss-rate + $s/s:expanded-tree-cache-hit-rate eq 0) then 0
        else $s/s:expanded-tree-cache-hit-rate div 
         ($s/s:expanded-tree-cache-miss-rate + $s/s:expanded-tree-cache-hit-rate))
    )
  )
)
return
element dl {
for $key in map:keys($map)
order by $key
return (element dt{$key},(: " = ",<strong>,map:get($map, $key), )}:)
element dd {map:get($map, $key)}
)
}