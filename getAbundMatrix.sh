#!/bin/bash

if [ ! ${TRINITY_HOME} ]; then
        echo "Missing TRINITY_HOME environment variable" 2>&1
        exit
else   
        if [ ! -d ${TRINITY_HOME} ]
        then   
                echo "Wrong TRINITY_HOME directory ${TRINITY_HOME} in this environment variable"
                exit
        fi
fi

# diretório contendo os arquivos no formato .fastq
input=$1


if [ ! ${input} ]
then   
        echo "Missing input reads (renamed for Trinity) directory"
        exit
else   
        if [ ! -d ${input} ]
        then   
                echo "Wrong input reads (renamed for Trinity) directory ${input}"
                exit
        fi
fi



trinity_output=$2



if [ ! ${trinity_output} ]
then   
        echo "Missing Trinity output directory"
        exit
else   
        if [ ! -d ${trinity_output} ]
        then   
                echo "Wrong Trinity output directory ${trinity_output}"
                exit
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

refsample=$4

REFSAMPLE_PARAM=""
if [ ${refsample} ]; then
	REFSAMPLE_PARAM=" --reference_sample ${refsample}"
fi	

trinity_trans_map=$5

if [ ${trinity_trans_map} ]; then
	if [ ! -e ${trinity_trans_map} ]; then
		echo "[ERROR] Wrong gene_trans_map (${trinity_trans_map})" 1>&2
		exit
	fi
fi

num_threads=16

# Arquivos e diretórios de saída (output) 
# Criando a variável para o diretório de saída:

abundance_out="${output}/abundance_salmon_kraken_gene_trans_map"

mkdir -p ${abundance_out}

# Criando as variáveis para as reads1 (left) e reads2(right):

left=()
right=()

echo "Collecting reads step ..."


left=($(find ${input} -type f -name '*.atropos_final.prinseq.cleaned_1.fastq'))



rm -f ${abundance_out}/samples.txt
rm -f ${abundance_out}/quant_files.txt
rm -f ${abundance_out}/groups.txt
rm -f ${abundance_out}/DE_analysis_samples.txt

echo -e "id\tname\tgroup" > ${abundance_out}/groups.txt

for l in ${left[@]}; do
	#echo ${l}
	repname=`basename ${l} | sed 's/.atropos_final.prinseq.cleaned_1.fastq//'`
	#echo ${repname}
	condname=`echo ${repname} | sed 's/_B[0-9]\+.*$//'`
	#echo ${condname}
	r=`echo ${l} | sed 's/_1./_2./'`

	if [ ! -e ${r} ]; then
		echo "Not found ${r} paired with (${l})"
		exit
	fi

	right=(${right[@]} ${r})
		
	echo -e "${condname}\t${abundance_out}/${repname}\t${l}\t${r}" >> ${abundance_out}/samples.txt
	echo -e "${abundance_out}/${repname}/quant.sf" >> ${abundance_out}/quant_files.txt
	echo -e "${repname}\t${repname}\t${condname}" >> ${abundance_out}/groups.txt
	echo -e "${condname}\t${repname}" >> ${abundance_out}/DE_analysis_samples.txt
done

echo " * LEFT: " ${left[*]}
echo "---"
echo " * RIGHT: " ${right[*]}



trinity_output=`dirname ${trinity_output}/Trinity.timing`
trinity_fasta=`find ${trinity_output} -type f -name '*.Trinity.fasta' | head -1`

if [ ! ${trinity_trans_map} ]; then
	trinity_trans_map=`find ${trinity_output} -type f -name '*.Trinity.fasta.gene_trans_map' | head -1`
fi


if [ ! -e "${trinity_fasta}" ]; then
	trinity_fasta="${trinity_output}.Trinity.fasta"
	if [ ! -e "${trinity_fasta}" ]; then
		echo "Error: Not found *Trinity.fasta in ${trinity_output}"
		exit;
	fi
fi

if [ ! -e "${trinity_trans_map}" ]; then
	trinity_trans_map="${trinity_output}.Trinity.fasta.gene_trans_map"
	
	if [ ! -e "${trinity_trans_map}" ]; then
		echo "Error: Not found Trinity.fasta,gene_trans_map in ${trinity_output}"
		exit;
	fi
fi

echo "Assembly(fasta)..........: " ${trinity_fasta}
echo "Assembly(gene_trans_map).: " ${trinity_trans_map}

echo "Estimating abundances ..."


${TRINITY_HOME}/util/align_and_estimate_abundance.pl 	--transcripts	${trinity_fasta} \
							--est_method	salmon \
							--samples_file	${abundance_out}/samples.txt \
							--gene_trans_map ${trinity_trans_map} \
							--prep_reference \
							--thread_count ${num_threads} \
							--seqType fq \
							--output_dir ${abundance_out} \
							--SS_lib_type RF \
							 > ${abundance_out}/align_and_estimate_abundance.log.out.txt \
							 2> ${abundance_out}/align_and_estimate_abundance.log.err.txt


echo "Constructing abundance matrix ..."


${TRINITY_HOME}/util/abundance_estimates_to_matrix.pl	--est_method salmon \
							--gene_trans_map ${trinity_trans_map} \
							--name_sample_by_basedir \
							--cross_sample_norm none \
							--quant_files ${abundance_out}/quant_files.txt \
							--out_prefix ${abundance_out}/abundance \
							 > ${abundance_out}/abundance_estimates_to_matrix.log.out.txt \
							2> ${abundance_out}/abundance_estimates_to_matrix.log.err.txt 



