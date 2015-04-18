## Calculate some general fund stats based on holding information

#fund_holdings <- read.csv("~/Desktop/GW/Data Mining/SEC-13F/fund_holdings_v2.csv")
fund_holdings <- read.csv("./fund_holdings_cleaned.csv")

# calculate total value of securities held for each fund
fund_split_values <- split(x=fund_holdings[,"Value"],f=fund_holdings$Fund)
fund_sums <- lapply(fund_split_values, sum)
log_fund_sums <- lapply(fund_sums, function(x) {log(x+1)}) #smoothing for log function
#hist(unlist(log_fund_sums))

# calculate total # of holdings for each fund
fund_num_holdings <- lapply(fund_split_values, length)
log_num_holdings <- lapply(fund_num_holdings, function(x) {log(x+1)}) #smoothing for log function
#hist(unlist(log_num_holdings))

# calculate concentration of holdings for each fund
#...

# construct fund data frame
fund_derived_stats <- data.frame("size"=unlist(log_fund_sums),
                                 "num_holdings"=unlist(log_num_holdings))

