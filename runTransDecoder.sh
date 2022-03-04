#!/bin/bash

Transcripts=$1
if [ ! ${Transcripts} ]; then
	Transcripts=./output/transrate/trinity_assembled.Trinity/good.trinity_assembled.Trinity.fasta
fi
Map=$2
if [ ! ${Map} ]; then
	Map=./output/transrate/trinity_assembled.Trinity/good.trinity_assembled.Trinity.fasta.gene_trans_map
fi
if [ ! ${Outdir} ]; then
	Outdir=./output/TransDecoder
fi	

if [ ! -e ${Transcripts} ]; then
	echo "[ERROR] File (${Transcripts}) not found!" 2>&1
	exit
fi
if [ ! -e ${Map} ]; then
	echo "[ERROR] File (${Map}) not found!" 2>&1
	exit
fi

uniprot=/data/db/uniprot/uniref100_prok_cleaned.dmnd
pfam=/data/db/pfam/Pfam-A.hmm

if [ ! -e ${uniprot} ]; then
	echo "[ERROR] File (${uniprot}) not found!" 2>&1
	exit
fi
if [ ! -e ${pfam} ]; then
	echo "[ERROR] File (${pfam}) not found!" 2>&1
	exit
fi

## modo de execução:  ./runTransDecoder.sh ./output/transrate/trinity_assembled.Trinity/good.trinity_assembled.Trinity.fasta ./output/transrate/trinity_assembled.Trinity/good.trinity_assembled.Trinity.fasta.gene_trans_map ./output/TransDecoder

TransDecoder.LongOrfs -m 60 -t ${Transcripts} --gene_trans_map ${Map} --output_dir ${Outdir}

diamond blastp --query ${Outdir}/longest_orfs.pep --db ${uniprot} --max-target-seqs 1 --outfmt 6 --evalue 0.00001 --threads 20 --out ${Outdir}/longest_orfs_uniprot.tsv

hmmscan --cpu 20 --domtblout /data/sbjulia/output/TransDecoder/longest_orfs_pfam.domtblout ${pfam} ${Outdir}/longest_orfs.pep

TransDecoder.Predict -t ${Transcripts} --retain_long_orfs_length 900 --retain_blastp_hits ${Outdir}/longest_orfs_uniprot.tsv --retain_pfam_hits ${Outdir}/longest_orfs_pfam.domtblout --single_best_only --output_dir ${Outdir}

