#!/bin/bash

indir=$1
#/data/sbjulia/outdir/abundance/DEG/abundance.isoform.counts.matrix.CTL_vs_CR3.DESeq2.DE_results
annotation=$2
outdir=$3
#OBS: Tive que adicionar nome ID para a primeira coluna (IDS das isoformas)
kraken_out=/data/sbjulia/output/kraken.out


# validação do parâmetro "indir"
if [ ! ${indir} ]
then   
        echo "[ERROR] Missing Differential Expression Genes directory." 1>&2
        exit
else   
        if [ ! -d ${indir} ]
        then   
                echo "[ERROR] Wrong input directory (${indir})." 1>&2
                exit
        fi
fi


# validação do parâmetro "annotation"
if [ ! ${annotation} ] 
then
        echo "[ERROR] Missing emapper annotation file." 1>&2
        exit
else
        if [ ! -f ${annotation} ]
        then
                echo "[ERROR] Wrong input file (${annotation})." 1>&2
                exit
        fi
fi


# validação do parâmetro "outdir"
if [ ! ${outdir} ] 
then
        echo "[ERROR] Missing output directory." 1>&2
	exit
fi

mkdir -p ${outdir}

if [ ! ${kraken_out} ]
then
        echo "[ERROR] Missing kraken output annotation file." 1>&2
        exit
else
        if [ ! -f ${kraken_out} ]
        then
                echo "[ERROR] Wrong input file (${kraken_out})." 1>&2
                exit
        fi
fi


cut -f2,3 ${kraken_out} | sed '1i ID\tTAXA'> ${outdir}/kraken.cleaned

for file in `ls ${indir}/*results`; do

	bn=`basename $(echo ${file} | sed -e 's/abundance.isoform.counts.matrix.//' -e 's/.DESeq2.DE_results//')`

	mergeR.R --x="${outdir}/kraken.cleaned" \
		 --y="${file}" \
		 --by.x="ID" \
		 --by.y="ID" \
		 --out="${outdir}/${bn}.tmp" \
		 --colnames.x="ID,TAX" \
		 --colnames.y="ID,sampleA,sampleB,baseMeanA,baseMeanB,baseMean,log2FoldChange,lfcSE,stat,pvalue,padj" \
	 	 --print.out.label

	
	mergeR.R --x="${outdir}/${bn}.tmp" \
                 --y="${annotation}" \
                 --by.x="ID" \
                 --by.y="query" \
                 --out="${outdir}/${bn}_table.csv" \
                 --colnames.x="ID,TAXA,sampleA,sampleB,baseMeanA,baseMeanB,baseMean,log2FoldChange,lfcSE,stat,pvalue,padj"\
                 --colnames.y="query,seed_ortholog,evalue,score,eggNOG_OGs,max_annot_lvl,COG_category,Description,Preferred_name,GOs,EC,KEGG_ko,KEGG_Pathway,KEGG_Module,KEGG_Reaction,KEGG_rclass,BRITE,KEGG_TC,CAZy,BiGG_Reaction,PFAMs" \
                 --print.out.label

#rm -f ${outdir}/${bn}.tmp

done
