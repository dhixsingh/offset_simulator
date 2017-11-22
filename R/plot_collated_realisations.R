#' Plots the results of the Offset Simulator run
#' @param config user configured plotting parameters to use
#' @param loglevel logging level to use, for instance futile.logger::INFO
#' @import futile.logger
#' @export
osim.plot <- function(config, loglevel = INFO){

  if (is.null(config)) {
    stop('please provide an offsetsim plotting configuration file')
  }
  
  flog.threshold(loglevel)
  flog.info('using offsetsim plot config %s', config )
  
#---------------------
# User parameters
#---------------------
  flog.info('sourcing %s', config)
source(config)
plot_params <- initialise_plot_params()

# Set the output filename, and open the pdf file for reading
if (plot_params$write_pdf == TRUE){
  flog.info('will start writing to PDF %s', plot_params$filename)
  pdf(plot_params$filename, width = 8.3, height = 11.7)
} 

# write plots to nx * ny subplots
setup_sub_plots(plot_params$nx, plot_params$ny, x_space = 5, y_space = 5)

if (plot_params$output_type == 'scenarios'){
  feature_ind = 1
} else if (plot_params$output_type == 'features'){
  scenario_ind = 1
}

if (file.exists(plot_params$run_params_filename) == FALSE){
  stop (paste('offsetsim run parameter file not found in ', plot_params$run_params_filename))
}

flog.info('reading %s', plot_params$run_params_filename)
run_params = readRDS(plot_params$run_params_filename)
scenario_filenames <- list.files(path = plot_params$simulation_params_folder, pattern = '_policy_params', all.files = FALSE, 
                                 full.names = FALSE, recursive = FALSE, ignore.case = FALSE, 
                                 include.dirs = FALSE, no.. = FALSE)

check_plot_options(plot_params, run_params, scenario_filenames)


if (!file.exists(plot_params$output_plot_folder)){
  flog.info('creating output plot folder %s', plot_params$output_plot_folder)
  dir.create(plot_params$output_plot_folder)
}


for (plot_ind in plot_params$plot_vec){
  flog.info('creating plot %d', plot_ind)
  if (plot_params$output_type == 'features'){
    feature_ind = plot_ind
  } else {
    scenario_ind = plot_ind
  }
  toRead = paste0(plot_params$simulation_params_folder, '/', scenario_filenames[scenario_ind])
  flog.info(' reading %s', toRead)
  current_policy_params = readRDS(toRead)
  
  collated_filenames = find_collated_files(file_path = plot_params$collated_folder, 
                                           scenario_string = formatC(scenario_ind, width = plot_params$string_width, format = "d", flag = "0"), 
                                           feature_string = formatC(run_params$features_to_use_in_simulation[feature_ind], 
                                                                    width = plot_params$string_width, format = "d", flag = "0"), 
                                           plot_params$realisation_num)
  
  collated_realisations = bind_collated_realisations(collated_filenames)

  flog.info(' writing plot %d of type %s', plot_ind, plot_params$plot_type)
  if (plot_params$plot_type == 'impacts'){
    plot_impact_set(collated_realisations, 
                    plot_params$plot_site_offset_impact, 
                    plot_params$plot_site_dev_impact, 
                    plot_params$plot_site_net_impact, 
                    plot_params$output_type,
                    current_policy_params, 
                    plot_params$site_impact_plot_lims_set[[plot_ind]],
                    plot_params$program_impact_plot_lims_set[[plot_ind]], 
                    plot_params$landscape_impact_plot_lims_set[[plot_ind]], 
                    plot_params$example_set_to_plot,
                    plot_params$lwd_vec, 
                    time_steps = run_params$time_steps, 
                    parcel_num = vector(),
                    realisation_num = collated_realisations$realisation_num,
                    feature_ind = run_params$features_to_use_in_simulation[feature_ind]) 
  } else {
    plot_outcome_set(collated_realisations,
                     plot_params$plot_site_offset_outcome, 
                     plot_params$plot_site_dev_outcome, 
                     plot_params$output_type,
                     current_policy_params,
                     plot_params$site_outcome_plot_lims_set[[plot_ind]],
                     plot_params$program_outcome_plot_lims_set[[plot_ind]], 
                     plot_params$landscape_outcome_plot_lims_set[[plot_ind]],
                     plot_params$example_set_to_plot,
                     plot_params$lwd_vec, 
                     time_steps = run_params$time_steps,
                     realisation_num = collated_realisations$realisation_num, 
                     feature_ind) 
  }
  
  flog.info(' finished writing plot %d', plot_ind)
  
}


# Close the pdf file for reading
if (plot_params$write_pdf == TRUE) {
  graphics.off()
  flog.info('closing PDF %s', plot_params$filename)
}
flog.info('all done')
}