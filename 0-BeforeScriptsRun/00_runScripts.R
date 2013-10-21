# Target outputs
outputs <- c("dcPurchases_clean.csv",
             list.files(pattern = "*.png$"))
file.remove(outputs)

## run the scripts
source("01_downloadAndClean.R")
source("02_visualizePurchases.R")