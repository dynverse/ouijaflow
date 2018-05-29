#' Execute Wishbone
#'
#' @param expression Expression
#' @param iter Number of iterations
#' @param num_cores Number of cores allowed
#'
#' @importFrom jsonlite toJSON read_json
#' @importFrom glue glue
#' @importFrom tibble tibble
#' @importFrom purrr %>%
#' @importFrom dplyr rename rename_if
#' @importFrom utils write.table read.csv
#'
#'
#' @export
ouijaflow <- function(
  expression,
  iter = 1000,
  num_cores = 1
) {
  # create temporary folder
  temp_folder <- tempfile()
  dir.create(temp_folder, recursive = TRUE)

  tryCatch({
    # write expression to temporary folder
    expression_df <- data.frame(expression, check.names = FALSE, stringsAsFactors = FALSE)
    utils::write.table(expression_df, paste0(temp_folder, "/expression.tsv"), sep="\t")

    # write parameters to temporary folder
    params <- tibble::lst(
      iter
    )

    write(
      jsonlite::toJSON(params, auto_unbox = TRUE),
      paste0(temp_folder, "/params.json")
    )

    if (!is.null(num_cores)) {
      num_cores_str <- glue::glue(
        "export MKL_NUM_THREADS={num_cores};",
        "export NUMEXPR_NUM_THREADS={num_cores};",
        "export OMP_NUM_THREADS={num_cores}"
      )
    } else {
      num_cores_str <- "echo 'no cores'"
    }

    # execute python script
    commands <- glue::glue(
      "cd {find.package('ouijaflow')}/venv",
      "source bin/activate",
      "{num_cores_str}",
      "python {find.package('ouijaflow')}/wrapper.py {temp_folder}",
      .sep = ";"
    )
    output <- processx::run("/bin/bash", c("-c", commands), echo=TRUE)

    # read output
    pseudotimes <- read_csv(paste0(temp_folder, "/pseudotimes.csv"), col_types=cols(col_double()), col_names=F)[[1]]

  }, finally = {
    # remove temporary output
    unlink(temp_folder, recursive = TRUE)
  })

  pseudotimes
}
