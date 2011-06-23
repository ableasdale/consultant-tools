xquery version "1.0-ml";

(:~
 : Example Database Configuration Script
 :)
import module namespace info = "http://marklogic.com/appservices/infostudio" at "/MarkLogic/appservices/infostudio/info.xqy";
import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

(: All current configuration values :)
declare variable $databasename as xs:string := "Documents";
declare variable $phrase-throughs as xs:string+ := ("PhraseThroughElementName");
declare variable $phrase-arounds as xs:string+ := ("PhraseAroundElementName");
declare variable $indexes as element(newIndexes) :=
<newIndexes>
  <newIndex names="ElementA, ElementB" type="string" namespace="http://www.xmlmachines.com/app" />
  <newIndex names="Date" type="date" namespace="http://www.xmlmachines.com/app" />
</newIndexes>;

(: Local functions :)
declare function local:initial-db-check($dbname as xs:string) as xs:unsignedLong? {
    for $db in xdmp:databases()
    where xdmp:database-name($db) eq $dbname
    return $db
};

declare function local:apply-initial-database-settings($databasename as xs:string) {
    let $config := admin:get-configuration()
    let $config := admin:database-set-uri-lexicon($config, xdmp:database($databasename), fn:true())
    let $config := admin:database-set-collection-lexicon($config, xdmp:database($databasename), fn:true())
    let $config := admin:database-set-directory-creation($config, xdmp:database($databasename), "manual")
    let $config := admin:database-set-maintain-last-modified($config, xdmp:database($databasename), fn:false())
    return
    admin:save-configuration($config)
};

(: Phrasethrough handling :)

declare function local:add-phrasethrough-to-config($config, $name as xs:string) {
    try {
      admin:database-add-phrase-through($config, xdmp:database($databasename),
        (
            admin:database-phrase-through((), $name )
        )
      )
    } catch ($e) {
        xdmp:log( concat("Unable to set phrasethrough - it may already exist?: " , $e/*:message/text()) )
    }
};

declare function local:apply-phrasethrough($name as xs:string) {
    let $config := admin:get-configuration()
    let $config := local:add-phrasethrough-to-config($config, $name)
    return
    admin:save-configuration($config)
};

declare function local:configure-phrasethroughs(){
 for $elementname in $phrase-throughs
 return
 local:apply-phrasethrough($elementname)
};

(: Phrase around handling :)

declare function local:add-phrasearound-to-config($config, $name as xs:string) {
    try {
      admin:database-add-phrase-around($config, xdmp:database($databasename),
        (
            admin:database-phrase-around((), $name )
        )
      )
    } catch ($e) {
        xdmp:log( concat("Unable to set phrasearound - it may already exist?: " , $e/*:message/text()) )
    }
};

declare function local:apply-phrasearound($name as xs:string) {
    let $config := admin:get-configuration()
    let $config := local:add-phrasearound-to-config($config, $name)
    return
    admin:save-configuration($config)
};

declare function local:configure-phrasearounds(){
 for $elementname in $phrase-arounds
 return
 local:apply-phrasearound($elementname)
};

declare function local:add-range-index($config as element(configuration), $dbName as xs:string,
  $index as element(index)){

   let $ret := try {
        admin:database-add-range-element-index(
            $config,
            xdmp:database($dbName),
            admin:database-range-element-index(
                $index/@type,
                $index/@namespace,
                $index/@name,
                $index/@collation,
                $index/@usePosition
            )
        )
    } catch ($e) {
         $e/*:message/text()
    }
    return $ret
};

declare function local:unroll-indexes($newIndexes as element(newIndexes))
  as element(index)* {

    let $res := for $index in $newIndexes/newIndex
      let $names := tokenize($index/@names, ",")
      let $type := $index/@type
      let $usePosition := if($index/@usePosition) then xs:boolean($index/@usePosition)
        else false()
      let $namespace := if($index/@namespace) then $index/@namespace else ""
      let $collation := if($index/@collation) then $index/@collation
        else if($type eq "string") then "http://marklogic.com/collation/codepoint"
        else "http://marklogic.com/collation"
      return for $iname in $names
        let $name := normalize-space($iname)
        return <index name="{$name}" type="{$type}" usePosition="{$usePosition}" namespace="{$namespace}"
      collation="{$collation}"/>
    return $res
};


declare function local:add-indexes($dbName as xs:string, $newIndexes as element(newIndexes)) {
  let $config := admin:get-configuration()
  let $indexes := local:unroll-indexes($newIndexes)
  let $results := local:process-indexes($config, $dbName, $indexes)
  let $updatedConfig := $results[1]
  let $statuses := subsequence($results, 2, count($results))
  let $dummy := admin:save-configuration($updatedConfig)
  return element results {$statuses}

};

declare function local:process-indexes($config as element(configuration), $dbName as xs:string, $indexes as element(index)*) {
  let $idxCount := count($indexes)
  return if($idxCount eq 1) then
      let $index := $indexes[1]
      let $c := local:add-range-index($config, $dbName, $index)
      return if($c instance of element(configuration)) then
    ($c, element addedIndex{$index/@name})
      else
        ($config, element indexFailed{$index/@name, $c})
  else
      let $index := $indexes[1]
      let $r := local:add-range-index($config, $dbName, $index)
      let $updatedConfig := if($r[1] instance of element(configuration)) then $r[1] else $config
      let $resultMessage := if($r[1] instance of element(configuration)) then
    element addedIndex {$index/@name}
      else
        element indexFailed {$index/@name, $r[1]}
      let $ret := local:process-indexes($updatedConfig, $dbName, subsequence($indexes, 2,  count($indexes)))
      return ($ret[1], ($resultMessage, subsequence($ret, 2, count($ret))))
};

(: Module main :)

(
(: STEP ONE - Check first - then create database :)
if (local:initial-db-check($databasename) gt 0)
then (xdmp:log( concat("Database ", $databasename, " already exists, no further action required" )))
else (info:database-create($databasename)),

(: STEP TWO - Apply base level settings to database :)
local:apply-initial-database-settings($databasename),

(: STEP THREE - Create range indexes :)
local:add-indexes($databasename, $indexes),

(: STEP FOUR - add phrase throughs :)
local:configure-phrasethroughs(),

(: STEP FIVE - add phrase arounds :)
local:configure-phrasearounds()
)
