stat545a-2013-hw06_gingerich-mat
================================

This project contains code for exploring the public listing of past purchase orders made by the District of Columbia. The purchase order data set is available from http://data.dc.gov and the scripts contained within this project are able to download and extract data directly from this source (this is, in fact, one of the main reasons I chose to work with this data set instead of the one I had used for homework 5, since that previous data set required a license to access).

As a condition of using this dataset, I need to provide you with the following disclaimer:

The data made available here has been modified for use from its original source, which is the Government of the District of Columbia. Neither the District of Columbia Government nor the Office of the Chief Technology Officer (OCTO) makes any claims as to the completeness, accuracy or content of any data contained in this application; makes any representation of any kind, including, but not limited to, warranty of the accuracy or fitness for a particular use; nor are any such warranties to be implied or inferred with respect to the information or data furnished herein. The data is subject to change as modifications and updates are complete. It is understood that the information contained in the dataset is being used at one's own risk.

Dataset Details
------------------
The Purchase Order data set lists purchases made by the city of Washington, D.C. The data is supplied in comma-separated value (CSV) format, and contains the following attributes (the official description of this data can be found [here](http://data.dc.gov/Metadata.aspx?id=20)):
* PO NUMBER: Purchase Order Number
* NIGP CODE DESCRIPTION: National Institute of Government Purchasing Commodity Code description
* PO TOTAL AMOUNT: Cost of the purchase
* ORDER DATE: Date of the purchase order
* SUPPLIER: Supplier business name
* SUPPLIER FULL ADDRESS: Supplier business address
* SUPPLIER CITY: Supplier's city
* SUPPLIER STATE: Supplier's state

Data Pre-processing
---------------------
This is a fairly clean data set, but there are a number of things I wanted to change before analysis. All order date's were given in a mm/dd/yyyy format and I needed that converted to yyyy-mm-dd to be easily converted to a Date object in R (this format also has the benefit of sorting chronologically when sorted alphabetically). In addition to this, I wanted to be able to interpret the type of transactions that were occurring and the main measure of that is the NIGP code. There are over a thousand different NIGP codes in this dataset, so I wanted to summarize these codes into categories; however, the dataset is not very well set up to accomodate that.

In theory, getting categories from NIGP codes should be fairly straightforward, as the codes are supposed to start by a three-digit class code, followed by a two-digit item code (and other optional codes after that). Unfortunately, this dataset doesn't include the three-digit class codes, but instead gives the item-level text and two-digit code. By itself, it's impossible to go from this information to the broader categorical classification, but with a copy of the NIGP code available from http://cmblreg.cpa.state.tx.us/commodity_book/Numeric_index.cfm it is possible to do a reverse-lookup search to find the full commodity code. The 01-downloadAndClean.R script in this repository is mostly successful in doing this task, though it's not able to match 100% of the codes.

Data Visualization
-------------------
![The 60 Largest Purchase Orders](https://raw.github.com/MattGingerich/stat545a-2013-hw06_gingerich-mat/master/1-AfterScriptsRun/OutputFigures/01-LargestOrders.png)
![Distribution of Earnings by Supplier](https://raw.github.com/MattGingerich/stat545a-2013-hw06_gingerich-mat/master/1-AfterScriptsRun/OutputFigures/02-EarningsBySupplier.png)
![10 Biggest Suppliers](https://raw.github.com/MattGingerich/stat545a-2013-hw06_gingerich-mat/master/1-AfterScriptsRun/OutputFigures/03-BiggestSuppliers.png)
![Most Expensive NIGP Categories](https://raw.github.com/MattGingerich/stat545a-2013-hw06_gingerich-mat/master/1-AfterScriptsRun/OutputFigures/04-PriciestAreas.png)
