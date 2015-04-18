## Performs clustering on funds based on general derived stats (size,# holdings, etc...)

source("Fund_Derived_Stats.R")

# save fund data frame
#write.csv(fund_derived_stats, "fund_derived_stats.csv", row.names=TRUE)

# plot size vs num holdings
plot(fund_derived_stats$num_holdings, fund_derived_stats$size,
     xlab="log(# holdings)",ylab="log(fund size)",
     main="Fund Size vs. Number of Holdings")

# convert to a matrix
funds_stats_matrix <- as.matrix(fund_derived_stats)
# 
# try k-means clustering
k <- 4
k_means_fit <- kmeans(funds_stats_matrix, k) # 5 cluster solution
clustered_funds <- data.frame("cluster"=k_means_fit$cluster, fund_derived_stats)
rsq <- k_means_fit$betweenss / k_means_fit$totss
rsq
k_means_fit$size
