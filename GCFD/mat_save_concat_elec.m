function mat_save_concat_elec(name,stype,seed, p_q_motor)

cd /home/daniil/workspase/matlab_SPoC
startup_spoc
cd /home/daniil/workspase/Parkinson/GCFD/gcfd
startup_gcfd
cd /home/daniil/workspase/Parkinson/GCFD/gcfd/task
%'stype','control', 'ses_on'/'ses_off'
front_pd(conf(),{'Name', name,'stype', stype, 'permut_seed', seed, 'p_q_motor', p_q_motor, 'save_elec','true'})
exit

