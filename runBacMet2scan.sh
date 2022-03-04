#!/bin/bash

## file >> trinity.transdecoder.cleaned.pep


infile=$1

if [ ! ${infile} ]; then
        echo "Missing input file" 2>&1
        exit
else   
        if [ ! -e ${infile} ]
        then   
                echo "Wrong input file" 2>&1
                exit
        fi
fi


outdir=$2

if [ ! ${outdir} ]; then
        echo "Missing output directory" 2>&1
        exit
else   
        if [ ! -d ${outdir} ]
        then   
		echo "Wrong output directory (${outdir})" 2>&1
                exit
        fi
fi


if [ ! ${BACMET_HOME} ]; then
        echo "Missing BACMET_HOME environment variable" 2>&1
        exit
else   
        if [ ! -d ${BACMET_HOME} ]
        then   
                echo "Wrong BACMET_HOME directory ${BACMET_HOME} in this environment variable"
                exit
        fi
fi

if [ ! -d ${BACMET_HOME}/BacMet2_PRE ]
then   
	echo "Not found BacMet2_PRE directory on (${BACMET_HOME})" 2>&1
	exit
fi

if [ ! -d ${BACMET_HOME}/BacMet2_EXP ]
then   
	echo "Not found BacMet2_EXP directory on (${BACMET_HOME})" 2>&1
	exit
fi


mkdir -p ${outdir}/BacMet2_EXP
mkdir -p ${outdir}/BacMet2_PRE

perl ${BACMET_HOME}/BacMet-Scan_v1.1.pl -i ${infile} -o ${outdir}/BacMet2_PRE/BacMet2_PRE -d ${BACMET_HOME}/BacMet2_PRE -diamond -protein -cpu 20 -all -columns all

perl ${BACMET_HOME}/BacMet-Scan_v1.1.pl -i ${infile} -o ${outdir}/BacMet2_EXP/BacMet2_EXP -d ${BACMET_HOME}/BacMet2_EXP -diamond -protein -cpu 20 -all -columns all

# summary
#pre

python3 ${BACMET_HOME}/bacmet_class_summary.py ${outdir}/BacMet2_PRE/BacMet2_PRE.table > ${outdir}/BacMet2_PRE/pre_bacmet_class_count.txt

Rscript ${BACMET_HOME}/ar_class_barplot.R ${outdir}/BacMet2_PRE/pre_bacmet_class_count.txt ${outdir}/BacMet2_PRE/pre_bacmet_class_count 

#exp

python3 ${BACMET_HOME}/bacmet_class_summary.py ${outdir}/BacMet2_EXP/BacMet2_EXP.table > ${outdir}/BacMet2_EXP/exp_bacmet_class_count.txt

Rscript ${BACMET_HOME}/ar_class_barplot.R ${outdir}/BacMet2_EXP/exp_bacmet_class_count.txt ${outdir}/BacMet2_EXP/exp_bacmet_class_count
