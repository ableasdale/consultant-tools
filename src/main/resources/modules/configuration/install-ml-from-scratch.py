#!/usr/bin/python
import os
import sys
import subprocess
import shlex
import time
import urllib
import urllib2

#########################################################################
#									#
#	Generic MarkLogic install and configuration script		#
#	author: Alex Bleasdale <ableasdale@marklogic.com>		#
#	version: 0.3							#
#									#
#########################################################################

LICENSE_KEY = "xxxx-xxxx-xxxx-xxxx-xxxx-xxxx"
LICENSEE = "Organisation - User - Evaluation"
ACCEPTED_AGREEMENT = "evaluation"

BINARY_PATH = "http://developer.marklogic.com/download/binaries/4.2/"
BINARY_FILENAME = "MarkLogic-4.2-4.x86_64.rpm"

ADM_UNAME = "admin"
ADM_PASSWORD = "admin"

BASE_HREF = "http://localhost:8001/"
BASE_XDBC_PORT = "9999"
MAIN_HTTP_PORT = "9997"

LICENCE_ARGS = { 'license-key':LICENSE_KEY, 'licensee':LICENSEE }
SECURITY_ARGS = { 'auto':'true', 'user':ADM_UNAME, 'password1':ADM_PASSWORD, 'password2':ADM_PASSWORD, 'realm':'public' }
EULA_ARGS = { 'accepted-agreement':ACCEPTED_AGREEMENT }

BOOSTER_XDBC_ARGS = {
        'action':'appserver-create-xdbc',
        'appserver-name':'xdbc-' + BASE_XDBC_PORT,
        'database-name':'Documents',
        'group-name':'Default',
        'modules-name':'Modules',
        'root':'/',
        'port':BASE_XDBC_PORT
}

BOOSTER_HTTP_MAIN_ARGS = {
	'action':'appserver-create-http',
	'appserver-name':'http-' + MAIN_HTTP_PORT,
	'database-name':'Documents',
	'group-name':'Default',
	'modules-name':"Modules",
	'root':'/',   
	'port':MAIN_HTTP_PORT
}

def appserverSetTemplate(servername, setting, value):
    httpProcess("- Updating server "+servername+" by setting '"+setting+"' to '"+value+"'", "booster.xqy", {
	'action':'appserver-set',
	'appserver-name':servername,
 	'group-name':'Default',
	'setting':setting,		# e.g. 'authentication'
	'value':value			# e.g. 'application-level'
     })

def httpProcess(message, url, args = "", debug = False):
    print message
    request = urllib2.Request(BASE_HREF + url)
    if args == "":
        response = urllib2.urlopen(request)
    else:
        response = urllib2.urlopen(request, urllib.urlencode(args))
    if (debug == True):
        data = response.read()
        print data

def configureAuthHttpProcess():
    passman = urllib2.HTTPPasswordMgrWithDefaultRealm()
    passman.add_password(None, BASE_HREF, ADM_UNAME, ADM_PASSWORD)
    authhandler = urllib2.HTTPDigestAuthHandler(passman)
    opener = urllib2.build_opener(authhandler)
    urllib2.install_opener(opener)

def sys(message, cmd):
    print message
    subprocess.call(shlex.split(cmd))
    time.sleep(5)

def checkRootUser():
    if os.geteuid() != 0:
	print "Please execute this script as root!"
	sys.exit(1)

########
# main #
########
checkRootUser()
configureAuthHttpProcess()
sys("0. Using yum to install several useful packages for debugging ML issues", "yum -y install glibc.i686 redhat-lsb pstack sysstat psutils")
sys("1. Downloading ML binary from developer.marklogic.com", "wget " + BINARY_PATH + BINARY_FILENAME)
sys("2. Installing ML from binary", "rpm -i " + BINARY_FILENAME)
sys("3. Starting MarkLogic Instance", "/etc/init.d/MarkLogic start")
httpProcess("4. Configuring licence details", "license-go.xqy", LICENCE_ARGS)
httpProcess("5. Accepting EULA", "agree-go.xqy", EULA_ARGS)
httpProcess("6. Triggering initial application server config", "initialize-go.xqy")
sys("7. Restarting Server", "/etc/init.d/MarkLogic restart")
httpProcess("8. Configuring Admin user (security)", "security-install-go.xqy", SECURITY_ARGS)
httpProcess("9. Testing Admin Connection", "default.xqy")
sys("10. Moving booster to ML Admin", "cp booster-0.2b.xqy /opt/MarkLogic/Admin/booster.xqy")
httpProcess("12. Configuring XDBC Server on port " + BASE_XDBC_PORT, "booster.xqy", BOOSTER_XDBC_ARGS)
sys("11. Cleaning up", "rm " + BINARY_FILENAME)
sys("12. Updating user permissions for home folder(s) where Modules are hosted (+x)", "chmod go+x /home/username")
httpProcess("13. Creating main appserver", "booster.xqy", BOOSTER_HTTP_MAIN_ARGS)
appserverSetTemplate("http-9997", "authentication", "application-level")
appserverSetTemplate("http-9997", "default-user", "admin")

print "Script completed, visit http://localhost:8001 to access the admin interface."
