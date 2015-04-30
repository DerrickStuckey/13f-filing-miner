## Calculate some general fund stats based on holding information

#fund_holdings <- read.csv("~/Desktop/GW/Data Mining/SEC-13F/fund_holdings_v2.csv")
#fund_holdings <- read.csv("./fund_holdings_cleaned.csv")
fund_holdings <- read.csv("./fund_holdings_best.csv")

# calculate total value of securities held for each fund
fund_split_values <- split(x=fund_holdings[,"Value"],f=fund_holdings$Fund)
fund_sums <- lapply(fund_split_values, sum)
#log_fund_sums <- log(unlist(fund_sums)+1) #smoothing for log function
#hist(unlist(log_fund_sums), main="Log-transformed Fund Size", xlab="Log(Fund Size)")

# calculate largest holding as a percentage of assets for each fund
largest_holdings <- lapply(fund_split_values, max)
largest_holdings_pct <- unlist(largest_holdings) / unlist(fund_sums)
largest_holdings_pct[is.nan(largest_holdings_pct)] <- 1

# calculate total # of holdings for each fund
#fund_num_holdings <- lapply(fund_split_values, length)
#log_num_holdings <- log(unlist(fund_num_holdings+1)) #smoothing for log function
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

# Plot log-transformed histograms
#log_common_holdings <- log(unlist(fund_common_holdings)+1)
#log_option_holdings <- log(unlist(fund_option_holdings)+1)
#log_other_holdings <- log(unlist(fund_other_holdings)+1)
#hist(log_common_holdings, main="Log-transformed # of Common Holdings", xlab="Log(# Common Holdings)")
#hist(log_option_holdings, breaks=20, main="Log-transformed # of Option Holdings", xlab="Log(# Option Holdings)")
#hist(log_other_holdings, main="Log-transformed # of Other Holdings", xlab="Log(# Other Holdings)")

# calculate concentration of holdings for each fund
#...

# construct fund data frame
fund_derived_stats <- data.frame("size"=unlist(fund_sums),
                                 "common_holdings"=unlist(fund_common_holdings),
                                 "other_holdings"=unlist(fund_other_holdings),
                                 "option_holdings"=unlist(fund_option_holdings),
                                 "largest_holding_prop"=largest_holdings_pct)

write.csv(fund_derived_stats, "fund_derived_stats.csv", row.names=TRUE)
