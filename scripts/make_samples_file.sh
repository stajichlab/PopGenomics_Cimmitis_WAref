#!/usr/bin/bash -l
echo "STRAIN,FILEBASE" > samples.csv
pushd input
ls *_1.fastq.gz | perl -p -e 's/((\S+)_1\.fastq\.gz)/$2,$2_[12].fastq.gz/' >> ../samples.csv
