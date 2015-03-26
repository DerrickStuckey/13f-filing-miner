__author__ = 'dstuckey'

import csv

filings = []
last_fund = "unknown"

# with open("DCLatLon.txt", 'rb') as csvfile:
with open("egf2.csv", 'rb') as csvfile:
    reader = csv.reader(csvfile, delimiter=',', quotechar='"')
    for row in reader:
       fund = row[0]
       if ("13F" in fund):
           fund = last_fund
       else:
           last_fund = fund
       file_date = row[1]
       size = row[2]
       accession_num = row[3]
       filings.append([fund, file_date, size, accession_num])

print filings[0]
print filings[1]
print filings[2]

with open("formatted_filings.csv", 'wb') as csvfile:
    writer = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    writer.writerow(['Fund', 'Date', 'Size', 'Accession_Number'])
    for filing in filings:
        writer.writerow(filing)