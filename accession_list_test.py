__author__ = 'dstuckey'

test_num = "0001083340-15-000003"

base_url = "http://www.sec.gov/Archives/edgar/data/"

def construct_index_url(accession_num):
    frag1 = accession_num[3:10]
    #print "frag1: ", frag1
    nodashes = accession_num.translate(None, "-")
    #print nodashes
    return base_url + frag1 + "/" + nodashes + "/" + accession_num + "-index.htm"

print construct_index_url(test_num)