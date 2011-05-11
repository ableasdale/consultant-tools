xquery version "1.0-ml";
(:~
 : Portlet view (powered by MarkLogic)
 :)
declare function local:first-ten-docs() as element(span) {
    element span {
        (for $doc in doc()[1 to 10]
        return element p {xdmp:node-uri($doc)})
    }
};

declare function local:lorem-ipsum() as element(span) {
    element span {
        (
        element p {"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec odio. Quisque volutpat mattis eros. Nullam malesuada erat ut turpis. Suspendisse urna nibh, viverra non, semper suscipit, posuere a, pede."},
        element p {"Donec nec justo eget felis facilisis fermentum. Aliquam porttitor mauris sit amet orci. Aenean dignissim pellentesque felis."},
        element p {"Morbi in sem quis dui placerat ornare. Pellentesque odio nisi, euismod in, pharetra a, ultricies in, diam. Sed arcu. Cras consequat."}
        )
    }
};
 
declare function local:portlet-body($content as node()) as element(div){
    element div {
        attribute class {"portlet-content"},
        $content
    }
 };
 
 declare function local:portlet-header($name as xs:string){
    element div {
        attribute class {"portlet-header"},
        $name   
    }
 };
 
 declare function local:portlet($name as xs:string, $content as node() ){
    element div {
        attribute class {"portlet"},
        local:portlet-header($name),
        local:portlet-body($content)   
    }
 };
 
(xdmp:set-response-content-type("text/html; charset=utf-8"),
<html>
<head>  
    <link href="dashboard.css" rel="stylesheet" type="text/css" />
    <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" rel="stylesheet" type="text/css"/>
    <script language="javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6/jquery.min.js">{" "}</script>
    <script language="javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js">{" "}</script>
    <script language="javascript" src="controller.js">{" "}</script>
</head>
<body>

<div class="demo">
    <div class="column">
        { local:portlet("Top Ten", local:first-ten-docs()) }
        { local:portlet("Lorem Ipsum", local:lorem-ipsum()) }  
    </div>

    <div class="column">
        { local:portlet("Downloads", local:lorem-ipsum()) }
    </div>

    <div class="column">
        { local:portlet("Favourites", local:lorem-ipsum()) }
        { local:portlet("Other Stuff", local:lorem-ipsum()) }
    </div>
</div>

</body>
</html>)