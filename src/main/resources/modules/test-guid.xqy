xquery version "1.0-ml";

import module namespace uuid = "http://www.xmlmachines.com/uuid" at "/lib-uuid.xqy";

element guids {
for $x in 1 to 50
return
 element guid {uuid:generate-uuid-v4()}
}

