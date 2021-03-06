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

fname <- file("household_power_consumption.txt", open = "r", blocking = FALSE)

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
datetime <- strptime(datetime, "%Y-%m-%d %H:%M:%S")

myData <- cbind(myData, datetime)

## Select the position of all midnights time in our data

#  -- This is the second graph
png(filename = "plot2.png",
    width = 480, height = 480, units = "px", pointsize = 12,
    bg = "white",  res = NA, 
    type = "cairo")


with(myData, {
  plot(datetime, global_active_power,
       type = "l", xlab = "", ylab = "Global Active Power (kilowatts)")
})

# Close graphics device
dev.off()
