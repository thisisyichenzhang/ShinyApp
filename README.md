# ShinyApp - Data Pipeline 1.0.0

Developer: Yichen Zhang (zhangyichen93@gmail.com)
Maintainer: Yichen Zhang (zhangyichen93@gmail.com)

This Shiny App serves as the crucial part of the data pipeline we recently built. It allows multiple users to enter data throuhg the Shiny App. The formatted data will be stored in the local sqlite (a light version of SQL) database. 

## Implementation 
To run the app on your machine, simply type the following code in your R console:

```{r}
#If you are the first-time user, please first install and load the following dependent packages 
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
This shiny app also has a R-portable version, which does not require the pre-installation of R on your machine (which is good for those have not heard of/used R before). You can simply copy-paste the R-portable folder in your laptop, and run the App with a easy 'Click'. Please contact the author if you are interested in getting the Rportable App.
