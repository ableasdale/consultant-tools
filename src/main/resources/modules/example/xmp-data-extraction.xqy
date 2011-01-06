xquery version "1.0-ml";

declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace tiff="http://ns.adobe.com/tiff/1.0/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace x="adobe:ns:meta/";

(:
 : Example code to show how to extract x:xmpmeta from images, indesign docs etc.
 :)

declare function local:string-to-hex($str as xs:string) as xs:string { 
     upper-case(string-join( for $c in string-to-codepoints($str) 
     return xdmp:integer-to-hex($c), '')) 
};

declare function local:store-example-doc(){
     (xdmp:document-load(
        "http://xquery.typepad.com/photos/uncategorized/maineboat.jpg",
        <options xmlns="xdmp:document-load">
          <uri>/xmp/maine-boat.jpg</uri>
       </options>
     ),<doc>stored</doc>)
};
 

declare function local:view-metadata($uri as xs:string){
(: let $uri :=  "/xmp/maine-boat.jpg" :)

let $start-tag-hex := local:string-to-hex("<x:xmpmeta") 
let $end-tag-hex := local:string-to-hex("</x:xmpmeta>") 
let $xmp:= string(xs:hexBinary(doc($uri)/node())) 
let $index-ofs := fn:tokenize($xmp,$start-tag-hex)
for $x in $index-ofs
let $tail := fn:tokenize($x,$end-tag-hex)
return
  if(count($tail) eq 2) 
  then 
   let $new-xmp := fn:concat($start-tag-hex,$tail[1],$end-tag-hex)
   return try {xdmp:unquote(xdmp:quote(binary { xs:hexBinary($new-xmp) }))
     } catch($x) {<conversion-failure/>}
  else ()
}; 
 
(: Step one - store an image in ML :) 
local:store-example-doc()
 
(: Step two - examine the resultant metadata
local:view-metadata("/xmp/maine-boat.jpg")
:)