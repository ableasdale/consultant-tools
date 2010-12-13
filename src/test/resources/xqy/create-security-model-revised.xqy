xquery version "1.0-ml";

(:~ 
 : Security Module for creating the Generic Database Users and roles
 :
 : @version 1.0
 :)

import module namespace sec = "http://marklogic.com/xdmp/security" at "/MarkLogic/security.xqy";

(: Specific Roles :)
declare variable $INSERT-UPDATE-ROLE-NAME as xs:string := "insert-update-role";
declare variable $INSERT-UPDATE-ROLE-DESCRIPTION as xs:string := "Database Insert/Update Role";
declare variable $EXECUTE-READ-ROLE-NAME as xs:string := "execute-read-role";
declare variable $EXECUTE-READ-ROLE-DESCRIPTION as xs:string := "Database Execute/Read Role";

(: Users :)
declare variable $NO-PERMS-USER-NAME as xs:string := "no-perms";
declare variable $NO-PERMS-USER-DESCRIPTION as xs:string := "No Permissions Test User";
declare variable $NO-PERMS-USER-PASSWORD as xs:string := "password";

declare variable $FULL-ACCESS-USER-NAME as xs:string := "full-user";
declare variable $FULL-ACCESS-USER-DESCRIPTION as xs:string := "Database Full Access User";
declare variable $FULL-ACCESS-USER-PASSWORD as xs:string := "password";

declare variable $EXECUTE-READ-USER-NAME as xs:string := "execute-read-user";
declare variable $EXECUTE-READ-USER-DESCRIPTION as xs:string := "Database Execute / Read User";
declare variable $EXECUTE-READ-USER-PASSWORD as xs:string := "password";


(:~
 : Function to create the new Database access roles:
 :
 : <ul>
 : <li>An Insert/Update Role</li>
 : <li>An Execute/Read Role</li>
 : </ul>
 :)
declare function local:create-roles() as xs:unsignedLong+ {
    (: Create Insert/Update Role :)
    sec:create-role($INSERT-UPDATE-ROLE-NAME,$INSERT-UPDATE-ROLE-DESCRIPTION,(),(),()),
    (: Create Execute/Read Role :)
    sec:create-role($EXECUTE-READ-ROLE-NAME,$EXECUTE-READ-ROLE-DESCRIPTION,(),(),())
};
 
(:~
 : Function to add the required privileges and permissions to the newly created roles:
 :
 : <ul>
 : <li>Execute permissions for Insert and Update</li>
 : <li>Execute permissions for Execute and Read</li>
 : <li>Configuring permissions based on the role nature</li>
 : <li>Applying Default permissions for both roles</li>
 : </ul>
 :) 
declare function local:create-privileges() as empty-sequence() {
    (: Insert/Update Privileges :)
    sec:privilege-add-roles("http://marklogic.com/xdmp/privileges/any-collection","execute",$INSERT-UPDATE-ROLE-NAME),
    sec:privilege-add-roles("http://marklogic.com/xdmp/privileges/any-uri","execute",$INSERT-UPDATE-ROLE-NAME),
    sec:privilege-add-roles("http://marklogic.com/xdmp/privileges/unprotected-collections","execute",$INSERT-UPDATE-ROLE-NAME),
    sec:privilege-add-roles("http://marklogic.com/xdmp/privileges/xdbc-insert","execute",$INSERT-UPDATE-ROLE-NAME),        
    (: Execute/Read Privileges :)
    sec:privilege-add-roles("http://marklogic.com/xdmp/privileges/xdbc-eval","execute",$EXECUTE-READ-ROLE-NAME),
    sec:privilege-add-roles("http://marklogic.com/xdmp/privileges/xdbc-eval-in","execute",$EXECUTE-READ-ROLE-NAME),
    sec:privilege-add-roles("http://marklogic.com/xdmp/privileges/xdbc-invoke","execute",$EXECUTE-READ-ROLE-NAME),
    sec:privilege-add-roles("http://marklogic.com/xdmp/privileges/xdbc-invoke-in","execute",$EXECUTE-READ-ROLE-NAME),
    sec:privilege-add-roles("http://marklogic.com/xdmp/privileges/xdmp-eval","execute",$EXECUTE-READ-ROLE-NAME),
    sec:privilege-add-roles("http://marklogic.com/xdmp/privileges/xdmp-eval-in","execute",$EXECUTE-READ-ROLE-NAME),
    sec:privilege-add-roles("http://marklogic.com/xdmp/privileges/xdmp-invoke","execute",$EXECUTE-READ-ROLE-NAME),
    sec:privilege-add-roles("http://marklogic.com/xdmp/privileges/xdmp-invoke-in","execute",$EXECUTE-READ-ROLE-NAME),
    let $permissions :=
        (
            xdmp:permission($EXECUTE-READ-ROLE-NAME,"read"),
            xdmp:permission($EXECUTE-READ-ROLE-NAME,"execute") 
        )
    return
       sec:role-set-default-permissions($EXECUTE-READ-ROLE-NAME,$permissions),  
    let $permissions := 
        (
            xdmp:permission($INSERT-UPDATE-ROLE-NAME,"insert"),
            xdmp:permission($INSERT-UPDATE-ROLE-NAME,"update")
        )
    return
        sec:role-set-default-permissions($INSERT-UPDATE-ROLE-NAME,$permissions)
};

(:~
 : Function to create two users for testing both roles:
 :
 : <ul>
 : <li>A Full Access User with both Read/Execute and Insert/Update roles</li>
 : <li>A limited user with only Execute/Read Roles</li>
 : </ul>
 :
 : This step is optional; DBAs may want to manually create these users
 :)
declare function local:create-users() as xs:unsignedLong+ {
(: Create Full Access User :)
sec:create-user(
                $FULL-ACCESS-USER-NAME, 
                $FULL-ACCESS-USER-DESCRIPTION,
                $FULL-ACCESS-USER-PASSWORD,
                ($INSERT-UPDATE-ROLE-NAME, $EXECUTE-READ-ROLE-NAME),
                (), (: permissions :)
                () (: collections :)
                ),
(: Create Execute/Read User :)                
sec:create-user(
                $EXECUTE-READ-USER-NAME, 
                $EXECUTE-READ-USER-DESCRIPTION,
                $EXECUTE-READ-USER-PASSWORD,
                $EXECUTE-READ-ROLE-NAME,
                (), (: permissions :)
                () (: collections :)
                ),
                
sec:create-user(
                $NO-PERMS-USER-NAME, 
                $NO-PERMS-USER-DESCRIPTION,
                $NO-PERMS-USER-PASSWORD,
                (), (: roles :)
                (), (: permissions :)
                () (: collections :)
                )     
};


(::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::)
(:                          Module Actions Below                          :) 
(::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::)

(: Step One 
local:create-roles()
:)

(: Step Two
local:create-privileges() 
:)

(: Step Three (Optional - you may want to create these users manually)
local:create-users()
:)