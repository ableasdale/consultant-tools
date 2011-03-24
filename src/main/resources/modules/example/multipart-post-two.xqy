xquery version "1.0-ml";

declare function local:post() {
    let $payload := local:build-payload()
    let $options :=
        <options xmlns="xdmp:http">
            <data>{$payload}</data>
            <headers>
                <Content-Type>multipart/form-data; boundary=---------------------------27154641122570</Content-Type>
 <data>api_key=564ebtln0xa1zw72z4hub&amp;method=docs.upload</data>
            </headers>
        </options>
    return 
        try{ 
             xdmp:http-post("http://api.scribd.com/api",$options)
        } catch($e) {xdmp:log($e)}
 };

declare function local:build-payload() {    
    let $CRLF := fn:codepoints-to-string((13,10))
    let $boundary := "-----------------------------27154641122570"
    let $input-type := 'Content-Disposition: form-data; name="file"; filename="test.pdf"'
    let $mime-type := 'Content-Type: application/pdf'
    let $api-key-meta := 'Content-Disposition: form-data; name="api_key"'
    let $api-key := "%YOUR_KEY_HERE"
    
    let $method-meta := 'Content-Disposition: form-data; name="method"'
    let $method := "docs.upload"


let $payload := fn:concat(
        $boundary,$CRLF,
        $input-type,$CRLF,
        $mime-type,$CRLF,
        $CRLF,
binary{xs:hexBinary(xs:base64Binary(data(xdmp:document-get("/path/to/a/test-doc.pdf")/node())))},$CRLF,
        $boundary,$CRLF,
        $api-key-meta,$CRLF,
        $CRLF,
        $api-key,$CRLF,

        $boundary,$CRLF,
        $method-meta,$CRLF,
        $CRLF,
        $method,$CRLF,
        $boundary,"--",$CRLF)
    return (xdmp:log($payload),$payload)
};

local:post()