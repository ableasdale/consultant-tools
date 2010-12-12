xquery version '1.0-ml'; 

declare namespace sec="http://marklogic.com/xdmp/security";

declare option xdmp:mapping "true";

declare function local:expand-roles($role-ids as element(sec:role-id)*) {
if ($role-ids) 
then
	element roles {
	for $role in /sec:role[sec:role-id = $role-ids]
		return element role {
		      element role-name { $role/sec:role-name/string() },
		      element role-description { $role/sec:description/string() },
		      local:format-permissions($role/sec:permissions),
		      local:expand-roles($role/sec:role-ids/sec:role-id)
    		}
	}
else ()
};

declare function local:format-permissions($permissions as element(sec:permissions)) {
if ($permissions/sec:permission) 
then  
	element permissions {
		for $perm in $permissions/sec:permission
		return
      			element permission {
        			element capability { $perm/sec:capability/string() },
				element role-name { /sec:role[sec:role-id eq $perm/sec:role-id]/sec:role-name/string() }
       			}
  	}
else ()
};

declare function local:build-tree(){
element roles-tree {
for $user in /sec:user
order by $user/sec:user-name
return
	element user {
		element name {
			$user/sec:user-name/string()
		},
		element description {
	    		$user/sec:description/string()
	  	},
		local:format-permissions($user/sec:permissions),
	  	local:expand-roles($user/sec:role-ids/sec:role-id)
	}
}
};

declare function local:generate-tree-view(){
element ul {attribute id{"collapser"},
for $user in local:build-tree()/user
return
	(element li {text{$user/name/text(), "(",$user/description/text(),") "}, element span{attribute class{"total"}, text{count($user/roles/role)," roles"}}, local:process-user-roles($user)})
}
};

declare function local:process-user-roles($user as element(user)){
for $roles in $user/roles
return
	local:process-roles($user/roles)
};

declare function local:process-permissions($elem as element(permissions)){
element ul {
for $permission in $elem/permission
return 
	element li {attribute class {"permission"}, text {$permission/role-name/text(), " (",$permission/capability/text(),")"}}
}
};

declare function local:process-roles($elem as element(roles)){
element ul {
for $role in $elem/role
return 
	(element li {text {$role/role-name/text(), "(",$role/role-description/text(),")"},
	local:process-permissions($role/permissions),
	local:process-roles($role/roles)
	})
}
};

declare function local:local-js() as xs:string{
"$(function(){$('#collapser').jqcollapse({slide: true, speed: 500, easing: 'easeOutCubic'}); });"
};

declare function local:local-css() as xs:string{
"body { width: 500px; margin: 100px auto; font: normal 14px Arial, Helvetica, sans-serif; }
ul { margin: 0; padding: 0; }
ul li { margin: 10px 0 10px 25px; padding: 0; list-style: none; }
.jqcNode { font-weight: bold; color: green; }
.total, .permission { color: red; }"
};

declare function local:generate-html-page($elem as element(), $env-name as xs:string){
('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">',
element html {
	element head {
		element meta {attribute http-equiv{"Content-Type"}, attribute content{"text/html"} },
		element title {concat("Users and Roles (",$env-name,")")},
		element script {attribute type{"text/javascript"}, attribute src {"jquery.js"}," "},
		element script {attribute type{"text/javascript"}, attribute src {"jquery.easing.js"}," "},
		element script {attribute type{"text/javascript"}, attribute src {"jquery.collapse.js"}," "},
		element script {attribute type{"text/javascript"}, local:local-js()},
		element style {attribute type{"text/css"}, local:local-css()}
	},
	element body {element h1 {concat("Users and Roles (",$env-name,")")}, $elem}
})
};
(: process the tree :)
local:generate-html-page(local:generate-tree-view(), "UATi")
