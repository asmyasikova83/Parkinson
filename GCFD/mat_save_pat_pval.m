function mat_save_pat_pval(name,stype,seed,FrBase)

cd /home/daniil/workspase/matlab_SPoC
startup_spoc
cd /home/daniil/workspase/gcfd
startup_gcfd
back_pd(algo(front_pd(conf({'permute_elec','true'}),{'stype', 'control', 'Name',name,'permut_seed',seed,'load_elec','true','FrBase',FrBase})))
exit
