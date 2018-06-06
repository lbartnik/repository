#' @export
#' @importFrom dplyr filter
dplyr::filter

#' @export
#' @importFrom dplyr arrange
dplyr::arrange

#' @export
#' @importFrom dplyr select
dplyr::select


#' @export
filter.repository <- function (repo, ...) {
  filter(as_query(repo), ...)
}

#' @export
arrange.repository <- function (repo, ...) {
  arrange(as_query(repo), ...)
}

#' @export
select.repository <- function (repo, ...) {
  select(as_query(repo), ...)
}


as_query <- function (x) {
  if (is_repository(x)) {
    return(query(x))
  }

  stop("cannot coerce class ", first(class(x)), " to query")
}

query <- function (x) {
  stopifnot(is_repository(x))
  structure(list(repository = x, filter = list(), arrange = list(), select = list()),
            class = 'query')
}

is_query <- function (x) inherits(x, 'query')

#' @importFrom rlang expr_deparse get_expr
#'
qexpr_text <- function (qry, key) {
  stopifnot(is_query(qry))
  map_chr(qry[[key]], function (f) expr_deparse(get_expr(f)))
}


#' @export
print.query <- function (x, ...) {
  lines <- vector(toString(x$repository))

  for (part in c('select', 'filter', 'arrange')) {
    if (length(x[[part]])) {
      lines$push_back(paste0(part, '(', join(qexpr_text(x, part), ', '), ')'))
    }
  }

  cat0('  ', join(lines$data(), ' %>%\n    '), '\n')
}


# --- impl -------------------------------------------------------------

#' @importFrom rlang quos
filter.query <- function (qry, ...) {
  dots <- quos(...)
  qry$filter <- c(qry$filter, dots)
  qry
}

#' @importFrom rlang quos
select.query <- function (qry, ...) {
  # TODO intersect selections
  qry$select <- quos(...)
  qry
}

#' @importFrom rlang quos
arrange.query <- function (qry, ...) {
  dots <- quos(...)
  qry$arrange <- c(qry$arrange, dots)
  qry
}

execute <- function (x) {
  stopifnot(is_query(x))

  # TODO
  # 1. call os_find
  # 2. load what is selected into a tible
  # 3. arrange

}