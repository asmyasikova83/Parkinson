#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

#data_dir=/home/daniil/workspase/data_pd_res_beta1_beta2_low_gamma_frp1_frq2
data_dir=/home/daniil/workspase/data_pd_res_beta13_30_gamma50_150_frp1_frq4

source Names.config

#echo "cleanup data dir ..."
#rm -rf ${data_dir}/*
#echo "rm -rf ${data_dir}/*"
#echo "DONE"
#echo ""

declare -a Type=("ses_off")
declare -a Seed=("0")
#beta 13-30, gamma 50 to 150Hz
#low beta -gamma, Frp = 1, FrQ = 2
#low beta = 15-25 Hz, low gamma = 30-50 Hz
#Beta 2 ("17" "18" "19" "20")
#Beta 1 ("13" "14" "15" "16")
#declare -a FrBase=("16" "17" "18" "19" "20")
declare -a FrBase=("13" "15" "17" "19" "21" "23" "25" "27" "29" "31")
test_no=1
for currName in "${Name[@]}"
do
    for currType in "${Type[@]}"
    do
        for currSeed in "${Seed[@]}"
        do
            for currFrBase in "${FrBase[@]}"
            do
                echo "run #${test_no} mat_save_pat_pval( ${currName}, ${currType}, ${currSeed}, ${currFrBase})"

                res_out=${data_dir}/res_"${currName}"_type_"${currType}"_seed_"${currSeed}"_FrBase_"${currFrBase}".pval_p
                echo "${res_out}"

                if [ ! -f "${res_out}" ];
                then
                    echo "run MATLAB script ..."
                    if [[ "$OSTYPE" == "linux-gnu" ]]
                    then
                        echo "/home/daniil/workspase/matlab/bin/matlab -nodisplay -nodesktop -r \"mat_save_pat_pval($'${currName}','${currType}','${currSeed}','${currFrBase}')\""
                        /home/daniil/workspase/matlab/bin/matlab -nodisplay -nodesktop -r "mat_save_pat_pval('${currName}','${currType}','${currSeed}','${currFrBase}')"
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
exit
