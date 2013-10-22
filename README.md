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
This is a fairly clean data set, but there are a number of things I wanted to change before analysis. All order dates were given in a mm/dd/yyyy format and I needed that converted to yyyy-mm-dd to be easily converted to a Date object in R (this format also has the benefit of sorting chronologically when sorted alphabetically). In addition to this, I wanted to be able to interpret the type of transactions that were occurring and the main measure of that is the NIGP code. There are over a thousand different NIGP codes in this dataset, so I wanted to summarize these codes into categories; however, the dataset is not very well set up to accomodate that.

In theory, getting categories from NIGP codes should be fairly straightforward, as the codes are supposed to start by a three-digit class code, followed by a two-digit item code (and other optional codes after that). Unfortunately, this dataset doesn't include the three-digit class codes, but instead gives the item-level text and two-digit code. By itself, it's impossible to go from this information to the broader categorical classification, but with a copy of the NIGP code available from http://cmblreg.cpa.state.tx.us/commodity_book/Numeric_index.cfm it is possible to do a reverse-lookup search to find the full commodity code. This mapping is rather non-trivial with R, but the 01-downloadAndClean.R script in this repository is mostly successful in associating purchase orders with their class.

Data Visualization
-------------------
I thought that it would be most interesting to look at the large purchase orders, to see where the biggest deals are happening. In this first figure, the value of the 60 largest purchase orders are shown in descending order with bars coloured by the state in which the supplier for the order is located. This graph served as a helpful sanity check of the data import and processing steps and it also reveals, unsurprisingly, that many of the largest purchase orders are fulfilled by companies within D.C or Virginia.
![The 60 Largest Purchase Orders](https://raw.github.com/MattGingerich/stat545a-2013-hw06_gingerich-mat/master/1-AfterScriptsRun/OutputFigures/01-LargestOrders.png)

This next plot shows the distribution of the total purchase orders given to individual suppliers. The x-axis is logarithmic and the density plot is still skewed heavily towards the low range of values, which implies that there's a relatively small number of purchase orders that are worth far more than the median purchase.
![Distribution of Earnings by Supplier](https://raw.github.com/MattGingerich/stat545a-2013-hw06_gingerich-mat/master/1-AfterScriptsRun/OutputFigures/02-EarningsBySupplier.png)

The next figure plots only the total value of the purchase orders given to the ten suppliers with the highest cumulative earnings from purchase orders. This figure answers some questions about what sort of projects are incurring these expenses, as it shows that healthcare and construction companies have been given orders whose total worth is in the hundreds of millions of dollars. [Skanska-Facchina](http://www.facchina.com/portfolio/index.cfm?portFeatured=current&isFeatured=1), the top-earning supplier on the list with orders worth over half a billion dollars over 2010 and 2011, is a group of companies that works on heavy highway projects.
![10 Biggest Suppliers](https://raw.github.com/MattGingerich/stat545a-2013-hw06_gingerich-mat/master/1-AfterScriptsRun/OutputFigures/03-BiggestSuppliers.png)

Moving away from individual suppliers, we can look at how much was spent on projects in each of the broad NIGP classes. The following figure selects the ten NIGP categories with the highest total expenditures. Health and construction services are still very prominent, but training, management, and consulting services take the largest share of funding.
![Most Expensive NIGP Categories](https://raw.github.com/MattGingerich/stat545a-2013-hw06_gingerich-mat/master/1-AfterScriptsRun/OutputFigures/04-PriciestAreas.png)

Finally, we can check for seasonal purchasing trends. At a glance, it appears that there are some periods (July-November) that have much a much higher volume of purchase orders than others (February-May). It could be interesting to see whether this aligns with any political/fiscal deadlines.
![Most Expensive NIGP Categories](https://raw.github.com/MattGingerich/stat545a-2013-hw06_gingerich-mat/master/1-AfterScriptsRun/OutputFigures/05-PurchasingByMonth.png)

Technical Details
------------------
This project is organized into two folders [0-BeforeScriptsRun](https://github.com/MattGingerich/stat545a-2013-hw06_gingerich-mat/tree/master/0-BeforeScriptsRun) and [1-AfterScriptsRun](https://github.com/MattGingerich/stat545a-2013-hw06_gingerich-mat/tree/master/1-AfterScriptsRun). As their names indicate, the "0-BeforeScriptsRun" and "1-AfterScriptsRun" folders contain snapshots of the project before and after scripts have been run. There is thus a lot of overlap between the content of the two folders, with the only difference being files that are automatically generated by the scripts. The "Before" folder includes a copy of the input data sets in case the web data sets happen to change or become inaccessible. To ignore these local copies of the data and grab the data directly from the source, set the downloadFiles variable at the beginning of the 01-downloadAndClean.R script to TRUE.

Both the pre-processing and data visualization scripts can be run without further intervention by running the 00_runScripts.R script.

Submission Status
---------------------
I may continue to update this repository as there are a couple of things that I'm still trying to get working. The git history can be used to check exactly when files were uploaded, but I'll also make an explicit note of any changes that occur after this commit.

* Update 2013-10-21, 2:30 PM, grammar and phrasing edits to the Readme.
* Update 2013-10-21, 9:40 PM, added figure of purchasing volume over time.
