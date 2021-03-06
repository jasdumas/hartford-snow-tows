library(RSocrata)
library(ggplot2)
library(plyr)
library(ggmap)

# A quick Exploratory look into the 'Towed Vehicles' Data set from Feb. 2nd 2015 - Present due to snow conditions
# in Hartford, CT

# read the data from the url provided
# snowData <- read.socrata("https://data.hartford.gov/Public-Safety/Towed-Vehicles-From-02012015/3acs-ahvq")
snowData <- read.csv("Towed_Vehicles_From_02012015.csv", header=T, sep=",")
h.snowData <- head(snowData)
sum.snowData <- summary(snowData)

#####################################################################
# We can answer some basic questions from the data summary even 
# before cleaning it and diving deeper
#####################################################################

mean(snowData$Year, na.rm=T) # Average year of car towed?: 2003 
Vehicle.year.bp <- boxplot(snowData$Year, main = "Vehicle Year")
jpeg('Vehicle.year.bp.jpeg')
dev.off()

#####################################################################
# From viewing the head of the dataset, it appears different towing 
# companies had different naming conventions for Make, Model, & Color
# Those variables need to be cleaned up ie. "BLK" = "Black"
# The headers are clean and make sense! (except for the Time)
#####################################################################

levels(snowData$Color) # What do we need to clean up?
snowData$Color[snowData$Color == "WHI"] <- "WHITE"
snowData$Color[snowData$Color == "WHT"] <- "WHITE"
snowData$Color[snowData$Color == "BLK"] <- "BLACK"
snowData$Color[snowData$Color == "BRN"] <- "BROWN"
snowData$Color[snowData$Color == "BRO"] <- "BROWN"
snowData$Color[snowData$Color == "YEL"] <- "YELLOW"
snowData$Color[snowData$Color == "GRY"] <- "GRAY"
snowData$Color[snowData$Color == "BLU"] <- "BLUE"
snowData$Color[snowData$Color == "GRN"] <- "GREEN"
snowData$Color[snowData$Color == "PUR"] <- "PURPLE"
snowData$Color[snowData$Color == "ORG"] <- "ORANGE"

levels(snowData$Make)# What do we need to clean up?
snowData$Make[snowData$Make == "ACUR"] <- "ACURA"
snowData$Make[snowData$Make == "CADI"] <- "CADILLAC"
snowData$Make[snowData$Make == "CADILAC"] <- "CADILLAC"
snowData$Make[snowData$Make == "CHEV"] <- "CHEVROLET"
snowData$Make[snowData$Make == "CHEVR"] <- "CHEVROLET"
snowData$Make[snowData$Make == "CHEVY"] <- "CHEVROLET"
snowData$Make[snowData$Make == "CHRY"] <- "CHRYSLER"
snowData$Make[snowData$Make == "DODGW"] <- "DODGE"
snowData$Make[snowData$Make == "HOND"] <- "HONDA"
snowData$Make[snowData$Make == "HYNDAI"] <- "HYUNDAI"
snowData$Make[snowData$Make == "HYUN"] <- "HYUNDAI"
snowData$Make[snowData$Make == "HYUNDIA"] <- "HYUNDAI"
snowData$Make[snowData$Make == "INFI"] <- "INFINITI"
snowData$Make[snowData$Make == "INFINITY"] <- "INFINITI"
snowData$Make[snowData$Make == "JAGAR"] <- "JAGUAR"
snowData$Make[snowData$Make == "LEXS"] <- "LEXUS"
snowData$Make[snowData$Make == "MERC"] <- "MERCURY"
snowData$Make[snowData$Make == " MITS"] <- "MITSUBISHI"
snowData$Make[snowData$Make == "MITS"] <- "MITSUBISHI"
snowData$Make[snowData$Make == "MITSBUISHI"] <- "MITSUBISHI"
snowData$Make[snowData$Make == " MITSU"] <- "MITSUBISHI"
snowData$Make[snowData$Make == "NISS"] <- "NISSAN"
snowData$Make[snowData$Make == "OLDS"] <- "OLDSMOBILE"
snowData$Make[snowData$Make == "PLYM"] <- "PLYMOUTH"
snowData$Make[snowData$Make == "PLYMOTH"] <- "PLYMOUTH"
snowData$Make[snowData$Make == "PONT"] <- "PONTIAC"
snowData$Make[snowData$Make == "SUBA"] <- "SUBARU"
snowData$Make[snowData$Make == "TOTY"] <- "TOYOTA"
snowData$Make[snowData$Make == "TOYT"] <- "TOYOTA"
snowData$Make[snowData$Make == "VOLV"] <- "VOLVO"
snowData$Make[snowData$Make == "VW"] <- "VOLKSWAGON"

# CLEAN.snowData is a nice subset of the variables for our inquiry!
CLEAN.snowData <- subset(snowData, select = c(Tow.Firm, Tow.Address, Make, Color, Year))

#####################################################################
# Which tow company been towing the most vehicles?
# Ideally some meta-data about the Tow.Firms would be very helpful
# in analyzing whether one company had more tow trucks on the road or
# more employees on that day!
#####################################################################
Tow <- count(CLEAN.snowData$Tow.Firm)

barplot(height = Tow$freq, names.arg = Tow$x, horiz=F, 
        main ="Which company has towed the most vehicles?", xlab ="Tow.Firm"
        , ylab ="Count")
jpeg('tow-firm.jpeg')
dev.off() ## FRIENDLY AUTO BODY & TOWING has towed the most vehicles

#####################################################################
# We answered our previous question pertaining to the entire dataset, 
# but this graphic gives us some detail into range of vehicle year by company
# There is no obvious trend in tow firm bias in vehicle year
#####################################################################
s = CLEAN.snowData$Tow.Firm
st = split(CLEAN.snowData$Year, s)
boxplot(st, las=2) # This is a nice way to spot the outliers!
jpeg('year.jpeg')
dev.off()

#####################################################################
# Is there any vehicle color that certain tow firms target?
# One could deduce that brighter colors stand out in the white snow
# more, but since these are contracters working on guidlines to 
# tow vehicles that are deliquent in shoveling/moving thier cars
# i'd say all the cars are fair game, and that color popularity lies with
# vehicle buyers
######################################################################
ct = table(CLEAN.snowData$Color, CLEAN.snowData$Tow.Firm)
barplot(ct, las=2, legend = unique(CLEAN.snowData$Color))
jpeg('color.jpeg')
dev.off()

#####################################################################
# Is there a parking location that tow firm target the most?
# This can be nicely visualized in a map with the ggmap package
#####################################################################
CLEAN.TA <- CLEAN.snowData$Tow.Address
map.image.address <- paste(CLEAN.TA, ", Hartford, CT")
geo <- geocode(location = map.image.address, output="latlon")

MAP <- ggmap(
  get_map(location = 'Hartford', color="color", source="google", 
              maptype="roadmap", zoom=13), 
  extent ="device")+ geom_point(data = geo, aes(x = lon, y = lat), alpha=0.5)
MAP
