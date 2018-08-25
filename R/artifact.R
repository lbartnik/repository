
#' Create an artifact DTO.
#'
#' Creates a DTO (data transfer object) that fully describes an artifact
#' from the repository. It is the central object for external (as opposed
#' to internal to this package) processing, printing, etc.
#'
#' Each artifact (a `list`) has the following attributes (names):
#'
#'   * `id` identifier in the object store; see [storage::object_store]
#'   * `class` one or more `character` values
#'   * `parents` zero or more identifiers of direct parent artifacts
#'
#' @param id artifact identifier in `store`.
#' @param store Object store; see [storage::object_store].
#' @return An `artifact` object.
#'
#' @rdname artifact-internal
new_artifact <- function (id, store) {
  # cast tags as an artifact DTO
  tags <- storage::os_read_tags(store, id)
  tags$id <- id
  dto <- as_artifact(tags)

  # attach the store; artifact_data() depends on it
  attr(dto, 'store') <- store
  dto
}


#' @param tags list of tag values that describe an artifact; typically
#'        read with [storage::os_read_tags()].
#'
#' @rdname artifact-internal
as_artifact <- function (tags) {
  stopifnot(utilities::has_name(tags, c('id', 'class', 'parents')))

  structure(
    list(
      id      = tags$id,
      class   = tags$class,
      parents = as.character(tags$parents)
    ),
    class = 'artifact'
  )
}


#' Manipulating and processing artifacts.
#'
#' @param x object to be tested; `artifact` to be processed.
#'
#' @export
#' @rdname artifact
is_artifact <- function (x) inherits(x, 'artifact')


#' @importFrom rlang is_character is_scalar_character
#' @rdname artifact
artifact_assert_valid <- function (x) {
  stopifnot(is_artifact(x))
  stopifnot(is_scalar_character(x$id))
  stopifnot(is_character(x$class))
  stopifnot(is_character(x$parents))
  TRUE
}


#' @rdname artifact
is_valid_artifact <- function (x) isTRUE(try(artifact_assert_valid(x), silent = TRUE))


#' @description `artifact_is` answers various questions about an
#' artifact.
#'
#' @param what property of an `artifact` to be tested.
#'
#' @export
#' @rdname artifact
#'
#' @examples
#' \dontrun{
#' artifact_is(a, 'plot')
#' }
artifact_is <- function (x, what) {
  stopifnot(is_artifact(x))

  if (identical(what, 'plot')) return('plot' %in% x$class)

  abort(glue("unsupported value of what: {what}"))
}


#' @description `artifact_data` loads the actual artifact object. The
#' output might be large and thus it is not loaded until requested.
#'
#' @export
#' @rdname artifact
artifact_data <- function (x) {
  stopifnot(is_artifact(x))
  store <- attr(x, 'store')
  storage::os_read_object(store, x$id)
}