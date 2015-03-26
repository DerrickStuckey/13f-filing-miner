# -*- coding: utf-8 -*-
"""
Created on Tue Nov 11 21:06:50 2014

@author: dstuckey
"""
import pandas as pd
import MySQLdb as myDB
from sqlalchemy import create_engine

mysql_host = "173.194.241.40"
mysql_user = "root"
mysql_pass = "beer"
mysql_db = "sec-filings"

save_dir = "csvs"

### Functions ###
# Function to save a dataframe to CSV
def saveToCsv(df, name):
    df.to_csv(save_dir + '/' + name + '.csv')

def getDBConnect():
    return myDB.connect(host=mysql_host,
                                user=mysql_user,
                                passwd=mysql_pass,
                                db=mysql_db)

# Function to save DataFrame to MySQL database
def saveToDB(df, table, dbConnect, replace=False):
    if (replace):
        action='replace'
    else:
        action='append'
    #clean up any 'NaN' fields which mysql doesn't understand
    dfClean = df.where((pd.notnull(df)), None)
    dfClean.to_sql(con=dbConnect,
                    name=table,
                    if_exists=action,
                    flavor='mysql')

# Missing sqlalchemy.schema module
def readFromDB(table, dbConnect):
    engine = create_engine('mysql+mysqldb://' + mysql_user + ':' + mysql_pass + '@' + mysql_host + '/' + mysql_db)
    
    df = pd.read_sql_table(table, con=engine)
    #clean up SUBJ column
    #df.SUBJ = df.SUBJ.str.strip()
    return df