# ShinyApp - Data Pipeline 1.0.0

Developer & Maintainer: Yichen Zhang (zhangyichen93@gmail.com)

This Shiny App serves as a crucial part of the data pipeline we recently built. It allows multiple users to enter data through the Shiny GUI. The data will be automatically formatted and stored in a local sqlite (a light version of SQL) database. 

## Implementation 
To run the app on your machine, simply type the following code in your R console:

```{r}
#If you are a first-time user, please first install and load the following dependent packages 
##install.packages("shiny")
##install.packages("shinyjs")
##install.packages("RSQLite")
##install.packages("DT")
##library(shiny)
##library(shinyjs)
##library(RSQLite)
##library(DT)

runGitHub("ShinyApp", "thisisyichenzhang")
```

## R-portable version 
This shiny app also has an R-portable version, which does not require the pre-installation of R on your machine (which is good for those who have not heard of/used R before). You can simply copy-paste the R-portable folder into your laptop and run the App with an easy 'Click'. Please contact the author if you are interested in getting the Rportable App.
