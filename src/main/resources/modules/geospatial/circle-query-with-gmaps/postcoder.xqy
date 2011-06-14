xquery version "1.0-ml";

declare variable $query := xdmp:get-request-field("postcode", "W2 6BD");

(xdmp:set-response-content-type("text/html; charset=utf-8"),
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
    <title>Postcoder V5</title>
    <link rel="stylesheet" href="/css/screen.css" type="text/css" media="screen, projection" /> 
    <script src="http://maps.google.com/maps/api/js?sensor=false" type="text/javascript">{" "}</script>
    <script src="/v5/js/gmaps.js"type="text/javascript">{" "}</script>
    <script type="text/javascript">
    //<![CDATA[
        var searchUrl = "/v5/search.xqy?postcode=]]>{$query}<![CDATA[";
    //]]>
    </script>
  </head>
  <body style="margin:0px; padding:0px;" onload="init()"> 
    <div id="map" style="width: 100%; height: 100%"></div>
  </body>
</html>)