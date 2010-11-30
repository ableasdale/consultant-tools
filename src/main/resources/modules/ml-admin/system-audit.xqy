xquery version "1.0-ml";

(:~
 :
 :  User, Role and privilege auditing script
 :  
 :)

import module "http://marklogic.com/xdmp/security" at "/MarkLogic/security.xqy";

element info {
    element server-name {xdmp:host-name()},
    element user-info {
        for $user in /sec:user
        return
        element user {
            $user/sec:user-id, 
            $user/sec:user-name, 
            $user/sec:description,
            element roles {
                for $role in xdmp:user-roles($user/sec:user-name)
                return
                (element role {$role}, sec:get-role-names($role))
            }         
        }
    },

    element role-info {
        for $role in /sec:role
        return $role
    },

    element privilege-info {
        for $priv in /sec:privilege
        return $priv
    },

    element collection-info {
        for $coll in /sec:collection
        return 
        element collection {
        $coll,
        element permissions {
            for $permission in sec:collection-get-permissions($coll/sec:uri/text())
            return 
                $permission
            }
        }
    }
}