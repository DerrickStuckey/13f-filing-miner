## Calculate some general fund stats based on holding information

#fund_holdings <- read.csv("~/Desktop/GW/Data Mining/SEC-13F/fund_holdings_v2.csv")
#fund_holdings <- read.csv("./fund_holdings_cleaned.csv")
fund_holdings <- read.csv("./fund_holdings_best.csv")

# calculate total value of securities held for each fund
fund_split_values <- split(x=fund_holdings[,"Value"],f=fund_holdings$Fund)
fund_sums <- lapply(fund_split_values, sum)
log_fund_sums <- log(unlist(fund_sums)+1) #smoothing for log function
#hist(unlist(log_fund_sums))

# calculate total # of holdings for each fund
fund_num_holdings <- lapply(fund_split_values, length)
log_num_holdings <- log(unlist(fund_num_holdings+1)) #smoothing for log function
#hist(unlist(log_num_holdings))

# calculate # of various position types for each fund
fund_split_positions <- split(x=fund_holdings[,"Position_Type"],f=fund_holdings$Fund)
fund_common_holdings <- lapply(fund_split_positions, 
                               function(x) {
                                 sum(x=="common")
                               })
fund_option_holdings <- lapply(fund_split_positions,
                               function(x) {
                                 sum(is.element(x, c("call","put")))
                               })
fund_other_holdings <- lapply(fund_split_positions,
                               function(x) {
                                 sum(x=="other")
                               })

# take log value of each count (w/ add-one smoothing)
log_common_holdings <- log(unlist(fund_common_holdings)+1)
log_option_holdings <- log(unlist(fund_option_holdings)+1)
log_other_holdings <- log(unlist(fund_other_holdings)+1)

# calculate concentration of holdings for each fund
#...

# construct fund data frame
fund_derived_stats <- data.frame("size"=log_fund_sums,
                                 "common_holdings"=log_common_holdings,
                                 "other_holdings"=log_other_holdings,
                                 "option_holdings"=log_option_holdings)

