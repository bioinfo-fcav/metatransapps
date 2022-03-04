#!/bin/bash
#
#              INGLÊS/ENGLISH
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  http://www.gnu.org/copyleft/gpl.html
#
#
#             PORTUGUÊS/PORTUGUESE
#  Este programa é distribuído na expectativa de ser útil aos seus
#  usuários, porém NÃO TEM NENHUMA GARANTIA, EXPLÍCITAS OU IMPLÍCITAS,
#  COMERCIAIS OU DE ATENDIMENTO A UMA DETERMINADA FINALIDADE.  Consulte
#  a Licença Pública Geral GNU para maiores detalhes.
#  http://www.gnu.org/copyleft/gpl.html
#
#  Copyright (C) 2019  Universidade Estadual Paulista "Júlio de Mesquita Filho"
#
#  Universidade Estadual Paulista "Júlio de Mesquita Filho" (UNESP)
#  Faculdade de Ciências Agrárias e Veterinárias (FCAV)
#  Laboratório de Bioinformática (LB)
#
#  Daniel Guariz Pinheiro
#  dgpinheiro@gmail.com
#  http://www.fcav.unesp.br 
#

#infile=./output/transrate/trinity_assembled.Trinity/good.trinity_assembled.Trinity.fasta
#outdir=./output/
#./mkTaxTable.sh ${infile} ${outdir} ./output/matrix_data/Taxonomy_table2.csv


kraken_in=$1

if [ ! ${kraken_in} ]; then
	echo "Missing fasta file !" 1>&2
	exit
fi
if [ ! -e ${kraken_in} ]; then
	echo "Wrong fasta file (${kraken_in}) !" 1>&2
	exit
fi

kraken_out=$2

if [ ! ${kraken_out} ]; then
	echo "Missing kraken output directory !" 1>&2
	exit
fi
if [ ! -d ${kraken_out} ]; then
	echo "Wrong kraken output directory (${kraken_out}) !" 1>&2
	exit
fi

kraken2 --output ${kraken_out}/kraken.out \
	--use-mpa-style \
	--memory-mapping \
	--use-names \
	--threads 20 \
	--report ${kraken_out}/kraken.report \
	${kraken_in}

taxon_table=$3

if [ ! ${taxon_table} ]; then
	echo "Missing taxonomy table output file !" 1>&2
	exit
fi

TAXID_TMPFILE=`mktemp /tmp/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`

./getTaxID2ktImport.py -i ${kraken_out}/kraken.out -o ${TAXID_TMPFILE}
awk 'NR == 1; NR > 1 {print $0 | "sort -u"}' ${TAXID_TMPFILE} > ${TAXID_TMPFILE}.sorted.unique
mv ${TAXID_TMPFILE}.sorted.unique ${TAXID_TMPFILE}

TAXON_TMPFILE=`mktemp /tmp/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`

cut -f2 ${TAXID_TMPFILE} | sed '1d' | sort -u | taxonkit lineage | taxonkit reformat -r "Unassigned" -f "{k}\t{p}\t{c}\t{o}\t{f}\t{g}\t{s}" | cut -f 1,3-9 | sed '1i taxid\tkingdom\tphylum\tclass\torder\tfamily\t\genus\tspecie' > ${TAXON_TMPFILE}

MERGER_TMPFILE=`mktemp /tmp/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`

mergeR.R --x=${TAXON_TMPFILE} --by.x="taxid" --y=${TAXID_TMPFILE} --by.y="taxid" --out=${MERGER_TMPFILE} --print.out.label

perl -F"\t" -lane ' INIT { our @header; } if ($.==1) { @header=split(/\t/, $_); for my $i (0..$#header) { $header[$i]=~s/query_id/#TAXONOMY/; } print join("\t", "#TAXONOMY", "kingdom", "phylum", "class", "order", "family", "genus", "specie"); } else { my %data; @data{@header}=split(/\t/, $_); { print join("\t", @data{"#TAXONOMY", "kingdom", "phylum", "class", "order", "family", "genus", "specie" }); } } ' ${MERGER_TMPFILE} > ${taxon_table}

rm -f ${TAXID_TMPFILE}
rm -f ${TAXON_TMPFILE}
rm -f ${MERGER_TMPFILE}
