


(:
:: Summary:
::
:: Returns the html login form used on both the login and logout pages.
::
:)
declare function tix-include:getLoginForm(){
   <div id="login-component">
   <form action="/login/validate.xqy" method="post">
    <p class="inputfield">
        <label for="username">User name: </label>
        <input id="username" type="text" name="user" />
    </p>
    
    <p class="inputfield">
        <label for="password">Password: </label>
        <input type="password" name="password" />
    </p>
    
    <p>
        <input type="submit" name="submit" value="Submit" />
    </p>
   </form>
   {tix-include:getAdminUserLink()}
   </div>
};