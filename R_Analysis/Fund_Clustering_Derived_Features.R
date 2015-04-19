## Performs clustering on funds based on general derived stats (size,# holdings, etc...)

source("Fund_Derived_Stats.R")

scaled_fund_stats <- fund_derived_stats

# log-transform all values for scaling
scaled_fund_stats$size <- log(scaled_fund_stats$size+1)
scaled_fund_stats$common_holdings <- log(scaled_fund_stats$common_holdings+1)
scaled_fund_stats$option_holdings <- log(scaled_fund_stats$option_holdings+1)
scaled_fund_stats$other_holdings <- log(scaled_fund_stats$other_holdings+1)

# convert to a matrix
funds_stats_matrix <- as.matrix(scaled_fund_stats)

# 
# try k-means clustering
k <- 4
k_means_fit <- kmeans(funds_stats_matrix, k) # 5 cluster solution
clustered_funds <- data.frame("cluster"=k_means_fit$cluster, fund_derived_stats)
rsq <- k_means_fit$betweenss / k_means_fit$totss
rsq
k_means_fit$size

# plot size vs # common holdings
plot(fund_derived_stats$common_holdings, fund_derived_stats$size,
     xlab="log(# holdings)",ylab="log(fund size)",
     main="Fund Size vs. Number of Common Holdings",
     col=k_means_fit$cluster)
legend("topleft", legend = paste("Group", 1:4), pch=1, col=1:4)

# plot # option holdings vs # common holdings
plot(fund_derived_stats$common_holdings, fund_derived_stats$option_holdings,
     xlab="log(# common holdings)",ylab="log(# option holdings)",
     main="# of Option Holdings vs. # of Common Holdings",
     col=k_means_fit$cluster)
legend("topleft", legend = paste("Group", 1:4), pch=1, col=1:4)

# plot # other holdings vs # (common) holdings
plot(fund_derived_stats$common_holdings, fund_derived_stats$other_holdings,
     xlab="log(# common holdings)",ylab="log(# other holdings)",
     main="# of Other Holdings vs. # of Common Holdings",
     col=k_means_fit$cluster)
legend("topleft", legend = paste("Group", 1:4), pch=1, col=1:4)

# plot # option holdings vs # other holdings
plot(fund_derived_stats$other_holdings, fund_derived_stats$option_holdings,
     xlab="log(# other holdings)",ylab="log(# option holdings)",
     main="# of Option Holdings vs. # of Other Holdings",
     col=k_means_fit$cluster)
legend("topleft", legend = paste("Group", 1:4), pch=1, col=1:4)

group_1_funds <- names(k_means_fit$cluster[k_means_fit$cluster==1])
group_1_derived_stats <- fund_derived_stats[k_means_fit$cluster==1,]

write.csv(clustered_funds, "../results/derived_stat_clustering/clustered_funds.csv",
          row.names=TRUE)
