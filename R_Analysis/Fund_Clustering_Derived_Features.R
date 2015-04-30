## Performs clustering on funds based on general derived stats (size,# holdings, etc...)

source("Fund_Derived_Stats.R")

scaled_fund_stats <- fund_derived_stats

# log-transform all values for scaling
scaled_fund_stats$size <- log(scaled_fund_stats$size+1)
scaled_fund_stats$common_holdings <- log(scaled_fund_stats$common_holdings+1)
scaled_fund_stats$option_holdings <- log(scaled_fund_stats$option_holdings+1)
#scaled_fund_stats$other_holdings <- log(scaled_fund_stats$other_holdings+1)

#remove other holdings column
scaled_fund_stats <- scaled_fund_stats[,-3]

# convert to a matrix
funds_stats_matrix <- as.matrix(scaled_fund_stats)
funds_stats_matrix <- scale(funds_stats_matrix)

# try with several values of k, get and plot r-sq vs k 
get_rsq <- function(k) {
  kmeans_fit <- kmeans(funds_stats_matrix, centers=k)
  rsq <- kmeans_fit$betweenss / kmeans_fit$totss
  return(rsq)
}

get_avg_rsq <- function(k) {
  trial_ks <- rep(k,5)
  trial_rsq <- lapply(trial_ks,get_rsq)
  avg_rsq <- mean(unlist(trial_rsq))
}

k_vals <- c(2,3,4,5,6,7,8,9)
rsq_vals <- lapply(k_vals, get_avg_rsq)

# plot rsq vs k
plot(k_vals, rsq_vals, xlab="k", ylab="R-squared", main="K-means Performance by # of Clusters", col="blue")

# k-means clustering with k=4
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
legend("topleft", legend = paste(1:4), pch=1, col=1:4)

# plot # option holdings vs # common holdings
plot(scaled_fund_stats$common_holdings, scaled_fund_stats$option_holdings,
     xlab="log(# common holdings)",ylab="log(# option holdings)",
     main="# of Option Holdings vs. # of Common Holdings",
     col=k_means_fit$cluster)
legend("topleft", legend = paste(1:4), pch=1, col=1:4)

# plot largest holdings vs # (common) holdings
plot(scaled_fund_stats$common_holdings, scaled_fund_stats$largest_holding_prop,
     xlab="log(# common holdings)",ylab="size of largest holding",
     main="Size of Largest Holding vs. # of Common Holdings",
     col=k_means_fit$cluster)
legend("topright", legend = paste(1:4), pch=1, col=1:4)

# plot # option holdings vs largest holding
plot(scaled_fund_stats$option_holdings, scaled_fund_stats$largest_holding_prop, 
     xlab="log(# option holdings)",ylab="size of largest holding",
     main="Size of Largest Holding vs. # of Option Holdings",
     col=k_means_fit$cluster)
legend("topright", legend = paste(1:4), pch=1, col=1:4)

# plot # option holdings vs largest holding
plot(scaled_fund_stats$largest_holding_prop, scaled_fund_stats$option_holdings, 
     xlab="size of largest holding",ylab="log(# option holdings)",
     main="# of Option Holdings vs. Size of Largest Holding",
     col=k_means_fit$cluster)
legend("topright", legend = paste(1:4), pch=1, col=1:4)

# plot size of largest holding vs fund size
plot(scaled_fund_stats$size, scaled_fund_stats$largest_holding_prop, 
     xlab="log(fund size)",ylab="size of largest holding",
     main="Size of Largest Holding vs. Fund Size",
     col=k_means_fit$cluster)
legend("bottomleft", legend = paste(1:4), pch=1, col=1:4)

group_1_funds <- names(k_means_fit$cluster[k_means_fit$cluster==1])
group_1_derived_stats <- fund_derived_stats[k_means_fit$cluster==1,]

write.csv(clustered_funds, "../results/derived_stat_clustering/clustered_funds.csv",
          row.names=TRUE)
