# -*- coding: utf-8 -*-
"""
Created on Thu Feb  5 17:23:44 2015

@author: dstuckey
"""

import urllib2
from bs4 import BeautifulSoup

count=100
company=""
iterations = 2
baseURL = "http://www.sec.gov/cgi-bin/browse-edgar?CIK=&type=13F&owner=include&action=getcurrent"

def construct13FQueryUrl(iteration=0):
    url = baseURL + "&count=" + str(count) + "&company=" + company + "&start=" + str(count*iteration)
    return url
    
def get13FSoup():
    baseQuery = construct13FQueryUrl()
    baseResponse = urllib2.urlopen(baseQuery)
    baseSoup = BeautifulSoup(baseResponse)
    return baseSoup

def constructInfoTableQuery(shortId, longId):
    return "http://www.sec.gov/Archives/edgar/data/" + shortId + "/" + longId + "/form13fInfoTable.xml"

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

def run():
    baseSoup = get13FSoup()
    infoTableURLs = []
    for i in range(0,iterations):
        curList = constructInfoTableQueryList(baseSoup)
        infoTableURLs += curList
    #dbg:
    print len(infoTableURLs)
    print infoTableURLs[0]
    

