#!/bin/bash

# input - diretório contendo os arquivos de entrada no formato .fastq
input=$1 
#Diretorio que contem os arquivos processados

reftrinity=$2
# Arquivo da montagem de novo Trinity.fa

# output - diretório para armazenar o resultado do processo de montagem
output=$3

refs=$4
# Diretorio que contem o proteoma de referencia mais proximo para ser utilizado como base

if [ ! ${input} ]
then   
	echo "[ERROR] Missing input directory (directory containing renamed *.fastq)." 1>&2
        exit
else   
        if [ ! -d ${input} ]
        then   
                echo "[ERROR] Wrong input directory ${input}." 1>&2
                exit
        fi
fi

if [ ! ${reftrinity} ]
then
        echo "[ERROR] Missing assembled fasta file." 1>&2
        exit
else
        if [ ! -e ${reftrinity} ]
        then
                echo "[ERROR] Wrong assembled fasta file  ${reftrinity}." 1>&2
                exit
        fi
fi


if [ ! ${refs} ]
then
        echo "[WARNING] Missing proteomic reference directory" 1>&2
else
        if [ ! -d ${refs} ]
        then
                echo "[ERROR] Wrong proteomic reference directory ${refs}" 1>&2
                exit
        fi
	
	rm -f ${refs}/Transrate_Reference_Proteome.faa
	for rp in `find ${refs} -type f -name '*_protein.faa'`; do
		echo "Reference proteome: ${rp}" 1>&2
		cat ${rp} >> ${refs}/Transrate_Reference_Proteome.faa
	done
	refprot="${refs}/Transrate_Reference_Proteome.faa"
fi


if [ ! ${output} ]
then   
        echo "[ERROR] Missing output directory" 1>&2
        exit
else   
        if [ ! -d ${output} ]
        then   
                echo "[ERROR] Wrong output directory ${output}" 1>&2
                exit
        fi
fi


num_threads=23
 


mkdir -p ${output}/Transrate

basedir_out="${output}/Transrate"


leftreads=()
rightreads=()

leftreads=( $( find ${input} -name '*_1.fastq' ) )
for r in ${leftreads[@]}; do
	r=`echo ${r} | sed 's/_1\./_2\./'`
	rightreads=(${rightreads[@]} ${r})
done

echo -e "Runnig Transrate"


refprotparam=""
if [ ${refprot} ]; then
	refprotparam=" --reference ${refprot} "
fi


transrate ${refprotparam} --assembly ${reftrinity} \
			  --left $(IFS=, ; echo "${leftreads[*]}") \
			  --right $(IFS=, ; echo "${rightreads[*]}") \
			  --threads ${num_threads} \
			  --output ${basedir_out}

grep '^>' ${basedir_out}/trinity_assembled.Trinity/good.trinity_assembled.Trinity.fasta | perl -lane 'my ($transcript_id)=$_; $transcript_id=~s/^>//; my ($gene_id)=$transcript_id=~/^(.*)_i\d+/; print join("\t", $gene_id,$transcript_id);' > ${basedir_out}/trinity_assembled.Trinity/good.trinity_assembled.Trinity.fasta.gene_trans_map
