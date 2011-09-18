#!/usr/bin/python
import os
import sys
import urllib
import urllib2

def configureAuthHttpProcess(server_name, uname, password):
    passman = urllib2.HTTPPasswordMgrWithDefaultRealm()
    passman.add_password(None, server_name, uname, password)
    authhandler = urllib2.HTTPDigestAuthHandler(passman)
    opener = urllib2.build_opener(authhandler)
    urllib2.install_opener(opener)

def booster(server_name, args = ""):
    request = urllib2.Request(server_name + "/booster.xqy")
    if args == "":
        response = urllib2.urlopen(request)
    else:
        response = urllib2.urlopen(request, urllib.urlencode(args))
