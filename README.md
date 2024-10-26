# Parkinson
15 participants with PD on and off medication, 15 controls. Dataset DOI doi:10.18112/openneuro.ds002778.v1.0.5

you need data in .txt

cd edf2ascii_ver14_source/
./edf2ascii ../../BDF_PD/PD_2.BDF

launch GCFD

1. run the folowing scripts

matlab_SPoC/
startup_spoc


bbci_public/
startup_bbci_toolbox

2. this is how us run the front() to save or load elec

front_pd(conf(), {'Name', 'PD_2', 'save_elec', 'true'})

3. this is how you run the GCFD

algo(front_pd(conf(), {'Name', 'PD_2', 'load_elec', 'true'}))

4. this is how you run permutations and do visualisation

back_pd(algo(front_pd(conf(), {'Name', 'PD_2', 'load_elec', 'true'})))

____________________________________________________________________
ERSP/
project for conducting event-related spectral perturbations in PD data and visualising them

1. compute ERSP for each condition
ersp_compute_ersp_single_trial_control.m
ersp_compute_ersp_single_trial_on_off.m

2. visualise ERSPs with t-statistics
ersp_stat_plot_conditions_single_trial_control.m

ersp_stat_plot_conditions_single_trial_on_off.m

ersp_stat_plot_comparison_single_trial_control.m

ersp_stat_plot_comparison_single_trial_on_off.m

GCDF/
project for cross-frequency analysis

save_pd_concat.sh - script which runs mat_save_concat_elec.m and creares, saves data (elecs) in the assigned dir

save_pd_res.sh - script which runs mat_save_pat_pval.m which runs the GCFD for all participants and base frequencies of interest, conducts permutations and saves the p, q spatial patterns(scalp topos), PLVs (ku values), pvals for p,q patterns

