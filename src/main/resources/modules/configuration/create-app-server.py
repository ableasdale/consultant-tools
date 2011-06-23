#!/usr/bin/python
import os
import sys
import urllib
import urllib2
import booster

def main():
    if len(sys.argv) < 5:
        print "Usage: ./create-app-server.py <server_name (http://localhost:8001)> <documents_database_name> <modules_database_name> <app_server_port>"
        print "Documents and Modules databases will not be created - you need to have done that already"
        sys.exit(1)

    server_name, database_name, modules_name, port= sys.argv[1:5]
    appserver_name = "http-" + port

    booster.configureAuthHttpProcess(server_name, "admin", "admin")

    booster.booster(server_name, { "action":"appserver-create-http", "group-name":"Default", "root": "/", "database-name": database_name,
                                   "modules-name": modules_name, "appserver-name": appserver_name, "port": port  })
    booster.booster(server_name, { "action":"appserver-set", "appserver-name": appserver_name, "group-name": "Default",  "setting": "authentication", "value": "application-level"})
    booster.booster(server_name, { "action":"appserver-set", "appserver-name": appserver_name, "group-name": "Default",  "setting": "default-user", "value": "admin"})

if __name__ == "__main__":
    main()

