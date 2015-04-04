## Performs an affinity analysis of securities across investment funds
library(arules)

fund_holdings <- read.csv("~/Desktop/GW/Data Mining/SEC-13F/fund_holdings_v2.csv")

# With no minimum threshold for security ownership: 
fund_holdings <- fund_holdings[,1:2]

nrow(fund_holdings)

fund_holdings$Fund <- factor(fund_holdings$Fund)

levels(fund_holdings$Fund)
levels(fund_holdings$Security)

#split into a list of funds
fund_split <- split(x=fund_holdings[,"Security"],f=fund_holdings$Fund)
fund_split <- lapply(fund_split,unique)

#transform to transaction format
transact <- as(fund_split,"transactions")

# check out some item frequencies
#itemFrequency(transact)
itemFrequencyPlot(transact,topN=20)
#itemFrequencyPlot(transact,topN=10,horiz=TRUE)

#only look at subsets of size 2 or less
fund_rules <- apriori(transact,parameter=list(support=.10,confidence=.75,maxlen=2)) 

#view the rules
inspect(fund_rules)
inspect(subset(fund_rules, subset=lift > 5)) 
