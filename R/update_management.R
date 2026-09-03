#' Update the management inputs for selected HRUs
#'
#' @param swat_inputs List with SWAT+ input files.
#' @param hru_id HRU IDs for which the land use is updated.
#' @param mgt_def List of management input files which define the management
#'   scenario.
#'
#' @returns The SWAT+ input tables list with the updated hru-data.hru,
#'   landuse.lum, management.sch, and plant.ini input tables.
#'
#' @importFrom dplyr bind_rows
#'
#' @keywords internal
#'
update_management <- function(swat_inputs, hru_id, mgt_def) {
  lum_mgt_sel <- mgt_def$hru_data.hru$lu_mgt[mgt_def$hru_data.hru$id %in% hru_id]

  swat_inputs$hru_data.hru$lu_mgt[swat_inputs$hru_data.hru$id %in% hru_id] <-
    lum_mgt_sel

  lum_add <- filter(mgt_def$landuse.lum, name %in% lum_mgt_sel)
  mgt_add <- filter(mgt_def$management.sch, name %in% lum_add$mgt)
  ini_add <- filter(mgt_def$plant.ini, pcom_name %in% lum_add$plnt_com)

  # A scenario may reuse a generated schedule label. Replace the complete
  # definition instead of appending a second block with the same name.
  swat_inputs$landuse.lum <- bind_rows(
    filter(swat_inputs$landuse.lum, !name %in% lum_add$name), lum_add)
  swat_inputs$management.sch <- bind_rows(
    filter(swat_inputs$management.sch, !name %in% mgt_add$name),
                                          mgt_add)
  swat_inputs$plant.ini <- bind_rows(
    filter(swat_inputs$plant.ini, !pcom_name %in% ini_add$pcom_name), ini_add)

  # Set the input files which are adjusted by management related changes
  # so that they will be written when writing output files.
  swat_inputs$file_updated[c('hru_data.hru', 'landuse.lum', 'management.sch',
                             'plant.ini')] <- TRUE

  return(swat_inputs)
}


