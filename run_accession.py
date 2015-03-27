__author__ = 'dstuckey'

import accession_list_scraper as acc
import csv

# read all funds names, accession numbers from csv
funds_acc_nums = []
with open("text_formatting/formatted_filings.csv") as inputcsv:
    reader = csv.reader(inputcsv, delimiter=',', quotechar='"')
    next(reader) #skip header
    for row in reader:
        funds_acc_nums.append((row[0],row[3]))

print "funds_acc_nums[0]: ", funds_acc_nums[0]

# dict to hold funds and their holdings
funds = {}

# iterate through a list of accession ids and build a dictionary of funds and their holdings
# for (fund, accession_num) in [("GAMBLE JONES INVESTMENT COUNSEL", "0001536262-15-000017"), ("B.S. PENSION FUND TRUSTEE LTD ACTING FOR THE BRITISH STEEL PENSION FUND", "0001083340-15-000003")]:
for (fund,accession_num) in funds_acc_nums:
    try:
        holdings = acc.get_holdings(accession_num)
        funds[fund] = holdings
    except:
        print "ERROR: unable to get holdings for ", fund

#dbg:
# print "Gamble: ", funds["GAMBLE JONES INVESTMENT COUNSEL"]
# print "BS Pension: ", funds["B.S. PENSION FUND TRUSTEE LTD ACTING FOR THE BRITISH STEEL PENSION FUND"]

# write all fund holdiing info to a CSV
with open("fund_holdings_test.csv", 'wb') as csvfile:
    writer = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    writer.writerow(['Fund', 'Security','Value'])
    for key in funds.keys():
        fund = funds[key]
        tuples = zip(fund['issuer_names'],fund['values'])
        for (security, value) in tuples:
            writer.writerow([key,security,value])