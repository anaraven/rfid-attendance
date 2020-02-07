#!/usr/local/bin/python3

# Open "DevTools -> Network in chrome"
# Open student list in AKSIS
# copy the line about "GetDersiAlanOgrenciler" in cURL format. This is a json file
# (this line also includes the COOKIE)
# parse the json file with this program

import json
import sys

for fname in sys.argv[1:]:
    x = open(fname, "r").readlines()
    y = json.loads(''.join(x))
    for z in y["Data"]:
        print("{Numara}\t{Ad}\t{Soyad}\t{FKKisiID}\t{ogrKimlikID}\t{CID}\t{DevamZorunluluguString}".format_map(z))

# pipe the output to
# awk -vCOOKIE="Cookie" -f ~/Web/blog/_code/attendance/get_html.awk | sh
# (it should only be for the missing files)
# then process each file with something like
# ls -tr HTML/*html |tail -37 |xargs -n 1 awk -vCOOKIE="Cookie" -f ~/Web/blog/_code/attendance/get_jpeg.awk
