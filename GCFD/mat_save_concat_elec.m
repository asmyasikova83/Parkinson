function mat_save_concat_elec(name,stype,seed)

cd /home/daniil/workspase/matlab_SPoC
startup_spoc
cd /home/daniil/workspase/gcfd
startup_gcfd
cd /home/daniil/workspase/gcfd/task
%'stype','ses_on'/'ses_off'
front_pd(conf(),{'Name',name,'permut_seed',seed,'save_elec','true'})
exit

