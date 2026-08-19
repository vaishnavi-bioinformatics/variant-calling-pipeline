#!/bin/bash

#Somatic and Germline Variant Calling Pipeline

#SRA download 
prefetch SRR13857279
prefetch SRR13857279

#FASTQ conversion 
fastq-dump --split-files SRR13857279
fastq-dump --split-files SRR13857280

# Quality Control 
SRR13857279_1.fastq.gz SRR13857279_2.fastq.gz

# Trimming 
trimmomatic PE \
SRR13857279_1.fastq.gz SRR13857280_2.fastq.gz \
SRR13857279_1p.fastq.gz SRR13857279_1u.fastq.gz \
SRR13857280_2p.fastq.gz SRR13857280_2u.fastq.gz \
ILLUMINACLIP:adapters.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4 MINLEN:36

# Quality Control of trimmed pairend fastq files 
fastqc SRR13857279_1p.fastq.gz SRR13857280_2p.fastq.gz

# Alignment 
bwa mem hg19_NoChr.fa SRR13857279_1p.fastq.gz SRR13857280_2p.fastq.gz > sample.sam

#Convert SAM to BAM 
samtools view -b sample.sam -o sample.bam 

#Sort BAM
samtools sort sample.bam -o sample_sorted.bam 

#Index sorted BAM 
samtools index sample_sorted.bam 

#Add/Replace Read Groups 
gatk AddOrReplaceReadGroups \
I=sample_sorted.bam \
O=sample_add_rg.bam \
RGID=4 \
RGLB=lib1 \
RGPL=ILLUMINA \
RGPU=unit1 \
RGSM=20

#MarkDuplicates 
java -jar picard.jar MarkDuplicates \
I= sample_add_rg.bam \
O= sample_markdup.bam \
M= sample_metrics.txt

#Base Quality Score Recalibration 
# 1. Build recalibration table 
gatk BaseRecalibrator \
-R hg19.fa \
-I sample_markdup.bam \
--known-sites /home/BIB/Databases/GATK_Knownsites_HG37/1000_omni2.5.b37.vcf.gz \
--known-sites /home/BIB/Databases/GATK_Knownsites_HG37/dbsnp_138.b37.vcf.gz \
--known-sites /home/BIB/Databases/GATK_Knownsites_HG37/Mills_and_1000G_gold_standard.indels.b37.vcf.gz \
-O recal_data.table

# 2. Apply BQSR 

