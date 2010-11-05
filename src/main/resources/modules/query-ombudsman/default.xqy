declare namespace ss = "http://marklogic.com/xdmp/status/server";

declare function local:delete-uri($request-status as element(ss:request-status)) as xs:string
{
	fn:concat("?cancel=true","&amp;",
	"request-id=",xdmp:url-encode(xs:string($request-status/ss:request-id)),"&amp;",
	"host-id=",xdmp:url-encode(xs:string($request-status/ss:host-id)),"&amp;",
	"server-id=",xdmp:url-encode(xs:string($request-status/ss:server-id)))
};

declare function local:request($request-status as element(ss:request-status)) as element()+
{
  <tr>
      <td>{xdmp:server-name($request-status/ss:server-id)}</td>
      <td>{xdmp:host-name($request-status/ss:host-id)}</td>
      <td>{fn:current-dateTime() - $request-status/ss:start-time}</td>
      <td>{$request-status/ss:client-address}</td>
      <td><div class="arrow"></div></td>
  </tr>,
  <tr>
    <td colspan="5">
      <h4>Additional information</h4>
			<a href="{local:delete-uri($request-status)}">
				<img src="images/Delete-icon.png" width="128" height="128" alt="Cancel this Query" />
			</a>
				{
					if(fn:current-dateTime() - $request-status/ss:start-time gt xs:dayTimeDuration("PT40M")) then (
						<img src="images/zero-tolerance.jpg" width="237" height="178" style="clear:both;float:right" />,
						<h3>Have zero tolerence for this Query</h3>	)
					else ()
				}

				<ul id="details">
					<li><strong>Request ID:</strong> {fn:data($request-status/ss:request-id)}</li>
					<li><strong>Canceled:</strong> {fn:data($request-status/ss:canceled)}</li>
					<li><strong>Modules:</strong> {fn:data($request-status/ss:modules)}</li>
					<li><strong>Database:</strong> {xdmp:database-name(fn:data($request-status/ss:database))}</li>
					<li><strong>Root:</strong> {fn:data($request-status/ss:root)}</li>
					<li><strong>Request Kind:</strong> {fn:data($request-status/ss:request-kind)}</li>
					<li><strong>Request Text:</strong> {fn:data($request-status/ss:request-text)}</li>
					<li><strong>Update:</strong> {fn:data($request-status/ss:update)}</li>
					<li><strong>Time-Limit:</strong> {fn:data($request-status/ss:time-limit)}</li>
					<li><strong>Max Time Limit:</strong> {fn:data($request-status/ss:max-time-limit)}</li>
					<li><strong>User:</strong> {fn:data($request-status/ss:user)}</li>
					<li><strong>Trigger Depth:</strong> {fn:data($request-status/ss:trigger-depth)}</li>
					<li><strong>Expanded Tree Cache Hits:</strong> {fn:data($request-status/ss:expanded-tree-cache-hits)}</li>
					<li><strong>Expanded Tree Cache Misses:</strong> {fn:data($request-status/ss:expanded-tree-cache-misses)}</li>
					<li><strong>Request State:</strong> {fn:data($request-status/ss:request-state)}</li>
					<li><strong>Profiing Allowed:</strong> {fn:data($request-status/ss:profiling-allowed)}</li>
					<li><strong>Profiling Enabled:</strong> {fn:data($request-status/ss:profiling-enabled)}</li>
					<li><strong>Debugging Allowed:</strong> {fn:data($request-status/ss:debugging-allowed)}</li>
					<li><strong>Debugging Status:</strong> {fn:data($request-status/ss:debugging-status)}</li>
				</ul>
      </td>
  </tr>
};

if(xdmp:get-request-field("cancel", "true") eq "true") then (

	let $request-id := xs:unsignedLong(xdmp:get-request-field("request-id"))
	let $host-id := xs:unsignedLong(xdmp:get-request-field("host-id"))
	let $server-id := xs:unsignedLong(xdmp:get-request-field("server-id"))

	return
	try {
		xdmp:request-cancel(
			$host-id,
			$server-id,
			$request-id
		)
	} catch($e) {}
) else (),


<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Expand table rows with jQuery - jExpand plugin - JankoAtWarpSpeed demos</title>
    <script src="js/jquery.min.js" type="text/javascript"></script>
    <script type="text/javascript" src="js/adhoc.js"><!-- --></script>        
		<link href="css/style.css" rel="stylesheet" type="text/css" media="screen" />
</head>
<body>
    <h1>The Query Judge</h1>

    <table id="report">
        <tr>
            <th>Server</th>
            <th>Host</th>
						<th>Elapsed Time</th>
	    			<th>Invoked By</th>
						<th />
        </tr>

				{
					
					for $host in xdmp:hosts()
					for $server in xdmp:servers()
					return local:request(xdmp:server-status($host, $server)//ss:request-status)
				}

    </table>

</body>
</html>


