function mat_save_pat_pval(name,stype,seed,FrBase, p_q_motor)

cd /home/daniil/workspase/matlab_SPoC
startup_spoc
cd /home/daniil/workspase/Parkinson/GCFD/gcfd
startup_gcfd
if strcmp(p_q_motor, 'on')
    %set ssd_comp_num = num of chans in the subsample of interest, for pd we only take C3, C4
    back_pd(algo(front_pd(conf({'permute_elec','true', 'ssd_comp_num', '2'}),{'stype', stype, 'Name',name,'permut_seed',seed,'load_elec','true','FrBase',FrBase, 'p_q_motor', p_q_motor})))
else
    assert(strcmp(p_q_motor, 'off'))
    back_pd(algo(front_pd(conf({'permute_elec','true'}),{'stype', stype, 'Name',name,'permut_seed',seed,'load_elec','true','FrBase',FrBase, 'p_q_motor', p_q_motor})))
end
exit
