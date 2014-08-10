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

fname <- file("./household_power_consumption.txt", open = "r", blocking = FALSE)

## Get the required 2 years of data plus the beginning reading of the day after
## 02/02/2007 at time 00:00:00. This is required so that the last X-axis 
## annotation will read 'Sat'

sqlQuery <-  "select * from fname where Date in (\"1/2/2007\" , \"2/2/2007\") OR 
(Date = \"3/2/2007\" and Time = \"00:00:00\")" 

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

## Select the position of all midnights time in our data

pos <- myData$time == "00:00:00"

##  This is the third graph

png(filename = "plot3.png",
    width = 480, height = 480, units = "px", pointsize = 12,
    bg = "white",  res = NA, 
    type = "cairo")

with(myData, {
  plot(x = datetime, y = sub_metering_1, ylim =c(0, max(sub_metering_1)),
       type = "l", xaxt = 'n', ylab = "Energy Sub metering")
  lines(x = datetime, y = sub_metering_1, col = "black")
  lines(x = datetime, y = sub_metering_2, col = "red")
  lines(x = datetime, y = sub_metering_3, col = "blue")
  legend("topright", pch = "-",  col = c("black", "red", "blue"),
         legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), lwd = 1 )
  axis(side = 1, at = datetime[pos], labels = format(strptime(datetime[pos], "%Y-%m-%d %H:%M:%S"), "%a"))
})

# Close the graphic device
dev.off()
