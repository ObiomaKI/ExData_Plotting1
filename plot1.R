##  Need to load "SQLDF" library as its members are used in data extraction
##  This is done to only select the needed dat and not load all data into
##  computer memory.
## To Run this program, you must have the following packages installed:
## gsubfn
## proto
## RSQLite
## DBI
## RSQLite.extfuns
## tcltk


library(sqldf) ## Load the required Library for sqldf

fname <- file("./proj1/household_power_consumption.txt", open = "r", blocking = FALSE)

## Get the required 2 years of data only -Using SQL will make it possible and
## would allow you to not overwhelm your system limited resource, memory.

sqlQuery <-  "select * from fname where Date in (\"1/2/2007\" , \"2/2/2007\")" 

myData <- sqldf(sqlQuery,
                file.format = list(sep = ";", header = TRUE,                    
                                   colClasses = c("character", "character", "numeric", "numeric", 
                                                  "numeric", "numeric", "numeric", "numeric", "numeric" ))) 


# close file connection
close(fname, type ="r")

## First we convert the column name "Date to lower case date
## to avoid confussion with R Date class data and then
## convert the Date variables to Standard R date
colnames(myData) <- tolower( colnames(myData))

myData$date <- as.Date(myData$date, "%d/%m/%Y")

## Create a datetime Variable

datetime <-   paste(myData$date, myData$time)

## Add the datetime variable as a column to the original extracted file

myData <- cbind(myData, datetime)

# Write the extracted files to disk for inspection
write.csv(myData, file = "household_power_consumption.csv" )

## Here is plot number 1

##Open a png graphic device to store the plot as a 480 X 480 pix image.
png(filename = "./proj1/plot1.png",
    width = 480, height = 480, units = "px", pointsize = 12,
    bg = "white",  res = NA, 
    type = "cairo")

# Plot the first graph (Histogram)
hist(myData$global_active_power, main = "Global Active Power",
     , xlab = "Global Active Power (kilowatts)", col = "red")

# Close the graphic device
dev.off()
