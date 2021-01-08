library(rvest)
library(tibble)
library(tm.plugin.factiva)



Sys.setlocale("LC_ALL","English")

read_html("/Users/bernhardclemm/Dropbox/Academia/Apps/factiva-parsing/Factiva.html")  

html <- "/Users/bernhardclemm/Dropbox/Academia/Apps/factiva-parsing/Factiva.html"

factiva_parser <- function(html) {
  
  page <- read_html(html)  
  
  # Get list of articles
  articles <- page %>% html_nodes(".article .deArticle") 
  
  articles_df <- data.frame(
    headline = NA,
    author = NA,
    topic = NA,
    words = NA,
    date = NA,
    time = NA,
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
    author <- divs %>% html_nodes(".author") %>% html_text()
    if (length(author) != 0) {
      articles_df[i, "author"] <- author
      }
    
    ## First two divs after headline or author are constant
    articles_df[i, "words"] <- divs[[1]] %>% html_text() %>% str_extract("\\d*")
    articles_df[i, "date"] <- divs[[2]] %>% html_text() %>% as.POSIXct(format = "%e %B %Y")
    
    ## After that, position of divs depends...
   
    ### ... on whether hour time is present
    if (grepl("\\d{2}:\\d{2}", html_text(divs[3])) == TRUE) {
      articles_df[i, "time"] <- divs[3] %>% html_text()
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
    
    # Article text
    paragraphs <- articles[[i]] %>% html_nodes(".articleParagraph") %>% html_text 
    articles_df[i, "text"] <- paste(paragraphs, collapse = " ")
  }
  
  return(articles_df)
}

df <- factiva_parser("/Users/bernhardclemm/Dropbox/Academia/Apps/factiva-parsing/Factiva.html")

article <- articles[[1]]

shopping_list <- c("apples x4", "bag of flour", "bag of sugar", "milk x2")

str_extract(shopping_list, "[a-z]+")
str_extract(shopping_list, "[a-z]{1,4}")
str_extract(shopping_list, "\\b[a-z]{1,4}\\b")

article <- articles[[1]]

headline <- article %>% html_nodes(".deHeadline") %>% html_text()
author <- article %>% html_nodes(".author") %>% html_text()
test1 <- article %>% html_nodes("div:not([class])") 
test2<- article %>% html_nodes("div:not([id])") 
test3 <- intersect(test1, test2)
test3 %>% html_nodes("div")

test %>% html_nodes("div:not([class] , [id])") %>% 
  test %>%html_nodes("div:not([id])")
test %>% html_nodes("div:not([id][class])")


divs <- article %>% html_nodes("div")
divs_text <- divs %>% html_text()

page %>% html_nodes(c("div", !".author"))


# Regularities:
## Headline always present
## Author not always present
## Sometimes, topic above headline, also as <div>

test <- read_html('<div class="author">A name</div>
<div id="tag">A tag</div>
<div>A number</div>
<div>A date</div>
<p class="articleParagraph dearticleParagraph">A text</p>
')
test %>% html_nodes("div")
test %>% html_nodes(xpath = '//div[not(contains(@id, "tag") or contains(@class, "author"))]')
test %>% html_nodes(xpath = '//div[not(@id or @class)]')
test %>% html_nodes("div:not([id]), div:not([class])")

test %>% html_nodes("div:not([id]), div:not([class])")
test %>% html_nodes("div:not([id]), div:not([id][class])")
test %>% html_nodes("div:not([id][class])")
test %>% html_nodes("div:not([id],[class])")


test2 <- test %>% html_nodes("div:not([id])")
test2 %>% html_nodes("div:not([class])")

# ==========================
page %>% html_structure()


for (i in 1:3) {
  page %>% html_nodes("article") %>% print()
}
  
data <- tibble(
  headline <- page %>% html_nodes("td") %>% html_text(),
)

library("rvest")<br />url <- "http://en.wikipedia.org/wiki/List_of_U.S._states_and_territories_by_population"
population <- url %>%
  html() %>%
  html_nodes(xpath='//*[@id="mw-content-text"]/table[1]') %>%<br />  html_table()<br />population <- population[[1]]<br /><br />head(population)<br />
  
  
  # source <- FactivaSource("/Users/bernhardclemm/Dropbox/Academia/Apps/factiva-parsing/Factiva.html")
  # corpus <- Corpus(source, list(language=NA))
  # 
  # source <- readFactivaHTML("/Users/bernhardclemm/Dropbox/Academia/Apps/factiva-parsing/Factiva.html")
  