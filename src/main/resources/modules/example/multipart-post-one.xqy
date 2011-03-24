xquery version "1.0-ml";

(: 
   Note - this code currently won't work due to a bug in ML:
   
   xdmp:multipart-encode does not append the terminating sequence
   to the last boundary in the list e.g fn:concat(${boundary},"--")
:)

declare namespace http = "xdmp:http";

declare variable $CRLF := fn:codepoints-to-string((13,10));

declare variable $boundary as xs:string := "---------------------------25706832812190";
declare variable $uri as xs:string := "http://api.scribd.com/api";
declare variable $parts as node()* := (
 xdmp:document-get("/path/to/a/test-doc.pdf")/node(), 
 xdmp:unquote("%YOUR_SCRIBD_API_KEY%", (), "format-binary"),
 xdmp:unquote("docs.upload", (), "format-binary")
 
);

declare function local:multipart-post(
  $uri as xs:string,
  $boundary as xs:string,
  $parts as node()*
) 
{
  xdmp:http-post(
    $uri,
    <options xmlns="xdmp:http">
      <headers>
        <Content-Type>multipart/form-data; boundary={$boundary}</Content-Type>
      </headers>
    </options>,
   
xdmp:multipart-encode(
      $boundary,
      <manifest xmlns="xdmp:multipart">
       { for $part at $pos in $parts
          return element part {
element http:headers {
     local:meta($part, $pos) 
            }
          }
         }
      </manifest>,
      $parts)
)
};

declare function local:meta($part, $pos) as element()* {
(
if ($pos eq 1)
then (
element Content-Disposition {text{'form-data; name="file"; filename="test.pdf"'}}, 
element Content-Type {text{'application/pdf'}}
)
else if ($pos eq 2)
then (
element Content-Disposition {text{'form-data; name="api_key"'}}
)
else if ($pos eq 3)
then (
element Content-Disposition {text{'form-data; name="method"'}}
)
else ()
)
};


local:multipart-post($uri, $boundary, $parts)