library(pdftools)
library(tesseract)
library(magick)


# Input file
pdf_doc <- list.files("data", full.names = T)

# Test  -------------------------------------------------------------------

# Dir to reduced version
pdf_doc_reduced <- "output/temp/pdf_reduced.pdf"

# Reduced version
pages_sub <- 1:7
pdf_subset(pdf_doc, pdf_doc_reduced, pages = pages_sub)

# Convert to png
directory <- "output/temp/book_png/"
dir.create("output/temp/book_png/")
pdf_pages <- pdf_info(pdf_doc_reduced)$pages
png_names <- paste0(directory, "page_", stringr::str_pad(1:pdf_pages, 3, pad = "0"))
pdf_convert(pdf_doc_reduced, dpi = 600, filenames = png_names)


# Extract text
tesseract_info()
# Load language
tesseract_download("spa")

# PNG files
text_png <- list.files("output/temp/book_png/", full.names = TRUE)

# Test 1
text <- tesseract::ocr(text_png[6], engine = tesseract("spa"))
cat(text)

# Test 2
text2 <- image_read(text_png[6]) %>%
  image_resize("2000") %>%
  image_convert(colorspace = 'gray') %>%
  image_trim() %>%
  image_ocr(language = "spa")
cat(text2)


# Extract all pages -------------------------------------------------

library(parallel)

n_cores <- detectCores()-1

# Wrapper fn for extracting text
png2_text <- function(png) {
  text <- image_read(png) |>
    magick::image_resize("2000") |>
    magick::image_convert(colorspace = 'gray') |>
    magick::image_trim() |>
    magick::image_ocr(language = "spa")
  return(text)
}

# Apply function 
system.time(
  text_all <- lapply(text_png, png2_text)
)

# Parallel
clust <- makeCluster(n_cores)
clusterEvalQ(clust, c(library(magick), library(pdftools)))
clusterExport(clust, c("png2_text"), envir=environment())
system.time(
  text_all_p <- parLapply(clust, text_png, png2_text)
  )

# See output
lapply(text_all, cat)
lapply(text_all_p, cat)
# Same
identical(text_all, text_all_p)


# Import all the document -------------------------------------------------

# Convert to png
pdf_pages <- pdf_info(pdf_doc)$pages
png_names <- paste0(directory, "page_", stringr::str_pad(1:pdf_pages, 3, pad = "0"))
pdf_convert(pdf_doc, dpi = 600, filenames = png_names)

# PNG files
text_png <- list.files("output/temp/book_png/", full.names = TRUE)

# Create directory to store results
dir.create('output/temp/book_text/')

# Batch size
batch_size <- 30
n_batches <- ceiling(pdf_pages / batch_size)
i<-1
# Run loop in batches 
for(i in 1:n_batches){
  # Progress
  print(paste(Sys.time(),'- Batch', i, 'of', n_batches))
  
  # Start batch index
  if(i == 1){
    start_index <- 1
  } else {
    start_index <- end_index + 1
  }
  # End batch index
  if(i == max(n_batches)){
    end_index <- pdf_pages
  } else {
    end_index <- batch_size + start_index
  }
    
  # Apply fn in parallel
  text_all_p <- parLapply(
    clust, text_png[start_index:end_index], png2_text
    )

  # Write as RDS
  saveRDS(
    text_all_p, 
    paste0("output/temp/book_text/book_", start_index, "_", end_index, ".rds")
    )

  # Clean env
  rm(text_all_p)
  gc()
}



