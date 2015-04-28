# -*- coding: utf-8 -*-
"""
Created on Sat Apr 18 23:41:20 2015

@author: Lanhao
"""

stock = ['GIS','KMB','CL','AXP','VNQI','UPS','MDLZ','LLY','HON','NSC','SYY','LOW','MET','DHR','ITW','SO','RTN','PSX','KRFT']
stocks = ['HIW','AEM','IAG','ACM','LPNT','WRB','OFC','BMR','EXR','OHI','CRL','HME','KGC','CMP','DST','MD','OGE','WRI']

from yahoo_finance import Share
import pandas as pd
from pandas import DataFrame
#[{u'Volume': u'28720000', u'Symbol': u'YHOO', u'Adj_Close': u'35.83', u'High': u'35.89', u'Low': u'34.12', u'Date': u'2014-04-29', u'Close': u'35.83', u'Open': u'34.37'}]
start = '2015-1-1'
end = '2015-3-31'

def get_yahoo(sec,start,end):
    target = Share(sec)
    his = target.get_historical(start,end)
    return his 


def get_tuple(his):
    close = [his[1]['Symbol']]
    for x in his:
        close.append(x['Close'])    
    
    closep = tuple(close)
    return closep

def get_date(his):
    tradate = []
    for x in his:
        tradate.append(x['Date'])
    return tradate

allprice = []
for a in stocks: 
    his = get_yahoo(a,start,end)
    closep = get_tuple(his)
    
    allprice.append(closep)

tradate = get_date(his)

columns = ["Names"]

column = columns + tradate

closeprice_lift = pd.DataFrame(data = allprice, columns = column)

closeprice_lift.to_csv('C:\Users\Lanhao\Desktop\closeprice.csv',index = False, header=True)