# Export text to docx 


# Packages -----------------------------------------------------------------

library(officer)
library(tidyverse)

# Read text ---------------------------------------------------------------

text_files <- list.files("output/temp/book_text/", full.names = TRUE)
text <- lapply(text_files, readRDS)
text <- unlist(text)


# Create docx  ------------------------------------------------------------


# Create a new document object
doc <- read_docx()
# Loop for each page of the document
for(i in 1:length(text)){
  doc <- body_add_par(doc, paste0("[Page ", i, "][linebreak]"), style = "Normal")
  doc <- body_add_par(doc, gsub("\n", "[linebreak]", text[i]), style = "Normal")
  doc <- body_add_par(doc, "[pagebreak]", style = "Normal")
  doc <- body_add_break(doc)
}

# Create a folder to save output
dir.create("output/temp/book_docx/")
# Write docx file
print(doc, "output/temp/book_docx/text_all.docx")

