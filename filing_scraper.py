# -*- coding: utf-8 -*-
"""
Created on Thu Feb  5 17:23:44 2015

@author: dstuckey
"""

import urllib2
from bs4 import BeautifulSoup

count=10
company=""
iterations = 2
baseQueryURL = "http://www.sec.gov/cgi-bin/browse-edgar?CIK=&type=13F&owner=include&action=getcurrent"
baseDataURL = "http://www.sec.gov/Archives/edgar/data"

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
    return [constructInfoTableQuery(idDict['shortId'], idDict['longId']) for idDict in idDicts]

def parseXMLInfo(xmlUrl):
    response = urllib2.urlopen(xmlUrl)
    soup = BeautifulSoup(response)
    #Note: BeautifulSoup converts xml tags to all lowercase

    # different documents use different namespaces:
    firstSecurity = soup.find('ns1:nameofissuer') or soup.find('nameofissuer') or soup.find('n1:nameofissuer')
    print firstSecurity

    # not finished ...

#def getInfoTableUrl():


def run():
    baseSoup = get13FSoup()
    # infoTableURLs = []
    # for i in range(0,iterations):
    #     curList = constructInfoTableQueryList(baseSoup)
    #     infoTableURLs += curList
    infoTableURLs = constructInfoTableQueryList(baseSoup)
    #dbg:
    print len(infoTableURLs)
    for url in infoTableURLs[0:10]:
        print "fetching: ", url

    for url in infoTableURLs[0:10]:
        parseXMLInfo(url)
    
run()

#http://www.sec.gov/Archives/edgar/data/1402302/000140230215000003/ge13freport4q2014a1.xml
#http://www.sec.gov/Archives/edgar/data/1402302/000140230215000003/ge13freport4q2014a1.xml