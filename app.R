library(shiny)
library(magrittr)
source("./funcs_copy.R")
appCSS <- ".mandatory_star { color: red; }"
# get a formatted string of the timestamp (exclude colons as they are invalid
# characters in Windows filenames)
humanTime <- function() {
  format(Sys.time(), "%Y%m%d")
}

# Define the fields we want to save from the form
fields1 <- c("source_age","sex","pre_treatment","pre_treatment_date","treatment","treatment_date","alive","replased","last_observed","response")
fields2 <- c("source_id2","size","tumor_in_adjacent_node","metastatic")
fields3 <- c("specimen_id2","consumable_id","user_id")
fields4 <- c("user","Gene_RLF","FovCount","lane1","lane2","lane3","lane4","lane5","lane6","lane7","lane8","lane9","lane10","lane11","lane12","comments")

# Define the mandatory fields
fieldsMandatory1 <- c("source_age","sex","pre_treatment","treatment")
fieldsMandatory2 <- c("source_id2","metastatic")
fieldsMandatory3 <- c("specimen_id2")



sqlitePath <- "./copy.sqlite"
table1 <- "responses"
db <- dbConnect(SQLite(), sqlitePath)
exist_table1 <- dbReadTable(db,table1)
dbDisconnect(db)

table2 <- "responses2"
db <- dbConnect(SQLite(), sqlitePath)
exist_table2 <- dbReadTable(db,table2)
dbDisconnect(db)

table3 <- "responses3"
db <- dbConnect(SQLite(), sqlitePath)
exist_table3 <- dbReadTable(db,table3)
dbDisconnect(db)

table4 <- "responses4"
db <- dbConnect(SQLite(), sqlitePath)
exist_table4 <- dbReadTable(db,table4)
dbDisconnect(db)

