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

# # try with several values of k, get and plot r-sq vs k 
# get_rsq <- function(k) {
#   kmeans_fit <- kmeans(funds_stats_matrix, centers=k)
#   rsq <- kmeans_fit$betweenss / kmeans_fit$totss
#   return(rsq)
# }
# 
# get_avg_rsq <- function(k) {
#   trial_ks <- rep(k,5)
#   trial_rsq <- lapply(trial_ks,get_rsq)
#   avg_rsq <- mean(unlist(trial_rsq))
# }
# 
# k_vals <- c(2,3,4,5,6,7,8,9)
# rsq_vals <- lapply(k_vals, get_avg_rsq)
# 
# # plot rsq vs k
# plot(k_vals, rsq_vals, xlab="k", ylab="R-squared", main="K-means Performance by # of Clusters", col="blue")

# k-means clustering ith k=4
k <- 4
k_means_fit <- kmeans(funds_stats_matrix, k)
clustered_funds <- data.frame("cluster"=k_means_fit$cluster, fund_derived_stats)
rsq <- k_means_fit$betweenss / k_means_fit$totss
rsq
k_means_fit$size

# plot size vs # common holdings
plot(scaled_fund_stats$common_holdings, scaled_fund_stats$size,
     xlab="log(# holdings)",ylab="log(fund size)",
     main="Fund Size vs. Number of Common Holdings",
     col=k_means_fit$cluster)
legend("topleft", legend = paste("Group", 1:4), pch=1, col=1:4)

# plot # option holdings vs # common holdings
plot(scaled_fund_stats$common_holdings, scaled_fund_stats$option_holdings,
     xlab="log(# common holdings)",ylab="log(# option holdings)",
     main="# of Option Holdings vs. # of Common Holdings",
     col=k_means_fit$cluster)
legend("topleft", legend = paste("Group", 1:4), pch=1, col=1:4)

# plot # other holdings vs # (common) holdings
plot(scaled_fund_stats$common_holdings, scaled_fund_stats$other_holdings,
     xlab="log(# common holdings)",ylab="log(# other holdings)",
     main="# of Other Holdings vs. # of Common Holdings",
     col=k_means_fit$cluster)
legend("topleft", legend = paste("Group", 1:4), pch=1, col=1:4)

# plot # option holdings vs # other holdings
plot(scaled_fund_stats$other_holdings, scaled_fund_stats$option_holdings,
     xlab="log(# other holdings)",ylab="log(# option holdings)",
     main="# of Option Holdings vs. # of Other Holdings",
     col=k_means_fit$cluster)
legend("topleft", legend = paste("Group", 1:4), pch=1, col=1:4)

group_1_funds <- names(k_means_fit$cluster[k_means_fit$cluster==1])
group_1_derived_stats <- fund_derived_stats[k_means_fit$cluster==1,]

write.csv(clustered_funds, "../results/derived_stat_clustering/clustered_funds.csv",
          row.names=TRUE)
