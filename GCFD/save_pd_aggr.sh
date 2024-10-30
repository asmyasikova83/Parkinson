#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

src_dir=/home/daniil/workspase/data_pd_res_beta13_30_gamma50_150_frp1_frq4
data_dir=/home/daniil/workspase/data_pd_aggr_beta_gamma

save_pd_aggr () {

if [ $1 = "ses_off" ];
then
    source Names.config
    declare -a Pair=("ses_off")
    echo "Your choice is ses_off"
elif [ $1 = "ses_on" ];
then
    source Names.config
    declare -a Pair=("ses_on")
    echo "Your choice is ses_on"
else [ $1 = "control" ];
    declare -a Name=("PD_2" "PD_4" "PD_7" "PD_8" "PD_10" "PD_18" "PD_20" "PD_21" "PD_24" "PD_25" "PD_29" "PD_30" "PD_31" "PD_32" "PD_33" )
    declare -a Pair=("control")
    echo "Your choice is control"
fi
declare -a Seed=("0")
declare -a FrBase=("13" "15" "17" "19" "21" "23" "25" "27" "29" "31")
test_no=1
exist_test_no=1
empty_test_no=1
pval_line_no=1
check_line_no=1



for currPair in "${Pair[@]}"
do
    for currName in "${Name[@]}"
    do
        for currSeed in "${Seed[@]}"
        do
            for currFrBase in "${FrBase[@]}"
            do
                echo "file #${test_no}"

                pval_p=${src_dir}/res_"${currName}"_type_"${currPair}"_seed_"${currSeed}"_FrBase_"${currFrBase}".pval_p
                pval_q=${src_dir}/res_"${currName}"_type_"${currPair}"_seed_"${currSeed}"_FrBase_"${currFrBase}".pval_q
                pattern_p=${src_dir}/res_"${currName}"_type_"${currPair}"_seed_"${currSeed}"_FrBase_"${currFrBase}".pattern_p
                pattern_q=${src_dir}/res_"${currName}"_type_"${currPair}"_seed_"${currSeed}"_FrBase_"${currFrBase}".pattern_q
                kuramoto=${src_dir}/res_"${currName}"_type_"${currPair}"_seed_"${currSeed}"_FrBase_"${currFrBase}".ku
                echo "${pval_p}"
                pval_line_no=$(cat ${pval_p} | wc -l)

                check_line_no=$(cat ${pval_q} | wc -l)
                if [ $pval_line_no -ne $check_line_no ]
                then
                    echo "different line number in ${pval_q}"
                    exit
                fi

                check_line_no=$(cat ${pattern_p} | wc -l)
                if [ $pval_line_no -ne $check_line_no ]
                then
                    echo "different line number in ${pattern_p}"
                    exit
                fi

                check_line_no=$(cat ${pattern_q} | wc -l)
                if [ $pval_line_no -ne $check_line_no ]
                then
                    echo "different line number in ${pattern_q}"
                    exit
                fi

                check_line_no=$(cat ${kuramoto} | wc -l)
                if [ $pval_line_no -ne $check_line_no ]
                then
                    echo "different line number in ${kuramoto}"
                    exit
                fi

                if [ -f "${pval_p}" ];
                then
                    if [ ! -s "${pval_p}" ];
                    then
                        echo -e "${RED}File is empty${NC}"
                        let "empty_test_no=empty_test_no+1"
                    fi
                    cat ${pattern_p} >> ${data_dir}/"$1"_pattern_p.res
                    cat ${pval_p} >> ${data_dir}/"$1"_pval_p.res
                    cat ${pattern_q} >> ${data_dir}/"$1"_pattern_q.res
                    cat ${pval_q} >> ${data_dir}/"$1"_pval_q.res
                    cat ${kuramoto} >> ${data_dir}/"$1"_kuramoto.res
                    echo -e "${GREEN}OK${NC}"

                    let "exist_test_no=exist_test_no+1"
                else
                    echo -e "${RED}File does not exist${NC}"
                fi
                echo ""

                let "test_no=test_no+1"
            done
        done
    done
done

echo "empty_test_no: ${empty_test_no}, exist_test_no: ${exist_test_no}"

}

echo "cleanup data dir ..."
echo "rm -rf ${data_dir}"
rm -rf ${data_dir}
echo "mkdir ${data_dir}"
mkdir ${data_dir}
echo "DONE"
echo ""

save_pd_aggr "control"
save_pd_aggr "ses_on"
#save_pd_aggr "ses_off"
