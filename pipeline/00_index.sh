#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 2 --mem 2gb --out logs/index.log

module load samtools
module load bwa
if [ -f config.txt ]; then
	source config.txt
fi
FASTAFILE=$REFGENOME

## THIS IS FUNGIDB DOWNLOAD PART
echo "working off $FASTAFILE - check if these don't match may need to update config/init script"

if [[ ! -f $FASTAFILE.fai || $FASTAFILE -nt $FASTAFILE.fai ]]; then
	samtools faidx $FASTAFILE
fi
if [[ ! -f $FASTAFILE.bwt || $FASTAFILE -nt $FASTAFILE.bwt ]]; then
	bwa index $FASTAFILE
fi

DICT=$(dirname $FASTAFILE)/$(basename $FASTAFILE .fasta)".dict"

if [[ ! -f $DICT || $FASTAFILE -nt $DICT ]]; then
	rm -f $DICT
	samtools dict $FASTAFILE > $DICT
	# sometimes GATK/picard wants XXX.fasta.dict and XXX.dict
	ln -s $(basename $DICT) $(dirname $FASTAFILE)/$(basename $FASTAFILE).dict 
fi
grep ">" $FASTAFILE | perl -p -e 's/>((Chr)?(\d+|mito)_\S+)\s+.+/$1,$3/' > $(dirname $FASTAFILE)/chrom_nums.csv

