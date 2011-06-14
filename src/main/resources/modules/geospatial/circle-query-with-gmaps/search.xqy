xquery version "1.0-ml";

declare variable $miles-radius := 0.3;
declare variable $query := xdmp:get-request-field("postcode", "W2 6BD");

declare function local:create-primary-marker($doc){
    element Marker {
        attribute name {$doc/Location/Postcode/text()},
        attribute address {$doc/Location/District/text()},
        attribute lat {$doc/Location/Latitude/text()},
        attribute lng {$doc/Location/Longitude/text()}
    }
};

(: <marker name="heading" address="content" lat="" lng="" distance=""/> :)
declare function local:create-geosearch-markers($docs){
    for $item in $docs/Location
    return 
    element Marker {
        attribute name {$item/CommonName/text()},
        attribute address {$item/Street/text()},
        attribute lat {$item/Latitude/text()},
        attribute lng {$item/Longitude/text()}
    }
};

let $doc := 
cts:search(
    doc(),
    cts:element-value-query(
        xs:QName("Postcode"), 
        $query, 
        ("case-insensitive", "whitespace-insensitive")
    )
)
(: from the doc - create the radial search :)
return
let $point := cts:point($doc/Location/Latitude/text(), $doc/Location/Longitude/text())
let $circle := cts:circle($miles-radius, $point)
let $docs := cts:search(doc()[/Location/AtcoCode],
cts:element-pair-geospatial-query(xs:QName("Location"), xs:QName("Latitude"),
xs:QName("Longitude"), $circle))
return
element Markers {
  (
  local:create-primary-marker($doc),
  local:create-geosearch-markers($docs)  
  )
}