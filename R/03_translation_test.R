# Translate from Spanish to English


# Packages -----------------------------------------------------------------


#devtools::install_github("zumbov2/deeplr")
library(deeplr)
library(tidyverse)

# Read key
my_key <- readLines("C:/Users/jvt3d/Documents/DeepL_key.txt")
# Check status/use
deeplr::usage2(my_key)


# Read text ---------------------------------------------------------------

library(readtext)

# Text 1
text1_spa <- readtext("output/temp/book_docx/test_1.docx")$text
# Split by page
text1_spa <- str_split(text1_spa, "\\[pagebreak\\]")
text1_spa <-unlist(text1_spa)
# Split by paragraph
text1_spa <- text1_spa %>% 
  str_split("(?<=(\\.|:|%)\n)") %>% 
  lapply(gsub, pattern =  "\n", replacement = " ") %>% 
  lapply(str_trim)

# Text 2
text2_spa <- readtext("output/temp/book_docx/test_2.docx")$text
# Split by page
text2_spa <- str_split(text2_spa, "\\[pagebreak\\]")
text2_spa <-unlist(text2_spa)
# Split by paragraph
text2_spa <- text2_spa %>% 
  str_split("(?<=(\\.|:|%)\n)") %>% 
  lapply(gsub, pattern =  "\n", replacement = " ") %>% 
  lapply(str_trim)


# Translate ---------------------------------------------------------------

# Translate text 1
text1_eng <- 
  lapply(text1_spa, function(x){
    deeplr::translate2(
      text = x,
      target_lang = "EN",
      source_lang = "ES",
      auth_key = my_key
      )
    }
  )

# Translate text 2
text2_eng <- 
  lapply(text2_spa, function(x){
    deeplr::translate2(
      text = x,
      target_lang = "EN",
      source_lang = "ES",
      auth_key = my_key
    )
  }
  )


# Save as word ------------------------------------------------------------

library(officer)

# Create a new document object
doc1 <- read_docx()
# Loop for each page for each paragraph
for(doc_page in 1:length(text1_eng)){
  for(doc_par in 1:length(text1_eng[[doc_page]]))
  doc1 <- body_add_par(doc1, text1_eng[[doc_page]][doc_par], style = "Normal")
  doc1 <- body_add_break(doc1)
}

# Create a folder to save output
dir.create("output/temp/translation_test/")
# Write docx file
print(doc1, "output/temp/translation_test/test1_eng.docx")


# Test 2: New document object
doc2 <- read_docx()
# Loop for each page for each paragraph
for(doc_page in 1:length(text2_eng)){
  for(doc_par in 1:length(text2_eng[[doc_page]]))
    doc2 <- body_add_par(doc2, text2_eng[[doc_page]][doc_par], style = "Normal")
  doc2 <- body_add_break(doc2)
}

# Write docx file
print(doc2, "output/temp/translation_test/test2_eng.docx")

