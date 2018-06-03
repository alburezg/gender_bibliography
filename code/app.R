rm(list=ls())

library(dplyr)
library(httr)
# install.packages("genderdata", repos = "http://packages.ropensci.org", type = "source")
library(genderdata)
library(gender)
library(shiny)

author_gender <- function(bib, api = "https://api.crossref.org/works?query.bibliographic=", ...) {
  
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
  
  out <- gender_df(auth_df, name_col = "name", year_col = "year")
  
  if(nrow(out)>0) {
    out <- out[na.omit(match(auth_df$name, out$name)), ] # Order according to authorship
    out$order <- 1:nrow(out)
    out$is_last <- F # Assign last
    out[nrow(out),'is_last'] <- T
  } 
  
  return(out)
}

# UI ####

ui <- fluidPage(
  textAreaInput("bib", "", width = "700px", height = "300px", placeholder = "Paste your bibliography here"),
  actionButton("check", "Gender check!"),
  tableOutput("table")
)

# Server ####

server <- function(input, output) {
  
  tab <- eventReactive(input$check, {
    
    if(input$bib != "") {
      
      bib <- unlist(strsplit(input$bib, "\n"))
      res_df <- do.call(rbind.data.frame, lapply(bib, author_gender) ) 
      
      # All authors
      
      df <- res_df
      
      no_all <- no_authors <- nrow(df)
      
      fem_all <- length(df$gender[df$gender == "female"])
      
      share_all <- round(fem_all/no_authors*100, digits = 1)
      
      # First author
      
      df <- res_df %>% dplyr::filter(order == 1)
      
      no_first <- no_authors <- nrow(df)
      
      fem_first <- length(df$gender[df$gender == "female"])
      
      share_first <- round(fem_first/no_authors*100, digits = 1)
      
      # Last author
      
      df <- res_df %>% dplyr::filter(is_last)
      
      no_last <- no_authors <- nrow(df)
      
      fem_last <- length(df$gender[df$gender == "female"])
      
      share_last <- round(fem_last/no_authors*100, digits = 1)
      
      data.frame(`Type of author` = c("All authors", "First author only", "Last author only"), 
                 `Number of authors identified` = c(no_all, no_first, no_last),
                 `Number of female authors` = c(fem_all, fem_first, fem_last),
                 `Percent of female authors` = c(share_all, share_first, share_last),
                 check.names = FALSE)
      
    } else {
      data.frame(Status = "Waiting for entry")
    }
  })
  
  output$table <- renderTable({ tab() })
  
}

shinyApp(ui = ui, server = server)
