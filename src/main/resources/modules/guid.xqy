(:~
 : Rough code for creating a v4 UUID - assembled from notes in this digest:
 : http://xqzone.marklogic.com/pipermail/general/2007-August/001024.html
 :
 : Code written in cq in MarkLogic - would need to be refactored into a module.
 : To test - copy and paste the code into http://localhost:8000/cq and hit XML  
 :
 : @author Alex Bleasdale 
 :)

xquery version '1.0-ml';

declare function local:random-hex($length as xs:integer) as xs:string {
  string-join(for $n in 1 to $length
    return xdmp:integer-to-hex(xdmp:random(15)),
    ""
  )
};

declare function local:generate-uuid-v4() as xs:string {
  string-join(
    (
      local:random-hex(8),
      local:random-hex(4),
      local:random-hex(4),
      local:random-hex(4),
      local:random-hex(12)
    ),
    "-"
  )
};

(: Query :)

<guids>
{
for $x in 1 to 50
return
<guid>{local:generate-uuid-v4()}</guid>
}
</guids>
