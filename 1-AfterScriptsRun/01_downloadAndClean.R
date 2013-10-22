# The data.table library is used for fast data manipulations
library(data.table)
library(plyr) # required for mutate()

# TRUE if files need to be downloaded from the internet;
# this should be set to FALSE after the first run.
downloadFiles <- FALSE

# Downloaded data will be stored in this folder.
dataFolder <- "InputData"

# The commodity book lists National Institute of Governmental Purchasing (NIGP) codes.
commodityBookUrl <- "https://cmblreg.cpa.state.tx.us/commodity_book/files/comm_book.csv"
commodityBook <- "comm_book.csv" # this is the name of the local copy of the file

# URL for DC purchase order data; the "YYYY" string must be replaced with a year.
zippedDataUrl <- "http://data.octo.dc.gov/feeds/pass/archive/pass_YYYY_CSV.zip"
years <- c(2010, 2011)

# Download and unzip all files.
if (downloadFiles){
  download.file(commodityBookUrl, paste0(dataFolder, '/', commodityBook))
  for (year in years) {
    fileUrl <- sub("YYYY", year, zippedDataUrl)
    zippedFile <- paste0(dataFolder, '/', basename(fileUrl))
    download.file(fileUrl, zippedFile)
    unzip(zippedFile, exdir=dataFolder)
  }
}

# Read in data files.
nigpCodes <- read.delim(paste0(dataFolder, '/', commodityBook), sep=',')
dcDat2010 <- read.delim(paste0(dataFolder, '/', "pass_2010_CSV.csv"), sep=',')
dcDat2011 <- read.delim(paste0(dataFolder, '/', "pass_2011_CSV.csv"), sep=',')

# Merge data from both years.
dcDat <- rbind(dcDat2010, dcDat2011)

# I'm not interested in the details of where suppliers are located, so I'm
# dropping these columns (while retaining the state of the supplier).
dropColumns <- c("SUPPLIER_FULL_ADDRESS", "SUPPLIER_CITY")
selectedColumns <- !(names(dcDat) %in% dropColumns) # logical index of columns to keep
dcDat <- dcDat[, selectedColumns]

# Convert date strings from a mm/dd/yyyy format to date objects
dcDat$ORDER_DATE <- as.Date(dcDat$ORDER_DATE, format="%m/%d/%Y")
## I originally tried using plyr for this, but applying the date conversion to each
## row individually (as shown below) is unbelievably slow.
#  library(plyr)
#  dcDat <- adply(dcDat, 1, transform, ORDER_DATE=as.Date(ORDER_DATE, format="%m/%d/%Y"))

# The $ symbol in the input files caused monetary values to import as factors instead
# of numeric quantities. This is fixed here.
getNumericCurrency <- function(currencyFactor){
  # Convert the factor to a string, delete dollar signs, then cast to numeric
  return(as.numeric(sub('$', '', as.character(currencyFactor), fixed=TRUE)))
}
dcDat$PO_TOTAL_AMOUNT <- getNumericCurrency(dcDat$PO_TOTAL_AMOUNT)

# The dropLastWord() function drops all the characters that appear after the
# final space in a string. This will be used to parse the NIGP_DESCRIPTION texts.
dropLastWord <- function(phrase){
  phrase <- as.character(phrase)
  phrase <- strsplit(phrase, " ")[[1]]
  return(paste(phrase[1:length(phrase)-1], collapse=" "))
}

# The getLastWord() function returns all the characters that appear after the
# final space in a string.
getLastWord <- function(phrase){
  phrase <- as.character(phrase)
  phrase <- strsplit(phrase, " ")[[1]]
  return(phrase[length(phrase)])
}

# The getPurchaseClass() function gets the category (class) of a purchase given a string
# representing the specific item or service purchased.
getPurchaseClass <- function(NIGP_DESCRIPTION) {
  # convert characters after the last space to a numeric code
  code <- as.numeric(getLastWord(NIGP_DESCRIPTION))
  # the remaining characters are a textual description of the item
  text <- dropLastWord(NIGP_DESCRIPTION)
  
  # try to match the item code and text to an NIGP entry  
  # if there is a match, lookup the description associated with the class code
  matches <- subset(nigpCodes, (code==Item) & grepl(toupper(text), toupper(Description), fixed=TRUE))
  if (nrow(matches) > 0) {
    classCode <- matches[1,"Class"]
    # Generic class labels are listed in the same table as specific items,
    # but the generic classes are all given the item code zero.
    itemClass <- subset(nigpCodes, Class == classCode & Item == 0)[,"Description"]
    # Remove the leading asterisk in front of class names
    itemClass <- sub("^\\*", "", itemClass)
  } else {
    itemClass <- "UNKNOWN"
  }
  return(itemClass)
}

# We need versions of the preceding functions that can operate over lists,
# so the following pair of wrapper functions provide this capability.

list.dropLastWord <- function(phrase){
  sapply(phrase, dropLastWord)
}

list.getPurchaseClass <- function(NIGP_DESCRIPTION){
  sapply(NIGP_DESCRIPTION, getPurchaseClass)
}

# Having established the getPurchaseClass and dropLastWord helper functions,
# we need to take each row of the dataframe, remove the item code from the
# NIGP description, and add a new variable representing the purchase class.
#
# Originally, I tried to do this with plyr. This seemed to work with small data
# frames (such as the disabled test code below that uses the head of dcDat), but
# for the full data set, my computer quickly used up its 8 GB of RAM without
# completing even the first 1000 rows.
#
# This seems wildly inefficient, as my data frames should only be several MB large.
# More importantly, I didn't have the RAM or patience to get results with this method.

#adplyTest <- adply(head(dcDat), 1, transform,
#           PURCHASE_TYPE=getPurchaseClass(NIGP_DESCRIPTION),
#           NIGP_DESCRIPTION=dropLastWord(NIGP_DESCRIPTION))

# As an alternative, I converted my data to a data.table object (using the data.table
# library) and used plyr's mutate function to transform the data.

dcTab <- as.data.table(dcDat)
setkeyv(dcTab, "PO_NUMBER")
dcDat <- as.data.frame(dcTab[,mutate(.SD, PURCHASE_TYPE=list.getPurchaseClass(NIGP_DESCRIPTION),
                                    NIGP_DESCRIPTION=list.dropLastWord(NIGP_DESCRIPTION))])

# Order the data by decreasing value of the purchase orders.
dcDat <- dcDat[with(dcDat, order(-PO_TOTAL_AMOUNT)),]

# Write the painstakingly cleaned data to file
write.table(dcDat, paste0(dataFolder,"/dcPurchases_clean.csv"), sep = ",", row.names = FALSE)