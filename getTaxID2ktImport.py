#!/usr/bin/env python3

import warnings
warnings.filterwarnings("ignore")

import pandas as pd
import argparse

parser= argparse.ArgumentParser(add_help=False)
parser.add_argument("-h", "--help", action="help", default=argparse.SUPPRESS, help= "Parsing Standard Kraken Output Format with taxa names and convert to format input of Krona (ktImportTaxonomy) ") 
parser.add_argument("-i", help="-i: input file from kraken command: kraken2 --db (database path) --output (output - tabular file) --use-mpa-style --use-names (input - fasta file)", required = "True")
parser.add_argument("-o", help="-o: output with sequence id associated with taxid", required = "True")
args = parser.parse_args()


headers = my_names=['seq_classification', 'query_id', 'taxonomy', 'length', 'lca']
kdf = pd.read_csv(args.i, sep="\t", names=headers)
dftax = kdf[['query_id', 'taxonomy']]
dftax['taxid'] = pd.DataFrame(dftax['taxonomy'].str.replace(r'[^(]*\(|\)[^)]*', '').str.replace(r'taxid',''))

dftax.drop('taxonomy', inplace=True, axis=1)

dftax.to_csv(args.o, sep='\t', encoding='utf-8', index=False)



