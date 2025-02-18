#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

data_dir=/home/daniil/workspase/data_pd_concat_whole_nobline


source Names.config

#echo "cleanup data dir ..."
#rm -rf ${data_dir}/*
#echo "rm -rf ${data_dir}/*"
#echo "DONE"
#echo ""

#declare -a Type=("ses_off" "ses_on" "control" )
declare -a Type=("control" )
declare -a Seed=("0")
declare -a p_q_Motor=("off")

test_no=1
for currName in "${Name[@]}"
do
    for currSeed in "${Seed[@]}"
    do
        for currType in "${Type[@]}"
        do 
            for currMotor in "${p_q_Motor[@]}"
            do
                echo "run #${test_no} mat_save_concat_elec(${currName}, ${currType}, ${currSeed}, ${currMotor})"

                concat_elec_out=${data_dir}/concat_elec_"${currName}"_type_"${currType}"_seed_"${currSeed}"_p_q_motor_"${currMotor}".elec
                echo "${concat_elec_out}"

                if [ ! -f "${concat_elec_out}" ];
                then
                    echo "run MATLAB script ..."
                        if [[ "$OSTYPE" == "linux-gnu" ]]
                        then
                            echo "/home/daniil/workspase/matlab/bin/matlab -nodisplay -nodesktop -r \"mat_save_concat_elec('${currName}','${currType}','${currSeed}', '${currMotor}')\""
                            /home/daniil/workspase/matlab/bin/matlab -nodisplay -nodesktop -r "mat_save_concat_elec('${currName}','${currType}','${currSeed}', '${currMotor}')"
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
done

