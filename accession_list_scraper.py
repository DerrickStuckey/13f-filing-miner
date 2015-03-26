__author__ = 'dstuckey'

import urllib2
from bs4 import BeautifulSoup

# pandas causing problems upon import
#import pandas as pd
#import MySQLdb as myDB
#from sqlalchemy import create_engine

# class Holding

count=20
company=""
iterations = 2
baseQueryURL = "http://www.sec.gov/cgi-bin/browse-edgar?CIK=&type=13F&owner=include&action=getcurrent"
baseDataURL = "http://www.sec.gov/Archives/edgar/data"

# based on a filing's accession number, builds the index url for that filing
def construct_index_url(accession_num):
    frag1 = accession_num[3:10]
    #print "frag1: ", frag1
    nodashes = accession_num.translate(None, "-")
    #print nodashes
    return baseDataURL + "/" + frag1 + "/" + nodashes + "/" + accession_num + "-index.htm"

# builds url for info table xml file based on short and long id
def constructInfoTableQuery(index_url):
    id_dict = extractIds(index_url)
    shortId = id_dict['shortId']
    longId = id_dict['longId']
    print "shortId: ", shortId
    print "longId: ", longId
    indexUrl = baseDataURL + "/" + str(shortId) + "/" + str(longId)
    #dbg:
    print indexUrl
    indexResponse = urllib2.urlopen(indexUrl)
    indexSoup = BeautifulSoup(indexResponse)

    #find xml link within indexSoup
    allLinks = indexSoup.findAll(name='a')
    # xml_links = []
    #dbg:
    for link in allLinks:
        link_href = str(link['href'])
        if (link_href.lower().endswith('xml') and (not 'primary' in link_href.lower())):
            print link_href
            xml_link = link_href

    # problem: not all documents have an info table link
    return indexUrl + '/' + xml_link

#extracts long and short ids from a url for the index page of a fund's filings
def extractIds(indexLink):
    components = indexLink.split('/')
    dataIdx = components.index('data')
    shortId = components[dataIdx + 1]
    longId = components[dataIdx + 2]
    return {"shortId":shortId,"longId":longId}

# returns a dictionary of holdings w/ 'issuer_names' and 'values'
def parseXMLInfo(xmlUrl):
    response = urllib2.urlopen(xmlUrl)
    soup = BeautifulSoup(response)
    #Note: BeautifulSoup converts xml tags to all lowercase

    # different documents use different namespaces:
    #firstSecurity = soup.find('ns1:nameofissuer') or soup.find('nameofissuer') or soup.find('n1:nameofissuer')
    #print firstSecurity

    #get list of entries
    import re
    entries = soup.findAll(re.compile(".*infotable"))

    print "num entries: ", len(entries)
    issuer_names = []
    values = []

    for entry in entries:
        issuer_name = str(entry.find(re.compile(".*nameofissuer")).text)
        value = str(entry.find(re.compile(".*value")).text)
        issuer_names.append(issuer_name)
        values.append(value)

    entry_dict = {
        'issuer_names' : issuer_names,
        'values' : values
    }

    return entry_dict

# returns a dictionary of holdings w/ 'issuer_names' and 'values'
def get_holdings(accession_num):
    index_url = construct_index_url(accession_num)
    print "index_url: ", index_url
    info_table_url = constructInfoTableQuery(index_url)
    return parseXMLInfo(info_table_url)

# parsed_xml = get_holdings("0001083340-15-000003")
parsed_xml = get_holdings("0001536262-15-000017")
print parsed_xml

#