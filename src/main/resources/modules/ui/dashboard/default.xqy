xquery version "1.0-ml";
(:~
 : Portlet view (powered by MarkLogic)
 :)
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

    <div class="portlet">
        <div class="portlet-header">Feeds</div>
        <div class="portlet-content">Lorem ipsum dolor sit amet, consectetuer adipiscing elit</div>
    </div>
    
    <div class="portlet">
        <div class="portlet-header">News</div>
        <div class="portlet-content">Lorem ipsum dolor sit amet, consectetuer adipiscing elit</div>
    </div>

</div>

<div class="column">

    <div class="portlet">
        <div class="portlet-header">Shopping</div>
        <div class="portlet-content">Lorem ipsum dolor sit amet, consectetuer adipiscing elit</div>
    </div>

</div>

<div class="column">

    <div class="portlet">
        <div class="portlet-header">Links</div>
        <div class="portlet-content">Lorem ipsum dolor sit amet, consectetuer adipiscing elit</div>
    </div>
    
    <div class="portlet">
        <div class="portlet-header">Images</div>
        <div class="portlet-content">Lorem ipsum dolor sit amet, consectetuer adipiscing elit</div>
    </div>

</div>

</div>
        <!--<ul id="column3" class="column">
            <li class="widget color-orange">  
                <div class="widget-head">

                    <h3>Author Locations</h3>
                </div>
                <div class="widget-content">
                    <p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam magna sem, fringilla in, commodo a, rutrum ut, massa. Donec id nibh eu dui auctor tempor. Morbi laoreet eleifend dolor. Suspendisse pede odio, accumsan vitae, auctor non, suscipit at, ipsum. Cras varius sapien vel lectus.</p>
                </div>
            </li>            
        </ul>-->
</body>
</html>)

(: /*<![CDATA[*/]]> :)