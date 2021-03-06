# -*- coding: utf-8 -*-
"""
Created on Thu Feb  5 17:23:44 2015

@author: dstuckey
"""

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

def construct_index_url(accession_num):
    frag1 = accession_num[3:10]
    #print "frag1: ", frag1
    nodashes = accession_num.translate(None, "-")
    #print nodashes
    return baseDataURL + "/" + frag1 + "/" + nodashes + "/" + accession_num + "-index.htm"

def construct13FQueryUrl(iteration=0):
    url = baseQueryURL + "&count=" + str(count) + "&company=" + company + "&start=" + str(count*iteration)
    return url
    
def get13FSoup():
    baseQuery = construct13FQueryUrl()
    baseResponse = urllib2.urlopen(baseQuery)
    baseSoup = BeautifulSoup(baseResponse)
    return baseSoup

#works for many records but filename 'form13fInfoTable.xml' not reliable
# def constructInfoTableQuery(shortId, longId):
#     return "http://www.sec.gov/Archives/edgar/data/" + shortId + "/" + longId + "/form13fInfoTable.xml"

def constructInfoTableQuery(shortId, longId):
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

    # incomplete ...

def extractIds(indexLink):
    components = indexLink.split('/')
    dataIdx = components.index('data')
    shortId = components[dataIdx + 1]
    longId = components[dataIdx + 2]
    return {"shortId":shortId,"longId":longId}

def constructInfoTableQueryList(baseSoup):
    indexLinks = baseSoup.findAll(name='a',text='[html]')
    idDicts = [extractIds(str(link['href'])) for link in indexLinks]
    print len(idDicts), " IDs to be queried"
    info_table_urls = []
    for id_dict in idDicts:
        try:
            info_table_url = constructInfoTableQuery(id_dict['shortId'], id_dict['longId'])
            info_table_urls.append(info_table_url)
        except:
            print "no info table found for long id ", id_dict['longId'], ", short id ", id_dict['shortId']
    # return [constructInfoTableQuery(idDict['shortId'], idDict['longId']) for idDict in idDicts]
    return info_table_urls

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

def scrapeInfoTableURLs():
    baseSoup = get13FSoup()
    infoTableURLs = constructInfoTableQueryList(baseSoup)
    return infoTableURLs

def run():
    infoTableURLs = scrapeInfoTableURLs()
    #dbg:
    print len(infoTableURLs)
    for url in infoTableURLs[0:10]:
        print "fetching: ", url

    for url in infoTableURLs[0:10]:
        parseXMLInfo(url)
    
# run()

def run_accession(accession_num):
    index_url = construct_index_url(accession_num)
    print "index_url: ", index_url
    id_dict = extractIds(index_url)
    info_table_url = constructInfoTableQuery(id_dict['shortId'], id_dict['longId'])
    return parseXMLInfo(info_table_url)

parsed_xml = run_accession("0001083340-15-000003")
print parsed_xml

#parseXMLInfo("http://www.sec.gov/Archives/edgar/data/49205/000004920515000018/4Q2011_13F_HR.XML")
# dict =  parseXMLInfo("http://www.sec.gov/Archives/edgar/data/1402302/000140230215000003/ge13freport4q2014a1.xml")

# info_table_urls = scrapeInfoTableURLs()
# print len(info_table_urls), " info tables found"
#
# info_table_url = info_table_urls[15]
#
# print "attempting to parse ", info_table_url
# dict = parseXMLInfo(info_table_url)
#
# print dict['issuer_names'][0:2]
# print dict['values'][0:2]
