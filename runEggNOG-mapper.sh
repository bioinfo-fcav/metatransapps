#!/bin/bash

file=$1

if [ ${file} ]; then
	echo "[ERROR] Missing input file" 2>&1
	exit
fi
if [ -e ${file} ]; then
	echo "[ERROR] Wrong input file (${file})" 2>&1
	exit
fi

output=$2

if [ ${output} ]; then
	echo "[ERROR] Missing output directory" 2>&1
	exit
fi
if [ -d ${output} ]; then
	mkdir -p ${output}
fi

emapper.py  -i ${file} \
		--output ${output}/ \
		--target_orthologs all \
		--sensmode ultra-sensitive \
		-m diamond \
		--evalue 0.00001 \
		--cpu 30 \
		--itype proteins \
		--target_taxa 2 \
		--tax_scope 2 \
		--override \
		--temp_dir /dev/shm/ \
		--report_orthologs \
		--go_evidence all \
		--query_cover 90 \
		--tax_scope_mode inner_narrowest

