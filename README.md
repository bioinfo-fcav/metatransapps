# MetaTransApps
## Applications for MetaTranscriptomics Data Analysis

### Steps for Metatranscriptomic Analysis
<pre>
1. preprocess.sh			: perform RNA-Seq pre-processing steps (FastQC, Atropos, PrinSeq);
2. rnaseq-denovo.sh			: perform de novo assembly of RNA-Seq data using Trinity;
3. runTransrate.sh			: run transcriptome assembly quality evaluation using Transrate;
4. runTransDecoder.sh			: run proteome prediction from transcriptome assembly;
5. runBacMet2scan.sh			: run BacMet2 analysis;
6. runEggNOG-mapper.sh			: functional annotation based on EggNOG database;
7. mkTaxTable.sh			: make taxonomy table based on kraken analysis;
8. genGeneTaxTable.pl			: generate genus_gene_trans_map based on taxonomy table and original gene_trans_map;
9. getAbundMatrix.sh			: run Trinity auxiliary scripts to generate an abundance Matrix for metatranscriptomic assembly;
10. splitMatrixByGenusGenePrefix.pl	: split an abundance matrix by Genus-Gene information;
11. runDGE.sh				: run Differential Gene Expression Analyzes;
12. post-DESeq2.R			: perform the complementary analysis of DESeq2 results;
</pre>

### Software requirements

- Perl programming language (https://www.perl.org);
- Python programming language (https://www.python.org);
- R software environment (https://www.r-project.org);
- diamond aligner (https://github.com/bbuchfink/diamond);
- HMMER (http://hmmer.org);
- bioinfoutilities (https://github.com/dgpinheiro/bioinfoutilities);
- eggnog-mapper (https://github.com/eggnogdb/eggnog-mapper);
- kraken2 (https://ccb.jhu.edu/software/kraken2/index.shtml);
- Trinity (https://github.com/trinityrnaseq/trinityrnaseq);
- TransDecoder (https://github.com/TransDecoder/TransDecoder);
- Transrate (https://hibberdlab.com/transrate);
- BacMet scripts (https://github.com/ZhihaoXie/BacMet);
- DESeq2 (https://bioconductor.org/packages/release/bioc/html/DESeq2.html);

### Database requirements

- UniRef100 (https://www.uniprot.org/uniref/);
- Pfam (http://pfam.xfam.org/);
- BacMet (http://bacmet.biomedicine.gu.se);

