xquery version "1.0-ml";
(xdmp:set-response-content-type("text/html"),
 '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
<html>
<head>
    <link rel="stylesheet" href="/css/screen.css" type="text/css" media="screen, projection" />
</head>
<body>
<div class="container">
    <h1>Postcode Search</h1>
    
    <div class="span-12">
        <form id="searchform" method="POST" action="/v5/postcoder.xqy">
            <fieldset> 
                <legend>Search by London Postcode</legend> 
                <p> 
                    <label for="postcode">London Postcode</label><br />
                    <input type="text" class="title" name="postcode" /><button type="submit" title="Run Search">Go</button> 
                </p> 
            </fieldset>        
        </form>
    </div>
    
    <div class="span-12">        
        <h2>Examples</h2>
        <ul>
            <li><a href="/v5/postcoder.xqy?postcode=W1B 1AD">RIBA (London W1B 1AD)</a></li>
            <li><a href="/v5/postcoder.xqy?postcode=NW1 2DB">The British Library (NW1 2DB)</a></li>     
            <li><a href="/v5/postcoder.xqy?postcode=WC2N 5DN">Trafalgar Square (WC2N 5DN)</a></li>
            <li><a href="/v5/postcoder.xqy?postcode=SW1P 4RG">Tate Britain (SW1P 4RG)</a></li>
            <li><a href="/v5/postcoder.xqy?postcode=W12 7RJ">BBC Television Centre (W12 7RJ)</a></li>
        </ul>
     </div>
</div>
</body>
</html>) 