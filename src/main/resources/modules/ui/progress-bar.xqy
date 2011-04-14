xquery version "1.0-ml";

(:~
 : Basic example of how XQuery could be used to calculate the percentage difference
 : between two values (e.g. items processed) and pass the values to jQuery 
 : for display.
 :
 : Possible usage: an extension to CORB?
 :)

let $c := xdmp:get-request-field("c", "35227")
let $r := xdmp:get-request-field("r", "878927")
let $p := floor(xs:integer($c) div xs:integer($r) * 100 )
return 
(xdmp:set-response-content-type("text/html; charset=utf-8"),
<html>
<head>
  <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" rel="stylesheet" type="text/css"/>
  
  <script language="javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js">{" "}</script>
  <script language="javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js">{" "}</script>

  <script type="text/javascript">
    <![CDATA[$(document).ready(function() {$("#progressbar").progressbar({ value: ]]>{$p}<![CDATA[});});]]>
  </script>
</head>
<body style="font-size:62.5%;">

<div id="progressbar"></div>

</body>
</html>)