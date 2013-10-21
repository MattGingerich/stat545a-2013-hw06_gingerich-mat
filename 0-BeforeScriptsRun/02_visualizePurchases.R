library(ggplot2)
library(scales)
library(RColorBrewer)
library(plyr)

# Loading in the clean data
dataFolder <- "InputData"
figureFolder <- "OutputFigures"
dcDat <- read.delim(paste0(dataFolder, '/', "dcPurchases_clean.csv"), sep=',')
dcDat$ORDER_DATE <- as.Date(dcDat$ORDER_DATE)

# Plotting the largest purchase orders, arranged by size, and coloured by the state of the supplier
brewColors <- brewer.pal(n = 9, name = "Set1")
n <- 60
p <- ggplot(head(dcDat, n),
            aes(x = reorder(PO_NUMBER, -PO_TOTAL_AMOUNT),
                y = PO_TOTAL_AMOUNT,
                fill=SUPPLIER_STATE))
p <- p + theme(axis.text.x = element_blank())
p <- p + ylab("Purchase Order Value (USD)")
p <- p + xlab("Purchase Order")
p <- p + geom_bar(stat="identity", position="dodge")
p <- p + scale_fill_manual(name="Supplier's State", values=brewColors)
p <- p + scale_y_log10(labels = trans_format("log10", math_format(10^.x)))
p <- p + coord_fixed(5)
p <- p + ggtitle(paste("The", n, "Largest Purchase Orders in 2010-2011"))
print(p)
ggsave(file.path(figureFolder, "01-LargestOrders.png"))

# Visualize the amount earned by suppliers with a density plot
sDat <- ddply(dcDat, ~SUPPLIER, summarize, total=sum(PO_TOTAL_AMOUNT))
sDat <- sDat[with(sDat, order(-total)), ]
p <- ggplot(sDat, aes(x = total))
p <- p + geom_density()
p <- p + scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                       labels = trans_format("log10", math_format(10^.x)))
p <- p + xlab("Total Earnings of Supplier (USD)")
p <- p + ggtitle(paste("Density Plot of the Total Amount Paid to\nIndividual Suppliers in 2010-2011"))
print(p)
ggsave(file.path(figureFolder, "02-EarningsBySupplier.png"))

# Find the largest suppliers
n <- 10
p <- ggplot(head(sDat, n),
            aes(x = reorder(SUPPLIER, -total),
                y = total))
p <- p + xlab("Supplier")
p <- p + ylab("Purchase Order Value (USD)")
p <- p + geom_bar(stat="identity", position="dodge")
p <- p + scale_fill_manual(name="Supplier's State", values=brewColors)
p <- p + scale_y_log10(labels = trans_format("log10", math_format(10^.x)))
p <- p + coord_flip()
p <- p + ggtitle(paste("The", n, "Largest Suppliers\nby Total Earnings in 2010-2011"))
print(p)
ggsave(file.path(figureFolder, "03-BiggestSuppliers.png"))

# Plot the amount of money spent by category
cDat <- ddply(subset(dcDat, PURCHASE_TYPE!="UNKNOWN"),
              ~PURCHASE_TYPE, summarize,
              total=sum(PO_TOTAL_AMOUNT))
cDat <- cDat[with(cDat, order(-total)), ]
# Remove parentheticals from categories for more concise labels
cDat$PURCHASE_TYPE <- sub("\\(.*\\)", "", cDat$PURCHASE_TYPE)
p <- ggplot(head(cDat, n),
            aes(x = reorder(PURCHASE_TYPE, -total),
                y = total))
p <- p + xlab("Expense Category")
p <- p + ylab("Total Purchase Order Value (USD)")
p <- p + geom_bar(stat="identity", position="dodge")
p <- p + scale_fill_manual(name="Supplier's State", values=brewColors)
p <- p + scale_y_log10(labels = trans_format("log10", math_format(10^.x)))
p <- p + coord_flip()
p <- p + ggtitle(paste("The", n, "Most Expensive Purchase Order Categories in 2010-2011"))
print(p)
ggsave(file.path(figureFolder, "04-PriciestAreas.png"))