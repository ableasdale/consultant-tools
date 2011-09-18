#!/usr/bin/python
import os
import sys
import urllib
import urllib2
import booster


def main():
    if len(sys.argv) < 4:
        print "Usage: ./create-modules-database.py <server_name (http://localhost:8001)> <modules_database_name> <forest_data_directory>"
        sys.exit(1)

    server_name, database_name, forest_data_directory = sys.argv[1:4]
    forest_name = database_name+"-1"

    booster.configureAuthHttpProcess(server_name, "admin", "admin")
    booster.booster(server_name, { "action":"database-create", "database-name": database_name, "security-db-name": "Security", "schema-db-name": "Schemas" })
    booster.booster(server_name, { "action":"forest-create", "forest-name": forest_name, "host-name": "localhost", "data-directory": forest_data_directory })
    booster.booster(server_name, { "action":"database-attach-forest", "database-name": database_name, "forest-name": forest_name })
    booster.booster(server_name, { "action":"database-set", "database-name": database_name, "setting": "stemmed-searches", "value": "off"})
    booster.booster(server_name, { "action":"database-set", "database-name": database_name, "setting": "fast-phrase-searches", "value": "false"})
    booster.booster(server_name, { "action":"database-set", "database-name": database_name, "setting": "fast-case-sensitive-searches", "value": "false"})
    booster.booster(server_name, { "action":"database-set", "database-name": database_name, "setting": "fast-diacritic-sensitive-searches", "value": "false"})
    booster.booster(server_name, { "action":"database-set", "database-name": database_name, "setting": "fast-element-word-searches", "value": "false"})
    booster.booster(server_name, { "action":"database-set", "database-name": database_name, "setting": "fast-element-phrase-searches", "value": "false"})

if __name__ == "__main__":
    main()

