# Parkinson
15 participants with PD on and off medication, 15 controls. Dataset DOI doi:10.18112/openneuro.ds002778.v1.0.5

you need data in .txt

cd edf2ascii_ver14_source/
./edf2ascii ../../BDF_PD/PD_2.BDF


____________________________________________________________________

GCDF/
project for cross-frequency analysis

I. CFS estimates, scripts for automatic processing

1. save_pd_concat.sh - script which runs mat_save_concat_elec.m and creares, saves data (elecs) in the assigned dir

2. save_pd_res.sh - script which runs mat_save_pat_pval.m which runs the GCFD for all participants and base frequencies of interest, conducts permutations and saves the p, q spatial patterns(scalp topos), PLVs (ku values), pvals for p,q patterns

launch GCFD in the MATLAB console, manual processing 

1. run the folowing scripts to add dependencies

matlab_SPoC/
startup_spoc


bbci_public/
startup_bbci_toolbox

2. this is how we manually  run the front() to save or load elec

front_pd(conf(), {'Name', 'PD_2', 'save_elec', 'true'})

3. this is how you run the GCFD

algo(front_pd(conf(), {'Name', 'PD_2', 'load_elec', 'true'}))

4. this is how you run permutations and do visualisation

back_pd(algo(front_pd(conf(), {'Name', 'PD_2', 'load_elec', 'true'})))

II. Analysis and visualization

1. save_kuramotos_1.m in a table
2. PLV_lme_2.m build and analyze the LMM model (3: see the article) 
3. compare_kuramotos_3.m  develop LMM model to estimate spurious CFS

III. Make source topographies for Fig2B

GCFD/gcfd/task/atlas/pd/Fig2B_plot_average.m

Add all the paths and settings in GCFD/gcfd/task/atlas

IV. Cognitive scores and PLVs are not significant, the scripts are in Parkinson/Cognitive_measurements
______________________________________________________________________________________________________
ERSP_deprecated/
project for conducting event-related spectral perturbations in PD data and visualising them

Now deprecated

1. compute ERSP for each condition
ersp_compute_

2. visualise ERSPs with t-statistics
ersp_stat_plot_conditions_
ersp_stat_plot_comparison_

Power_deprecated/
project for computing, comparing, visualising log power 

Now deprecated
