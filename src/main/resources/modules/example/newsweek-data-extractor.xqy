xquery version "1.0-ml";

(:~
 : A small snippet of code for getting a few "searchable" XML docs into
 : MarkLogic - useful if you quickly want to get some test data into a DB
 : for demo purposes.
 :
 : This module takes the current RSS feed from Newsweek and for each entry, 
 : ingests the content of the article into MarkLogic
 :)
 
declare namespace atom = "http://www.w3.org/2005/Atom";

let $list := for $entry in xdmp:document-get('http://feeds.newsweek.com/newsweek/TopNews')/atom:feed/atom:entry/atom:id
return 
fn:concat("http://www.newsweek.com",fn:substring-after($entry/text(), "/content/newsweek"),".xml")


for $entry in $list
return
xdmp:document-insert($entry, xdmp:document-get($entry))
 

