test_that('existing headers override legacy fallback schemas', {
  file <- tempfile()
  writeLines(c('title', 'id name new_field', '1 item future'), file)
  read <- getFromNamespace('read_tbl', 'SWATmeasR')
  x <- read(file, col_names = c('id','legacy'), col_types = 'ic')
  expect_named(x, c('id','name','new_field'))
  expect_identical(x$new_field, 'future')
})

test_that('table writer retains fields beyond a legacy format vector', {
  file <- tempfile()
  write <- getFromNamespace('write_tbl', 'SWATmeasR')
  write(tibble::tibble(id=1L, name='item', new_field='future'), file, c('%8d','%-16s'))
  expect_match(readLines(file)[3], 'future', fixed = TRUE)
})
