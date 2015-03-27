__author__ = 'dstuckey'

import accession_list_scraper as acc

index_url = "http://www.sec.gov/Archives/edgar/data/1140361/000114036115007461/0001140361-15-007461-index.htm"
info_table_url = acc.constructInfoTableQuery(index_url)

print "info_table_url: ", info_table_url