## Performs clustering on funds based on security holdings

library(arules)

#fund_holdings <- read.csv("~/Desktop/GW/Data Mining/SEC-13F/fund_holdings_v2.csv")
fund_holdings <- read.csv("./fund_holdings_cleaned.csv")

# calculate total value of securities held for each fund
fund_split_values <- split(x=fund_holdings[,"Value"],f=fund_holdings$Fund)
fund_sums <- lapply(fund_split_values, sum)
fund_sums_unsplit <- unsplit(fund_sums,f=fund_holdings$Fund)

# add Fund_Value column to dataframe
fund_holdings <- data.frame(fund_holdings,"Fund_Value"=fund_sums_unsplit)

# calculate relative value for each holding
fund_holdings$Rel_Value <- fund_holdings$Value / fund_holdings$Fund_Value
#hist(fund_holdings_trimmed$Rel_Value,breaks=50,main="Relative Holding Size (all funds)")
# Rel_Value appears exponentially distributed - maybe log-transforming will help?
fund_holdings$Log_Rel_Value <- log(fund_holdings$Rel_Value)

# Set minimum threshold for security ownership:
min_proportion <- 0.01
fund_holdings_trimmed <- fund_holdings[fund_holdings$Rel_Value > min_proportion,]

# ***try instead removing securities not held by very many funds***

# reset factor levels for Security field 
fund_holdings_trimmed$Security <- as.factor(as.character(fund_holdings_trimmed$Security))

# reshape data frame to "wide" format (Fund x Security matrix)
library(reshape2)
#funds_securities_values <- fund_holdings_trimmed[,-c(3,4,5)]
funds_securities_values <- data.frame("Fund"=fund_holdings$Fund,
                                      "Security"=fund_holdings$Security,
                                      "Rel_Value"=fund_holdings$Rel_Value)
funds_wide <- dcast(funds_securities_values, Fund ~ Security, value.var="Rel_Value",
                    fun.aggregate=sum,fill=0)
row.names(funds_wide) <- funds_wide$Fund
funds_wide <- funds_wide[,-1]

# # remove securities only held by a few funds (sparse columns)
# security_counts <- lapply(funds_wide, sum)
# dense_securities_list <- security_counts > 10 #arbitrary number, gets to ~2000 securities
# #summary(dense_securities_list)
# dense_securities_df <- funds_wide[,dense_securities_list]

# remove securities only held by a few funds (sparse columns)
security_sums <- lapply(funds_wide, sum)
dense_securities_list <- security_sums > 0.01 #arbitrary number
#summary(dense_securities_list)
dense_securities_list[is.na(dense_securities_list)] <- FALSE
dense_securities_df <- funds_wide[,dense_securities_list]

# convert to a matrix
funds_securities_matrix <- as.matrix(dense_securities_df)

# try k-means clustering
k <- 10
k_means_fit <- kmeans(funds_securities_matrix, k) # 5 cluster solution
clustered_funds <- data.frame("cluster"=k_means_fit$cluster, dense_securities_df)
rsq <- k_means_fit$betweenss / k_means_fit$totss
rsq
k_means_fit$size

# try k-modes clustering
library(klaR)

# takes quite a while:
k_modes_fit <- kmodes(funds_securities_matrix, k)
mode_clustered_funds <- data.frame("cluster"=k_modes_fit$cluster, dense_securities_df)

# hierarchical clustering

