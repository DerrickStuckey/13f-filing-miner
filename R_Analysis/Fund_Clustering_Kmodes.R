## Performs clustering on funds based on security holdings

# get fund_security_matrix
source("Fund_Security_Matrix.R")

# k-modes clustering
library(klaR)

# takes quite a while:
k_modes_fit <- kmodes(fund_security_matrix, k)
#mode_clustered_funds <- data.frame("cluster"=k_modes_fit$cluster, dense_securities_df)
clusters <- k_modes_fit$cluster
k_modes_fit$size

