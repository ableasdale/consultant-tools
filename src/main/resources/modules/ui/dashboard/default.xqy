xquery version "1.0-ml";
(:~
 : Portlet view (powered by MarkLogic)
 :)
 
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
        { local:portlet("FOO", text{"lorem ipsum..."}) }
        { local:portlet("BAR", text{"Lorem ipsum dolor sit amet, consectetuer adipiscing elit"}) }  
    </div>

    <div class="column">
        { local:portlet("DOO", text{"lorem ipsum..."}) }
    </div>

    <div class="column">
        { local:portlet("DAH", text{"lorem ipsum..."}) }
        { local:portlet("BAR", text{"Lorem ipsum dolor sit amet, consectetuer adipiscing elit"}) }
    </div>
</div>

</body>
</html>)