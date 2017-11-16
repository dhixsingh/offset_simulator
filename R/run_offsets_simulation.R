#' Runs the Offset Simulator
#' @param config user configured parameters to use
#' @param loglevel logging level to use, for instance futile.logger::INFO
#' @import doParallel
#' @import foreach
#' @import futile.logger
#' @export
run <- function(config = NULL, loglevel = WARN){

flog.threshold(loglevel)
flog.info('Starting Offset Simulator with config: %s', config )

run_params <- run_initialise_routines(config)
initial_ecology <- readRDS(paste0(run_params$simulation_inputs_folder, 'parcel_ecology.rds'))
parcels <- readRDS(paste0(run_params$simulation_inputs_folder, 'parcels.rds'))
dev_weights <- readRDS(paste0(run_params$simulation_inputs_folder, 'dev_weights.rds'))

decline_rates_initial <- simulate_decline_rates(parcel_num = length(parcels$land_parcels),
                                                sample_decline_rate = TRUE,
                                                mean_decline_rates = run_params$mean_decline_rates,
                                                decline_rate_std = run_params$decline_rate_std,
                                                feature_num = run_params$feature_num)       # set up array of decline rates that are eassociated with each cell

initial_ecology <- select_feature_subset(initial_ecology, run_params$features_to_use_in_simulation)

cl<-parallel::makeCluster(run_params$crs)  # allow parallel processing on n = 4 processors
registerDoParallel(cl)

for (scenario_ind in seq_along(run_params$policy_params_group)){

  loop_strt <- Sys.time()
  flog.info('running scenario %d of %d with %d realisations on %d cores', 
            scenario_ind, 
            length(run_params$policy_params_group),  
            run_params$realisation_num,
            run_params$crs)

  if (run_params$realisation_num > 1){
    foreach(realisation_ind = seq_len(run_params$realisation_num),
            .verbose=TRUE) %dopar%{

      simulation_outputs <- run_offset_simulation_routines(policy_params = run_params$policy_params_group[[scenario_ind]],
                                                           run_params,
                                                           parcels,
                                                           initial_ecology,
                                                           decline_rates_initial,
                                                           dev_weights,
                                                           scenario_ind,
                                                           realisation_ind)
    }
  } else {
    simulation_outputs <- run_offset_simulation_routines(policy_params = run_params$policy_params_group[[scenario_ind]],
                                                         run_params,
                                                         parcels,
                                                         initial_ecology,
                                                         decline_rates_initial,
                                                         dev_weights,
                                                         scenario_ind,
                                                         realisation_ind = 1)
  }

  flog.info('scenario %d done in %s %s', 
            scenario_ind,
            round(difftime(Sys.time(), loop_strt), 1), 
            units(difftime(Sys.time(), loop_strt)))

}

if (run_params$save_simulation_outputs == FALSE){
  unlink(run_params$output_folder, recursive = TRUE)
}

flog.info('all scenarios done in %s %s', 
          round(difftime(Sys.time(), run_params$strt), 1), 
          units(difftime(Sys.time(), run_params$strt)))

parallel::stopCluster(cl)
}
