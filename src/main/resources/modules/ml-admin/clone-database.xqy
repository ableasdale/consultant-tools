xquery version "1.0-ml";
(:~
 : Rough Module for cloning a database - not tested in production.
 :)
import module namespace admin = "http://marklogic.com/xdmp/admin" 
          at "/MarkLogic/admin.xqy";

declare function local:clone-database(  $config,
                                        $source-database-name,
                                        $target-database-name,
                                        $triggers-database-name ){
let $config :=
    if ( $triggers-database-name eq "none" )
    then $config
    else local:clone-database( $config, "Triggers", $triggers-database-name, "none" )
        
let $config := admin:forest-copy($config, admin:forest-get-id( $config, $source-database-name ), $target-database-name, ())
let $config := admin:database-copy($config, admin:database-get-id( $config, $source-database-name ), $target-database-name)
let $config := (admin:save-configuration($config), $config)
let $config := admin:database-attach-forest($config, xdmp:database($target-database-name), xdmp:forest($target-database-name) )
let $config :=
        if ( $triggers-database-name eq "none" )
        then $config
        else admin:database-set-triggers-database($config, admin:database-get-id( $config, $target-database-name ), admin:database-get-id( $config, $triggers-database-name ))
return 
    admin:save-configuration($config)
}; 

(:local:clone-database(admin:get-configuration(), "test", "test2", "none"):)
