## Performs an affinity analysis of securities across investment funds
library(arules)

fund_holdings <- read.csv("~/Desktop/GW/Data Mining/SEC-13F/fund_holdings_wcusip.csv")

# standardize to one Security name per Cusip, using most common security name
#cusip_names <- aggregate(fund_holdings$Security, by=list(Cusip=fund_holdings$Cusip),
#                         FUN=function(x) names(which.max(table(x))))
#names(cusip_names)[names(cusip_names)=='x'] <- "Security"
# *OR* read saved cusip/security name mapping, as aggregation takes a while
cusip_names <- read.csv("~/Desktop/GW/Data Mining/SEC-13F/R_Analysis/cusip_names.csv", stringsAsFactors=FALSE)

# replace all security names w/ most common for that cusip
lookup_security <- function(x) {cusip_names$Security[cusip_names$Cusip==x]}
#fund_holdings$Security <- lapply(fund_holdings$Cusip, lookup_security)
#above should take ~10 minutes

#somehow this worked:
# fund_holdings_by_cusip <- split(x=fund_holdings,f=fund_holdings$Cusip)
# fund_holdings_by_cusip_2 <- lapply(X=fund_holdings_by_cusip,FUN=function(df) {df$Security2 <- lookup_security(df$Cusip[1])})
# fund_holdings_please <- unsplit(fund_holdings_by_cusip_2, f=fund_holdings$Cusip)
# cusip_names_maybe <- fund_holdings_please
# fund_holdings$Security <- cusip_names_maybe

# save fund_holdings after standardizing names
write.csv(fund_holdings, file="fund_holdings_names_std.csv", quote=TRUE, row.names=FALSE)

# consolidate duplicate entries of same security, same fund
fund_holdings_agg <- aggregate(fund_holdings$Value, by=list(Fund=fund_holdings$Fund,Security=fund_holdings$Security,Cusip=fund_holdings$Cusip),FUN=sum)
names(fund_holdings_agg)[names(fund_holdings_agg)=='x'] <- "Value"

# save fund_holdings after cleaning up
write.csv(fund_holdings_agg, file="fund_holdings_cleaned.csv", quote=TRUE, row.names=FALSE)

