# Parkinson
15 participants with PD on and off medication, 15 controls. Dataset DOI doi:10.18112/openneuro.ds002778.v1.0.5

launch GCFD

matlab_SPoC/
startup_spoc


bbci_public/
startup_bbci_toolbox

front_pd(conf(), {'Name', 'PD_2', 'save_elec', 'true'})
algo(front_pd(conf(), {'Name', 'PD_2', 'load_elec', 'true'}))
