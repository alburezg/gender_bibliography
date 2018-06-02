rm(list=ls())

library(dplyr)
library(httr)
# install.packages("genderdata", repos = "http://packages.ropensci.org", type = "source")
library(genderdata)
library(gender)
library(shiny)

author_gender <- function(bib, api = "https://api.crossref.org/works?query.bibliographic=", ...) {
  # browser()
  # print(bib)
  
  bib_e <- URLencode(bib, reserved = T)
  
  url <- paste0(api, bib_e)
  
  r <- content(GET(url), "parsed")$message$items[[1]]
  
  author <- lapply(r$author, function(x) list(x$given, x$family ))
  
  auth_df <- data.frame(matrix(unlist(author), ncol=2, byrow=T),stringsAsFactors=FALSE)
  
  colnames(auth_df) <- c("name", "surname")
  
  year <- r$indexed$`date-parts`[[1]][[1]]
  
  auth_df$year <- ifelse(year > 2012, 2012, year)
  
  # Keep only first name
  auth_df$name <- sapply(auth_df$name, function(x) unlist(strsplit(x, "[[:space:]]"))[1] )
  auth_df$name <- gsub('[[:punct:] ]+',' ',auth_df$name)
  
  # gen_df <- 
  
  out <- gender_df(auth_df, name_col = "name", year_col = "year")
  
  if(nrow(out)>0) {
    out <- out[na.omit(match(auth_df$name, out$name)), ] # Order according to authorship
    out$order <- 1:nrow(out)
  } 
  
  return(out)
}

ui <- fluidPage(
  textAreaInput("bib", "", width = "700px", height = "300px", placeholder = "Paste your bibliography here"),
  # textInput("bib", "", placeholder = "Paste your bibliography here"),
  
  tabPanel(
    "2 columns",
    fluidRow(
      column(width = 4,
             h2("Gender of first author"),
             tableOutput("first")
             ),
      column(width = 4,
             h2("Gender of all authors"),
             tableOutput("all")
      )    )
  )
)

server <- function(input, output) {
  
  first <- eventReactive(input$bib, {
    
    if(input$bib != "") {
      # browser()
      bib <- unlist(strsplit(input$bib, "\n"))
      res_df <- do.call(rbind.data.frame, lapply(bib, author_gender) ) 
      
      res_df %>% 
        dplyr::filter(order == 1) %>% 
        dplyr::rename(Gender = gender) %>% 
        dplyr::group_by(Gender) %>% 
        dplyr::summarise(
          `No. authors` = n(),
          Share = round(n()/nrow(dplyr::filter(res_df, order == 1))*100, 1)
        )
      
    } else {
      data.frame(Status = "Waiting for entry")
    }
    
  })
  
  all <- eventReactive(input$bib, {
    
    if(input$bib != "") {
      # browser()
      bib <- unlist(strsplit(input$bib, "\n"))
      res_df <- do.call(rbind.data.frame, lapply(bib, author_gender) ) 
      
      res_df %>% 
        # dplyr::filter(order == 1) %>% 
        dplyr::rename(Gender = gender) %>% 
        dplyr::group_by(Gender) %>% 
        dplyr::summarise(
          `No. authors` = n(),
          Share = round(n()/nrow(res_df)*100, 1)
        )
      
    } else {
      data.frame(Status = "Waiting for entry")
    }
    
  })
  
  
  
  output$first <- renderTable({
    
    first()

  })
  
  output$all <- renderTable({
    
    all()
    
  })
  
}

shinyApp(ui = ui, server = server)
