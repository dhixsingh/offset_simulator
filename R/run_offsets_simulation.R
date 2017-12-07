#' Runs the Offset Simulator
#' @param config user configured parameters to use
#' @param loglevel logging level to use, for instance futile.logger::WARN
#' @import doParallel
#' @import doRNG
#' @import foreach
#' @import futile.logger
#' @export
osim.run <- function(config = NULL, loglevel = WARN){

flog.threshold(loglevel)
flog.info('starting offsetsim with config: %s', config )

run_params <- run_initialise_routines(config)

# nested list object containing ecological values by feature layer for all sites
initial_ecology <- readRDS(paste0(run_params$simulation_inputs_folder, 'parcel_ecology.rds'))

# list containing information on site geography
parcels <- readRDS(paste0(run_params$simulation_inputs_folder, 'parcels.rds'))

# list containing probabilities of sites being developed
dev_weights <- readRDS(paste0(run_params$simulation_inputs_folder, 'dev_weights.rds'))

# list used to govern ecology rate changes
decline_rates_initial <- simulate_decline_rates(parcel_num = length(parcels$land_parcels), 
                                                sample_decline_rate = TRUE, 
                                                mean_decline_rates = run_params$mean_decline_rates, 
                                                decline_rate_std = run_params$decline_rate_std, 
                                                feature_num = run_params$feature_num)       # set up array of decline rates that are eassociated with each cell
# select subset of ecology to use in current simulation 
# (e.g. if initial ecology is 100 layers deep just run with 10 of them)
initial_ecology <- select_feature_subset(initial_ecology, run_params$features_to_use_in_simulation)

cl<-parallel::makeCluster(run_params$crs, output="")  # allow parallel processing on n = 4 processors
registerDoParallel(cl)

for (scenario_ind in seq_along(run_params$policy_params_group)){

  loop_strt <- Sys.time()
  flog.info('running scenario %d of %d with %d realisations on %d cores', 
            scenario_ind, 
            length(run_params$policy_params_group),  
            run_params$realisation_num,
            run_params$crs)

  if (run_params$realisation_num > 1 && run_params$set_seed == TRUE){
    # case when running DETERMINISTIC realisations in parallel
    # doRNG needed to get deterministic foreach loops, dsingh 24/nov/17
    flog.info('will use doRNG with seed %d to get determinisitc parallel runs', 123)
    registerDoRNG(123) 
    foreach(realisation_ind = seq_len(run_params$realisation_num)) %dorng%{
              
              simulation_outputs <- run_offset_simulation_routines(policy_params = run_params$policy_params_group[[scenario_ind]],
                                                                   run_params,
                                                                   parcels,
                                                                   initial_ecology,
                                                                   decline_rates_initial,
                                                                   dev_weights,
                                                                   scenario_ind,
                                                                   realisation_ind)
            }
  } else if (run_params$realisation_num > 1){
    # case when running NON-DETERMINISTIC realisations in parallel
    foreach(realisation_ind = seq_len(run_params$realisation_num)) %dopar%{

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
    # case when running single realisation
    # bypasses foreach, but could be merged into earlier case of non-determinisitc realisations in parallel, dsingh 24/nov/17
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
  #remove all temporary files
  unlink(run_params$output_folder, recursive = TRUE)
}

flog.info('all scenarios done in %s %s', 
          round(difftime(Sys.time(), run_params$strt), 1), 
          units(difftime(Sys.time(), run_params$strt)))

parallel::stopCluster(cl)
}

