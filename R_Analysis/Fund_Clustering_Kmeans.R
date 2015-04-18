## Performs clustering on funds based on security holdings

# get fund_security_matrix
source("Fund_Security_Matrix.R")

#try adding fund size, # holdings
source("Fund_Derived_Stats.R")
#dense_securities_df <- cbind("Num_Holdings"=unlist(log_num_holdings), dense_securities_df)
#dense_securities_df <- cbind("Fund_Size"=unlist(log_fund_sums), dense_securities_df)
#dense_securities_df <- cbind(fund_derived_stats, dense_securities_df)

fund_security_matrix <- cbind(fund_derived_stats, fund_security_matrix)

# scale the matrix
fund_security_matrix <- scale(fund_security_matrix)
# weight fund size, # holdings higher
fund_security_matrix[,'size'] <- 3*fund_security_matrix[,'size']
fund_security_matrix[,'num_holdings'] <- 3*fund_security_matrix[,'num_holdings']

# try k-means clustering
k <- 5
k_means_fit <- kmeans(fund_security_matrix, k) # 5 cluster solution
#clustered_funds <- data.frame("cluster"=k_means_fit$cluster, dense_securities_df)
clusters <- k_means_fit$cluster
rsq <- k_means_fit$betweenss / k_means_fit$totss
rsq
k_means_fit$size

write.csv(clusters,"kmeans_clusters_k5.csv",row.names=TRUE)
