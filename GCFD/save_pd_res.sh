#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

#data_dir=/home/daniil/workspase/data_pd_res_beta13_30_gamma78_180_frp1_frq6_p_q_motor_nobline
#data_dir=/home/daniil/workspase/data_pd_res_beta13_30_gamma39_90_frp1_frq3_p_q_motor_nobline
data_dir=/home/daniil/workspase/data_pd_res_beta13_30_gamma50_150_frp1_frq4_p_q_motor_nobline
#data_dir=/home/daniil/workspase/data_pd_res_beta13_30_gamma50_120_frp1_frq4_p_q_motor_nobline
#data_dir=/home/daniil/workspase/data_pd_res_beta15_30_gamma30_60_frp1_frq2_p_q_motor
#data_dir=/home/daniil/workspase/data_pd_res_beta15_30_gamma30_60_frp1_frq2_p_q_motor_nobline
#data_dir=/home/daniil/workspase/data_pd_res_gamma30_80_gamma30_80_frp1_frq1_p_q_motor
#data_dir=/home/daniil/workspase/data_pd_res_gamma30_70_gamma70_140_frp1_frq2_p_q_motor


source Names.config

#echo "cleanup data dir ..."
#rm -rf ${data_dir}/*
#echo "rm -rf ${data_dir}/*"
#echo "DONE"
#echo ""

declare -a Type=("control")
declare -a Seed=("0")
declare -a p_q_Motor=("on")
#beta 13-30, gamma 50 to 150Hz
#low beta -gamma, Frp = 1, FrQ = 2
#low beta = 15-25 Hz, low gamma = 30-50 Hz
declare -a FrBase=("13" "15" "17" "19" "21" "23" "25" "27" "29" "30")
#declare -a FrBase=("15" "17" "19" "21" "23" "25" "27" "29" "30" "15" "17" "19" "21" "23" "25" "27" "29" "30")
#declare -a FrBase=("30" "32" "34" "36" "38" "40" "42" "44" "46" "48" "50" "52" "54" "56" "58" "60" "62" "64" "66" "68" "70")
# "72" "74" "78" "80" "82" "84" "86" "88" "90" "92" "94" "96" "98" "100")

test_no=1
for currName in "${Name[@]}"
do
    for currType in "${Type[@]}"
    do
        for currSeed in "${Seed[@]}"
        do
            for currFrBase in "${FrBase[@]}"
            do
                for currMotor in "${p_q_Motor[@]}"
                do
                    echo "run #${test_no} mat_save_pat_pval( ${currName}, ${currType}, ${currSeed}, ${currFrBase}, ${currMotor})"

                    res_out=${data_dir}/res_"${currName}"_type_"${currType}"_seed_"${currSeed}"_FrBase_"${currFrBase}"_p_q_motor_"${currMotor}".pval_p
                    echo "${res_out}"

                    if [ ! -f "${res_out}" ];
                    then
                        echo "run MATLAB script ..."
                        if [[ "$OSTYPE" == "linux-gnu" ]]
                        then
                            echo "/home/daniil/workspase/matlab/bin/matlab -nodisplay -nodesktop -r \"mat_save_pat_pval($'${currName}','${currType}','${currSeed}','${currFrBase}','${currMotor}')\""
                            /home/daniil/workspase/matlab/bin/matlab -nodisplay -nodesktop -r "mat_save_pat_pval('${currName}','${currType}','${currSeed}','${currFrBase}','${currMotor}')"
                        else
                            #TODO
                            echo "C:\Program Files\MATLAB\R2015b\bin\matlab.exe -nodisplay -nodesktop -logfile output.log -r \"mat_save_pat_pval($'${currName}','${currType}','${currSeed}','${currFrBase}')\""
                            "C:\Program Files\MATLAB\R2015b\bin\matlab.exe" -nodisplay -nodesktop -logfile output.log -r "mat_save_pat_pval('${currName}','${currType}','${currSeed}','${currFrBase}')"
                            sleep 3000s
                        fi
                        echo "DONE"
                    fi

                    echo -e "${GREEN}Run PASS${NC}"
                    echo ""

                    let "test_no=test_no+1"
                done
            done
        done
    done
done
exit
