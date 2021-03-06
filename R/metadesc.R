auto_tags <- function (x, ...) UseMethod("auto_tags")

auto_tags.default <- function (x, ...) {
  preset <- list(...)
  stopifnot(is_all_named(preset))

  combine(preset, list(class = class(x), time = current_time(), artifact = TRUE,
                       session = r_session_id()))
}

auto_tags.data.frame <- function (x, ...) {
  tags <- auto_tags.default(x, ...)
  combine(list(nrow = nrow(x), ncol = ncol(x), colnames = colnames(x)), tags)
}


auto_tags.lm <- function (x, ...) {
  tags <- auto_tags.default(x, ...)

  glance <- broom::glance(x)
  glance <- glance[c('adj.r.squared', 'AIC', 'df')]

  combine(glance, tags)
}



describe <- function (tags) UseMethod("describe")

#' @importFrom stringi stri_paste
#' @importFrom rlang is_call
describe.default <- function (tags) {
  # class `unclass` to avoid calling a custom operator in `map_chr` as
  # `tags` is not really an object of the class it declares
  tags <- unclass(tags)

  # `exclude` could be an argument
  exclude <- c("artifact", "class", "commit", "id", "parent_commit", "time", "expression")
  tags <- tags[setdiff(names(tags), exclude)]

  values <- map_chr(tags, function(v) {
    if (is_empty(v)) return('')
    if (is_call(v)) v <- deparse(v)
    stri_paste(unlist(v), collapse = ',')
  })
  stri_paste(names(tags), values, sep = ':', collapse = ' ')
}

describe.data.frame <- function (tags) {
  return(paste0('data.frame[', tags$nrow, ', ', tags$ncol, ']'))
}

describe.lm <- function (tags) {
  paste0('lm adjR2:', format(tags$adj.r.squared, digits = 2),
         ' AIC:', format(tags$AIC, digits = 2),
         ' df:', tags$df)
}

describe.rawplot <- function (tags) {
  ''
}


#' Provide a summary of an object.
#'
#' @param tags Tags retrieved from an object store.
#'
#' @import broom
#' @rdname internals
#'
#' @export
description <- function (tags)
{
  stopifnot(is_all_named(tags))

  if (is_empty(tags)) return(NA_character_)
  if (is_empty(tags$class)) return(describe(tags))

  describe(structure(tags, class = tags$class))
}
