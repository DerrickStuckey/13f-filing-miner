## Performs clustering on funds based on security holdings

library(arules)

#fund_holdings <- read.csv("~/Desktop/GW/Data Mining/SEC-13F/fund_holdings_v2.csv")
fund_holdings <- read.csv("./fund_holdings_cleaned.csv")

# calculate total value of securities held for each fund
fund_split_values <- split(x=fund_holdings[,"Value"],f=fund_holdings$Fund)
fund_sums <- lapply(fund_split_values, sum)

# calculate size of each fund
log_fund_sums <- lapply(fund_sums, log)
#hist(unlist(log_fund_sums))

# calculate total # of holdings for each fund
fund_num_holdings <- lapply(fund_split_values, length)
log_num_holdings <- lapply(fund_num_holdings, log)
#hist(unlist(log_num_holdings))

# calculate concentration of holdings for each fund
#...

# construct fund data frame
fund_derived_stats <- data.frame("size"=unlist(log_fund_sums),
                                 "num_holdings"=unlist(log_num_holdings))

# plot size vs num holdings
plot(fund_derived_stats$num_holdings, fund_derived_stats$size,
     xlab="log(# holdings)",ylab="log(fund size)",
     main="Fund Size vs. Number of Holdings")

# convert to a matrix
#funds_securities_matrix <- as.matrix(dense_securities_df)
# 
# # try k-means clustering
# k <- 10
# k_means_fit <- kmeans(funds_securities_matrix, k) # 5 cluster solution
# clustered_funds <- data.frame("cluster"=k_means_fit$cluster, dense_securities_df)
# rsq <- k_means_fit$betweenss / k_means_fit$totss
# rsq
# k_means_fit$size
