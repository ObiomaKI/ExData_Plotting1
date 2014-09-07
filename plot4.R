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
## NOTE: make sure that your sample data and your R code is in the same directory.


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

# This is the combined plots

png(filename = "plot4.png",
    width = 480, height = 480, units = "px", pointsize = 12,
    bg = "white",  res = NA, 
    type = "cairo")

par(mfrow = c(2,2))

## Use bty = 'n' to remove the border around legend
with(myData, { 
  plot(x = datetime, 
       y = global_active_power,
       ylim =c(0, max(global_active_power)),
       type = "l", 
       ylab = "Global Active Power")
  points(x = datetime, y = global_active_power, type = "l") 
 
  plot(x = datetime,
       y = voltage,
       ylim =c(min(voltage), max(voltage)), type = "l", 
       ylab = "Voltage",
       xlab = "datetime")
  lines(x = datetime, y = voltage, type = "l") 

  plot(x = datetime,
       y = sub_metering_1,
       ylim =c(0, max(sub_metering_1)),
       type = "l",
       ylab = "Energy Sub metering")
  lines(x = datetime, y = sub_metering_1, col = "black")
  lines(x = datetime, y = sub_metering_2, col = "red")
  lines(x = datetime, y = sub_metering_3, col = "blue")
  legend("topright", pch = "-",  col = c("black", "red", "blue"),
  legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), lwd = 1, bty = "n", cex = 0.95 )

  plot(x = datetime,
       y = global_reactive_power,
       ylim =c(min(global_reactive_power), max(global_reactive_power)),
       type = "l", 
       ylab = "Global_reactive_power",
       xlab = "datetime")
  lines(x = datetime, y = global_reactive_power, type = "l") 
 })

# Close graphics device
dev.off()