# Shiny app with 3 fields that the user can submit data for
shinyApp(
  ui = fluidPage(
    tabsetPanel(
      tabPanel("page1",pageWithSidebar(
        
        headerPanel("Input the source (patient) infomation"),
        sidebarPanel(
          shinyjs::inlineCSS(appCSS),
          shinyjs::useShinyjs(),
          helpText(" Source can be the 'biological unit' such as 
                   patient or cell-line "),
          sliderInput("source_age", labelMandatory("Age"),
                      1, 100, 30, ticks = T),
          selectizeInput("sex", labelMandatory("Write the sex"),choices = unique(exist_table1$sex), multiple = FALSE,
                         options = list(create = TRUE, placeholder = 'Choose the sex')),
          checkboxInput("pre_treatment", labelMandatory("This patient had pre-treatment"), FALSE),
          dateInput("pre_treatment_date",label = "Write the pre-treatment date",value = "2017-04-1", format = "yyyy-mm-dd"),
          selectizeInput("treatment", labelMandatory("Write the treatment type"),choices = unique(exist_table1$treatment), multiple = FALSE,
                         options = list(create = TRUE, placeholder = 'Choose the treatment')),
          dateInput("treatment_date",label = "Write the treatment date",value = "2017-05-1", format = "yyyy-mm-dd"),
          checkboxInput("alive", labelMandatory("Alive"), FALSE),
          checkboxInput("replased", labelMandatory("Replased"), FALSE),
          dateInput("last_observed",label = "Write the last observed date",value = "2017-06-1", format = "yyyy-mm-dd"),
          selectizeInput("response", "Write the response",choices = unique(exist_table1$response), multiple = FALSE,
                         options = list(create = TRUE, placeholder = 'Choose the response')),
          
          
          actionButton("submit", "Submit")
          ),
        mainPanel(###### download button ########
                  downloadButton("downloadBtn", "Download responses"),tags$hr(),
                  
                  DT::dataTableOutput("responses", width = 300), tags$hr()
        )
        
      )
      ),
      
      tabPanel("page2",pageWithSidebar(
        headerPanel("Input the specimen (tumor) infomation"),
        sidebarPanel(
          shinyjs::useShinyjs(),
          helpText(" Specimen can be Tumor."),
          uiOutput("source_id2"),
          selectizeInput("size", "The size of the tumor",choices = unique(exist_table2$size), multiple = FALSE,
                         options = list(create = TRUE, placeholder = 'Choose the size')),
          
          selectizeInput("tumor_in_adjacent_node", "Have observed the tumor in the adjacent node",choices = c("Y","N","N/A"), multiple = FALSE,
                         options = list(create = TRUE, placeholder = 'Choose the tumor in adjacent node')),
          
          selectizeInput("metastatic", labelMandatory("Tumor is metastatic"),choices = c("Y","N","N/A"), multiple = FALSE,
                         options = list(create = TRUE, placeholder = 'Choose the metastatic')),
          
          actionButton("submit2", "Submit")
        ),
        mainPanel(downloadButton("downloadBtn2", "Download responses"), tags$hr(),
                  DT::dataTableOutput("responses2", width = 300), tags$hr()
        )
      )
      ),
      
      
      tabPanel("page3",pageWithSidebar(
        headerPanel("Input the  sub-specimen (biomaterial extraction/prep) infomation"),
        sidebarPanel(
          helpText("Subspecimen can be Biomaterial extraction/prep."),
          uiOutput("specimen_id2"),
          selectizeInput("consumable_id", "Write the Consumable ID ",choices = unique(exist_table3$consumable_id ), multiple = FALSE,
                         options = list(create = TRUE, placeholder = 'Choose the consumable_id ')),
          
          selectizeInput("user_id", "Write the User ID",choices = unique(exist_table3$user_id), multiple = FALSE,
                         options = list(create = TRUE, placeholder = 'Choose the user_id')),
          
          
          actionButton("submit3", "Submit")
        ),
        mainPanel(downloadButton("downloadBtn3", "Download responses"),tags$hr(),
                  DT::dataTableOutput("responses3", width = 300), tags$hr()
        )
      )
      ),
      
      
      tabPanel("page4",pageWithSidebar(
        headerPanel("Input the cartridge infomation"),
        sidebarPanel(
          textInput("user","User:",""),
          textInput("Gene_RLF","Gene_RLF:",""),
          numericInput("FovCount", "FovCount:", 10, min = 1, max = 100),
          uiOutput("lane1"),
          uiOutput("lane2"),
          uiOutput("lane3"),
          uiOutput("lane4"),
          uiOutput("lane5"),
          uiOutput("lane6"),
          uiOutput("lane7"),
          uiOutput("lane8"),
          uiOutput("lane9"),
          uiOutput("lane10"),
          uiOutput("lane11"),
          uiOutput("lane12"),
          textInput("comments","Comments:",""),
          actionButton("submit4", "Submit")
        ),
        mainPanel(downloadButton("downloadBtn4", "Download responses"), tags$hr(),
                  actionButton("downloadBtn5", "Download cdfs"), 
                  helpText("The cdf will be downloaded to the ./shiny/cdf when clicked"),tags$hr(),
                  DT::dataTableOutput("responses4", width = 300), tags$hr())
      )
      )
      
  )
    ),
  server = function(input, output, session) {
    
    ################### only with mandatory input is submit available ############
    ######page1#########
    observe({
      # check if all mandatory fields have a value
      mandatoryFilled <-
        vapply(fieldsMandatory1,
               function(x) {
                 !is.null(input[[x]]) && input[[x]] != ""
               },
               logical(1))
      mandatoryFilled <- all(mandatoryFilled)
      
      # enable/disable the submit button
      shinyjs::toggleState(id = "submit", condition = mandatoryFilled)
    })
    ####################
    
    ######page2#########
    observe({
      # check if all mandatory fields have a value
      mandatoryFilled <-
        vapply(fieldsMandatory2,
               function(x) {
                 !is.null(input[[x]]) && input[[x]] != ""
               },
               logical(1))
      mandatoryFilled <- all(mandatoryFilled)
      
      # enable/disable the submit button
      shinyjs::toggleState(id = "submit2", condition = mandatoryFilled)
    })
    
    ####################
    #####page3##########
    observe({
      # check if all mandatory fields have a value
      mandatoryFilled <-
        vapply(fieldsMandatory3,
               function(x) {
                 !is.null(input[[x]]) && input[[x]] != ""
               },
               logical(1))
      mandatoryFilled <- all(mandatoryFilled)
      
      # enable/disable the submit button
      shinyjs::toggleState(id = "submit3", condition = mandatoryFilled)
    })
    ###################
    
    #####################end of mandatory fields setting#################################
    
    ############## downloading the data #####################
    ########### download the data1 ###################
    output$downloadBtn <- downloadHandler(
      filename = function() { 
        sprintf("patient_%s.csv", humanTime())
      },
      content = function(file) {
        write.csv(loadData(table = table1), file, row.names = FALSE)
      }
    )
    
    ########### download the data2 ###################
    output$downloadBtn2 <- downloadHandler(
      filename = function() { 
        sprintf("specimen_%s.csv", humanTime())
      },
      content = function(file) {
        write.csv(loadData(table = table2), file, row.names = FALSE)
      }
    )
    ####################################################
    
    ########### download the data3 ###################
    output$downloadBtn3 <- downloadHandler(
      filename = function() { 
        sprintf("subspecimen_%s.csv", humanTime())
      },
      content = function(file) {
        write.csv(loadData(table = table3), file, row.names = FALSE)
      }
    )
    ####################################################
    
    ########### download the data4 ###################
    output$downloadBtn4 <- downloadHandler(
      filename = function() { 
        sprintf("catridge_%s.csv", humanTime())
      },
      content = function(file) {
        data <- loadData(table = table4)
        write.csv(data, file, row.names = FALSE)
      }
    )
    
    observeEvent(input$downloadBtn5,{
      olddata_wide<-loadData(table = table4)
      olddata_wide$cartridge_id <- factor(olddata_wide$cartridge_id)
      # conver the long format to wide format 
      data_long <- tidyr::gather(olddata_wide, 'lanes ID', 'subspecimen ID', lane1:lane12, factor_key=TRUE)
      cartridge_id <- unique(data_long$cartridge_id)
      for(i in cartridge_id){
        output <- subset(data_long, data_long$cartridge_id == i)[,-1] 
        output = cbind(output, date = rep(humanTime(),12))
        line = sprintf("<Header>
FileVersion,1.1
CartridgeID,%s
Email,
ArchiveFolder,
</Header>\n", i)   
        write(line, file=sprintf("./cdf/output_id%s.cdf",i), append=F)
        write("<Samples>", file=sprintf("./cdf/output_id%s.cdf",i), append=TRUE)
        write.table(output, file=sprintf("./cdf/output_id%s.cdf",i), append=TRUE,row.names = F,sep = ",",quote = F)
        write("</Samples>\n", file=sprintf("./cdf/output_id%s.cdf",i), append=TRUE)
      }})
    
    ####################################################
    
    ui <- eventReactive(input$submit,{
      db <- dbConnect(SQLite(), sqlitePath)
      source_table <- dbReadTable(db, "responses")
      selectInput("source_id2", labelMandatory("Choose Source ID"), source_table$source_id)
    },ignoreNULL=FALSE) # ignoreNULL=FALSE is to initialize the list 
    
    output$source_id2 <- renderUI(ui())
    
    # Whenever a field is filled, aggregate all form data
    
    
    ui3 <- eventReactive(input$submit2,{
      db <- dbConnect(SQLite(), sqlitePath)
      source_table2 <- dbReadTable(db, "responses2")
      selectInput("specimen_id2", labelMandatory("Choose specimen ID"), source_table2$specimen_id)
    },ignoreNULL=FALSE) # ignoreNULL=FALSE is to initialize the list 
    
    output$specimen_id2 <- renderUI(ui3())
    
    # Whenever a field is filled, aggregate all form data
    
    ############## page4 lane 1 to lane 12 ##################
    ui4_1 <- eventReactive(input$submit3,{
      db <- dbConnect(SQLite(), sqlitePath)
      source_table4 <- dbReadTable(db, "responses3")
      selectInput("lane1", "Choose lane1", choices = c("NULL",source_table4$sub_specimen_id),selected = "NULL")
      
    },ignoreNULL=FALSE) # ignoreNULL=FALSE is to initialize the list 
    
    output$lane1 <- renderUI(ui4_1())
    
    
    ui4_2 <- eventReactive(input$submit3,{
      db <- dbConnect(SQLite(), sqlitePath)
      source_table4 <- dbReadTable(db, "responses3")
      selectInput("lane2", "Choose lane2", c("NULL",source_table4$sub_specimen_id),selected = NULL)
      
    },ignoreNULL=FALSE) # ignoreNULL=FALSE is to initialize the list 
    
    output$lane2 <- renderUI(ui4_2())
    
    ui4_3 <- eventReactive(input$submit3,{
      db <- dbConnect(SQLite(), sqlitePath)
      source_table4 <- dbReadTable(db, "responses3")
      selectInput("lane3", "Choose lane3", c("NULL",source_table4$sub_specimen_id),selected = NULL)
      
    },ignoreNULL=FALSE) # ignoreNULL=FALSE is to initialize the list 
    
    output$lane3 <- renderUI(ui4_3())
    
    ui4_4 <- eventReactive(input$submit3,{
      db <- dbConnect(SQLite(), sqlitePath)
      source_table4 <- dbReadTable(db, "responses3")
      selectInput("lane4", "Choose lane4", c("NULL",source_table4$sub_specimen_id),selected = NULL)
      
    },ignoreNULL=FALSE) # ignoreNULL=FALSE is to initialize the list 
    
    output$lane4 <- renderUI(ui4_4())
    
    ui4_5 <- eventReactive(input$submit3,{
      db <- dbConnect(SQLite(), sqlitePath)
      source_table4 <- dbReadTable(db, "responses3")
      selectInput("lane5", "Choose lane5", c("NULL",source_table4$sub_specimen_id),selected = NULL)
      
    },ignoreNULL=FALSE) # ignoreNULL=FALSE is to initialize the list 
    
    output$lane5 <- renderUI(ui4_5())
    
    ui4_6 <- eventReactive(input$submit3,{
      db <- dbConnect(SQLite(), sqlitePath)
      source_table4 <- dbReadTable(db, "responses3")
      selectInput("lane6", "Choose lane6", c("NULL",source_table4$sub_specimen_id),selected = NULL)
      
    },ignoreNULL=FALSE) # ignoreNULL=FALSE is to initialize the list 
    
    output$lane6 <- renderUI(ui4_6())
    
    ui4_7 <- eventReactive(input$submit3,{
      db <- dbConnect(SQLite(), sqlitePath)
      source_table4 <- dbReadTable(db, "responses3")
      selectInput("lane7", "Choose lane7", c("NULL",source_table4$sub_specimen_id),selected = NULL)
      
    },ignoreNULL=FALSE) # ignoreNULL=FALSE is to initialize the list 
    
    output$lane7 <- renderUI(ui4_7())
    
    ui4_8 <- eventReactive(input$submit3,{
      db <- dbConnect(SQLite(), sqlitePath)
      source_table4 <- dbReadTable(db, "responses3")
      selectInput("lane8", "Choose lane8", c("NULL",source_table4$sub_specimen_id),selected = NULL)
      
    },ignoreNULL=FALSE) # ignoreNULL=FALSE is to initialize the list 
    
    output$lane8 <- renderUI(ui4_8())
    
    ui4_9 <- eventReactive(input$submit3,{
      db <- dbConnect(SQLite(), sqlitePath)
      source_table4 <- dbReadTable(db, "responses3")
      selectInput("lane9", "Choose lane9", c("NULL",source_table4$sub_specimen_id),selected = NULL)
      
    },ignoreNULL=FALSE) # ignoreNULL=FALSE is to initialize the list 
    
    output$lane9 <- renderUI(ui4_9())
    
    ui4_10 <- eventReactive(input$submit3,{
      db <- dbConnect(SQLite(), sqlitePath)
      source_table4 <- dbReadTable(db, "responses3")
      selectInput("lane10", "Choose lane10", c("NULL",source_table4$sub_specimen_id),selected = NULL)
      
    },ignoreNULL=FALSE) # ignoreNULL=FALSE is to initialize the list 
    
    output$lane10 <- renderUI(ui4_10())
    
    ui4_11 <- eventReactive(input$submit3,{
      db <- dbConnect(SQLite(), sqlitePath)
      source_table4 <- dbReadTable(db, "responses3")
      selectInput("lane11", "Choose lane11", c("NULL",source_table4$sub_specimen_id),selected = NULL)
      
    },ignoreNULL=FALSE) # ignoreNULL=FALSE is to initialize the list 
    
    output$lane11 <- renderUI(ui4_11())
    
    ui4_12 <- eventReactive(input$submit3,{
      db <- dbConnect(SQLite(), sqlitePath)
      source_table4 <- dbReadTable(db, "responses3")
      selectInput("lane12", "Choose lane12", c("NULL",source_table4$sub_specimen_id),selected = NULL)
      
    },ignoreNULL=FALSE) # ignoreNULL=FALSE is to initialize the list 
    
    output$lane12 <- renderUI(ui4_12())
    
    # Whenever a field is filled, aggregate all form data
    ########################################################
    
    formData1 <- reactive({
      data <- sapply(fields1, function(x) as.character(input[[x]]))
      data
    })
    
    # When the Submit button is clicked, save the form data
    observeEvent(input$submit, {
      saveData(formData1(),table = table1)
    })
    
    # Show the previous responses
    # (update with current response when Submit is clicked)
    output$responses <- DT::renderDataTable({
      input$submit
      loadData(table = table1)
    })
    
    
    
    
    formData2 <- reactive({
      data <- sapply(fields2, function(x) as.character(input[[x]]))
      data
    })
    
    # When the Submit button is clicked, save the form data
    observeEvent(input$submit2, {
      saveData(formData2(),table = table2)
    })
    
    # Show the previous responses
    # (update with current response when Submit is clicked)
    output$responses2 <- DT::renderDataTable({
      input$submit2
      loadData(table = table2)
    })
    
    
    ################### layer 3###########
    formData3 <- reactive({
      data <- sapply(fields3, function(x) as.character(input[[x]]))
      data
    })
    
    # When the Submit button is clicked, save the form data
    observeEvent(input$submit3, {
      saveData(formData3(),table = table3)
    })
    
    # Show the previous responses
    # (update with current response when Submit is clicked)
    output$responses3 <- DT::renderDataTable({
      input$submit3
      loadData(table = table3)
    })
    
    ################### layer 4################
    formData4 <- reactive({
      data <- sapply(fields4, function(x) as.character(input[[x]]))
      data
    })
    
    # When the Submit button is clicked, save the form data
    observeEvent(input$submit4, {
      saveData(formData4(),table = table4)
    })
    
    # Show the previous responses
    # (update with current response when Submit is clicked)
    output$responses4 <- DT::renderDataTable({
      input$submit4
      loadData(table = table4)
    })
  }
)

