## Analysis of price correlation of securities w/ high affinity

library(reshape2)

#load price data
top_lift_prices <- read.csv("~/Desktop/GW/Data Mining/SEC-13F/top_lift_prices.csv")

#throw out date column
top_lift_prices <- top_lift_prices[,-1]

#create difference series
top_lift_prices_today <- top_lift_prices[1:nrow(top_lift_prices)-1,]
top_lift_prices_tomorrow <- top_lift_prices[2:nrow(top_lift_prices),]
price_diffs <- top_lift_prices_tomorrow - top_lift_prices_today

#find correlation between price moves for each pair of securities
price_corrs <- cor(price_diffs)

#load affinity data
affinity_matrix <- read.csv("~/Desktop/GW/Data Mining/SEC-13F/top_lift_matrix.csv")

#make first column to row names
row.names(affinity_matrix) <- affinity_matrix$Security
#remove first column and cast to a matrix
affinity_matrix <- affinity_matrix[,-1]
affinity_matrix <- as.matrix(affinity_matrix)

#melt both data frames
melted_corrs <- melt(price_corrs, varnames=c("Sec1","Sec2"))
melted_affinity <- melt(affinity_matrix, varnames=c("Sec1","Sec2"))

#combine (should use 'merge' but this works)
corr_affinity <- data.frame("Sec1"=melted_corrs$Sec1,
                            "Sec2"=melted_corrs$Sec2,
                            "Corr"=melted_corrs$value,"Affinity"=melted_affinity$value)
corr_affinity_dedup <- corr_affinity[as.character(corr_affinity$Sec1) 
                                     < as.character(corr_affinity$Sec2),]

linear_fit <- lm(Corr ~ Affinity, data=corr_affinity_dedup)

#box-whisker plot
corr_affinity_dedup_fa <- as.factor(as.logical(corr_affinity_dedup$Affinity))
plot(corr_affinity_dedup_fa, corr_affinity_dedup$Corr,main="Price Correlation vs Affinity (Top Lift Rules)", ylab="Price Correlation",xlab="Affinity")

# t-test
no_affinity_corrs <- corr_affinity_dedup$Corr[corr_affinity_dedup$Affinity==0]
affinity_corrs <- corr_affinity_dedup$Corr[corr_affinity_dedup$Affinity==1]
t_results <- t.test(no_affinity_corrs, affinity_corrs)
t_results
