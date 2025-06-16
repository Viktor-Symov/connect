#!/usr/bin/python3
import os
import pynetbox
import urllib3
urllib3.disable_warnings()

from sys import argv
#
if __name__ == "__main__":
    if len(argv) == 1:
        print("Usage: nb-resolv <hostname>")
        exit(1)
    hostname = argv[1]
    netbox_url = os.environ.get("NB_URL")
    ro_token = os.environ.get("NB_TOKEN")
    nb = pynetbox.api(netbox_url, token=ro_token)
    nb.http_session.verify = False
    result = nb.dcim.devices.get(name=hostname)
    if result:
          print(str(result.primary_ip).split('/')[0])
