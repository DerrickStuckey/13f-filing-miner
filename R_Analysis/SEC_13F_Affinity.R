## Performs an affinity analysis of securities across investment funds
library(arules)

#fund_holdings <- read.csv("~/Desktop/GW/Data Mining/SEC-13F/fund_holdings_v2.csv")
fund_holdings <- read.csv("./fund_holdings_cleaned.csv")

# Set minimum threshold for security ownership:
min_proportion <- 0.01
fund_split_values <- split(x=fund_holdings[,"Value"],f=fund_holdings$Fund)
fund_sums <- lapply(fund_split_values, sum)
fund_sums_unsplit <- unsplit(fund_sums,f=fund_holdings$Fund)
fund_holdings_2 <- data.frame(fund_holdings,"Fund_Value"=fund_sums_unsplit)
fund_holdings_trimmed <- fund_holdings_2[fund_holdings_2$Value > fund_holdings_2$Fund_Value*min_proportion,]

# rename trimmed dataframe back to original
#fund_holdings <- fund_holdings_trimmed

nrow(fund_holdings)

fund_holdings$Fund <- factor(fund_holdings$Fund)

levels(fund_holdings$Fund)
levels(fund_holdings$Security)

#split into a list of funds
fund_split <- split(x=fund_holdings[,"Security"],f=fund_holdings$Fund)
fund_split <- lapply(fund_split,unique)

#fund_split_2 <- split(x=c(fund_holdings[,"Security"],fund_holdings[,"Value"]),f=fund_holdings$Fund)

#transform to transaction format
transact <- as(fund_split,"transactions")

# check out some item frequencies
#itemFrequency(transact)
itemFrequencyPlot(transact,topN=20)
#itemFrequencyPlot(transact,topN=10,horiz=TRUE)

#only look at subsets of size 2 or less
fund_rules <- apriori(transact,parameter=list(support=.05,confidence=.75,maxlen=2)) 

#view the rules
#inspect(fund_rules)
#inspect(subset(fund_rules, subset=lift > 10)) 

#top 10 rules by lift
inspect(sort(fund_rules, by="lift")[1:10])
