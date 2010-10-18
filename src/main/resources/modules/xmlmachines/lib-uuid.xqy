(:~
 : Rough code for creating a v4 UUID - assembled from notes in this digest:
 : http://xqzone.marklogic.com/pipermail/general/2007-August/001024.html
 :
 : @author Alex Bleasdale 
 :)

xquery version '1.0-ml';

module namespace uuid="http://www.xmlmachines.com/uuid";

declare private function uuid:random-hex($length as xs:integer) as xs:string {
  fn:string-join(for $n in 1 to $length
    return xdmp:integer-to-hex(xdmp:random(15)),
    ""
  )
};

declare function uuid:generate-uuid-v4() as xs:string {
  fn:string-join(
    (
      uuid:random-hex(8),
      uuid:random-hex(4),
      uuid:random-hex(4),
      uuid:random-hex(4),
      uuid:random-hex(12)
    ),
    "-"
  )
};