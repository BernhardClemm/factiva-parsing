library(rvest)
library(tidyverse)

# Make sure you set your locale for parsing of date

factiva_parser <- function(html) {
  
  print(paste0("Processing file: ", html))
  
  page <- read_html(html)  
  
  # Get list of articles
  articles <- page %>% html_nodes(".article .deArticle") 
  
  articles_df <- data.frame(
    headline = NA,
    author = NA,
    source = NA,
    topic = NA,
    words = NA,
    date = NA,
    hour = NA,
    id = NA,
    number = NA,
    lang = NA,
    copyright = NA,
    text = NA
  )
  
  # Extract information from articles 
  for (i in 1:length(articles)) {
    
    # All meta information is in <div> elements
    
    divs <- articles[[i]] %>% html_nodes("div")
    
    ## First check whether first element contains headline or topic (very rarely)
    ### If the first div does not have a class, save as "topic" 
    #### Extract remaining divs without class
    if (length(html_attrs(divs[[1]])) == 0) {
      articles_df[i, "topic"] <- divs[[1]] %>% html_text()
      divs <- articles[[i]] %>% html_nodes('div:not([id]):not([class])')
      divs <- divs[-1]
    } else {
      divs <- articles[[i]] %>% html_nodes('div:not([id]):not([class])')
    }
    
    ## Extract headline and author by class
    articles_df[i, "headline"] <- articles[[i]] %>% html_nodes(".deHeadline") %>% html_text()
    author <- articles[[i]] %>% html_nodes(".author") %>% html_text()
    if (length(author) != 0) {
      articles_df[i, "author"] <- author
      }
    
    ## Check if first div after headline or author has number
    if (grepl("\\d", html_text(divs[1])) == FALSE) {
      divs <- divs[-1]
    }
    ## Then, the first two divs are word number and date
    articles_df[i, "words"] <- divs[[1]] %>% html_text() %>% str_extract("\\d*")
    articles_df[i, "date"] <- divs[[2]] %>% html_text() %>% as.POSIXct(format = "%e %B %Y")
    
    ## After that, risk of errors because of unstable HTML
    ## Position of divs depends...
   
    tryCatch( 
      
      expr = { 
        
        ### ... on whether hour time is present
        if (grepl("\\d{2}:\\d{2}", html_text(divs[3])) == TRUE) {
          articles_df[i, "hour"] <- divs[3] %>% html_text()
          articles_df[i, "source"] <- divs[4] %>% html_text() 
          articles_df[i, "id"] <- divs[5] %>% html_text()
          
          ### ... and on whether some cryptic number is present (could be number of paragraphs...)
          if (grepl("\\d", html_text(divs[6])) == TRUE) {
            articles_df[i, "number"] <- divs[6] %>% html_text() 
            articles_df[i, "lang"] <- divs[7] %>% html_text() 
            articles_df[i, "copyright"] <- divs[8] %>% html_text() 
            
            ### ... or cryptic number is not present
          } else {
            articles_df[i, "lang"] <- divs[6] %>% html_text() 
            articles_df[i, "copyright"] <- divs[7] %>% html_text() 
          }
          
          ### ... or hour time is not present
        } else {
          articles_df[i, "source"] <- divs[3] %>% html_text()
          articles_df[i, "id"] <- divs[4] %>% html_text() 
          
          ### ... cryptic number is present
          if (grepl("\\d", html_text(divs[5])) == TRUE) {
            articles_df[i, "number"] <- divs[5] %>% html_text() 
            articles_df[i, "lang"] <- divs[6] %>% html_text() 
            articles_df[i, "copyright"] <- divs[7] %>% html_text() 
            
            ## ... or cryptic number is not present
          } else {
            articles_df[i, "lang"] <- divs[5] %>% html_text() 
            articles_df[i, "copyright"] <- divs[6] %>% html_text() 
          }
        }
      },
      
      error = function(e){          
        message(paste0("Error in processing article ", i, ":"))
        message(e)
      },
      
      warning = function(w){        
        message(paste0("Warning in processing article ", i, ":"))
        message(w)
      },
      
      finally = NULL
    )
    
    # Article text
    paragraphs <- articles[[i]] %>% html_nodes(".articleParagraph") %>% html_text 
    articles_df[i, "text"] <- paste(paragraphs, collapse = " ")
  }
  
  return(articles_df)
}
