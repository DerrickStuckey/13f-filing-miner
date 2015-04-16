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

# Set minimum threshold for security ownership:
min_proportion <- 0.01
fund_holdings_trimmed <- fund_holdings[fund_holdings$Value > fund_holdings$Fund_Value*min_proportion,]

# ***try instead removing securities not held by very many funds***

# reset factor levels for Security field 
fund_holdings_trimmed$Security <- as.factor(as.character(fund_holdings_trimmed$Security))

# calculate relative value for each holding
fund_holdings_trimmed$Rel_Value <- fund_holdings_trimmed$Value / fund_holdings_trimmed$Fund_Value
#hist(fund_holdings_trimmed$Rel_Value,breaks=50,main="Relative Holding Size (all funds)")
# Rel_Value appears exponentially distributed - maybe log-transforming will help?
fund_holdings_trimmed$Log_Rel_Value <- log(fund_holdings_trimmed$Rel_Value)

# reshape data frame to "wide" format (Fund x Security matrix)
library(reshape2)
#funds_securities_values <- fund_holdings_trimmed[,-c(3,4,5)]
funds_securities_values <- data.frame("Fund"=fund_holdings_trimmed$Fund,
                                      "Security"=fund_holdings_trimmed$Security,
                                      "Rel_Value"=fund_holdings_trimmed$Rel_Value)
funds_wide <- dcast(funds_securities_values, Fund ~ Security, value.var="Rel_Value",fun.aggregate=sum,fill=0)
row.names(funds_wide) <- funds_wide$Fund
funds_wide <- funds_wide[,-1]

#convert to a matrix
funds_securities_matrix <- as.matrix(funds_wide)
