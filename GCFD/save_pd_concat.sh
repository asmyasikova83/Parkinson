#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

data_dir=/home/daniil/workspase/data_pd_concat


source Names.config

#echo "cleanup data dir ..."
#rm -rf ${data_dir}/*
#echo "rm -rf ${data_dir}/*"
#echo "DONE"
#echo ""

#"control"
declare -a Type=("ses_on")
declare -a Seed=("0")
test_no=1
for currName in "${Name[@]}"
do
    for currSeed in "${Seed[@]}"
    do
        for currType in "${Type[@]}"
        do
            echo "run #${test_no} mat_save_concat_elec(${currName}, ${currType}, ${currSeed})"

            concat_elec_out=${data_dir}/concat_elec_"${currName}"_type_"${currType}"_seed_"${currSeed}".elec
            echo "${concat_elec_out}"

            if [ ! -f "${concat_elec_out}" ];
            then
                echo "run MATLAB script ..."
                    if [[ "$OSTYPE" == "linux-gnu" ]]
                    then
                        echo "/home/daniil/workspase/matlab/bin/matlab -nodisplay -nodesktop -r \"mat_save_concat_elec('${currName}','${currType}','${currSeed}')\""
                        /home/daniil/workspase/matlab/bin/matlab -nodisplay -nodesktop -r "mat_save_concat_elec('${currName}','${currType}','${currSeed}')"
                    else
			#TODO
                        echo "C:\Program Files\MATLAB\R2015b\bin\matlab.exe -nodisplay -nodesktop -logfile output.log -r \"mat_save_concat_elec($'${currName}','${currType}','${currSeed}')\""
                        "C:\Program Files\MATLAB\R2015b\bin\matlab.exe" -nodisplay -nodesktop -logfile output.log -r "mat_save_concat_elec('${currName}','${currType}','${currSeed}')"
                        sleep 120s
                    fi

                echo "DONE"
            fi

            echo -e "${GREEN}Run PASS${NC}"
            echo ""

            let "test_no=test_no+1"
        done
    done
done


