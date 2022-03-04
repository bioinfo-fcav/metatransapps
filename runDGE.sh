#!/bin/bash

# diretório contendo os arquivos no formato .fastq
input=$1


if [ ! ${input} ]
then   
        echo "Missing input matrix"
        exit
else   
        if [ ! -e ${input} ]
        then   
                echo "Wrong input matrix file ${input}"
                exit
        fi
fi

controlgenes=$2


if [ ! ${controlgenes} ]
then   
        echo "Missing control genes file"
        exit
else   
        if [ ${controlgenes} != "NA" ]; then
		if [ ! -e ${controlgenes} ]
        	then   
                	echo "Wrong control genes file ${controlgenes}"
	                exit
        	fi
	fi		
fi

output=$3


if [ ! ${output} ]
then   
        echo "Missing output directory"
        exit
else   
        if [ ! -d ${output} ]
        then   
                echo "Wrong output directory ${output}"
                exit
        fi
fi

group=$4

if [ ! ${group} ]
then   
        echo "Missing groups file"
        exit
else   
        if [ ! -e ${group} ]
        then   
                echo "Wrong group file ${group}"
                exit
        fi
fi


refsample=$5

echo "Calculating Differentially Expressed Genes ..."

if [ ${controlgenes} != "NA" ]; then
	echo "Using Control genes file: ${controlgenes}"
	run-DESeq2.R 	--in=${input} \
			--groups=${group} \
			--out=${output} \
			--controlgenes=${controlgenes} \
			--refgroup=${refsample} \
		      	1> ${output}/run-DESeq2.log.out.txt \
			2> ${output}/run-DESeq2.log.err.txt
else	
	echo "Not using control genes file"
	run-DESeq2.R 	--in=${input} \
			--groups=${group} \
			--out=${output} \
			--refgroup=${refsample} \
		      	1> ${output}/run-DESeq2.log.out.txt \
			2> ${output}/run-DESeq2.log.err.txt
fi


