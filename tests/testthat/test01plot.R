
# source( 'plot_collated_realisations.R' )

initialise_plot_params <- function(){
  plot_params = list()
  plot_params$plot_type = 'impacts' # can be 'outcomes'  or 'impacts',
  plot_params$output_type = 'scenarios' # set to 'features' for multiple feature layers or 'scenarios' for multiple scenarios
  plot_params$realisation_num = 'all' # 'all' or number to plot
  plot_params$write_pdf = TRUE

  plot_params$lwd_vec = c(3, 0.5)
  plot_params$plot_site_offset_impact = TRUE 
  plot_params$plot_site_dev_impact = TRUE
  plot_params$plot_site_net_impact = TRUE
  plot_params$plot_site_offset_outcome = TRUE
  plot_params$plot_site_dev_outcome = TRUE
  
  plot_params$run_number = 02 # for output plot name
  plot_params$example_set_to_plot = 1 # example site to plot
  plot_params$plot_vec = c(1)#c(1,4,7,10, 8, 2,3,5,6,9,11,12 ) #1:12
  plot_params$string_width = 3 # how many digits are used to store scenario index and realisation index
  plot_params$nx = 3 
  plot_params$ny = 4
  
  plot_params$base_folder = '/home/dsingh/offset_data/simulated/simulation_runs/00107'
  
  plot_params$collated_folder = paste0(plot_params$base_folder, '/collated_outputs/')  # LOCATION OF COLLATED FILES
  
  plot_params$simulation_params_folder = paste0(plot_params$base_folder, '/simulation_params/')
  plot_params$output_plot_folder = plot_params$collated_folder
  
  if (plot_params$plot_type == 'impacts'){
    plot_params$filename = paste0(plot_params$output_plot_folder, '/impacts.pdf')
  } else if (plot_params$plot_type == 'outcomes'){
    plot_params$filename = paste0(plot_params$output_plot_folder, '/outcomes.pdf')
  }
  
  plot_params$site_outcome_plot_lims_set = rep(list(c(0, 3e2)), length(plot_params$plot_vec))
  plot_params$program_outcome_plot_lims_set = rep(list(c(2e6, 1e7)), length(plot_params$plot_vec))
  plot_params$landscape_outcome_plot_lims_set = rep(list(c(0.4e7, 0.8e7)), length(plot_params$plot_vec))
  
  plot_params$site_impact_plot_lims_set = rep(list(c(-3e4, 3e4)), length(plot_params$plot_vec))
  plot_params$program_impact_plot_lims_set = rep(list(c(-1e6, 1e6)), length(plot_params$plot_vec)) 
  plot_params$landscape_impact_plot_lims_set = rep(list(c(-1e6, 0.5e6)), length(plot_params$plot_vec))
  
  plot_params$run_params_filename <- paste0(plot_params$simulation_params_folder, '/run_params.rds')

  return(plot_params)
}
