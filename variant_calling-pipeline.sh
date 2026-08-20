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
-R hg19_NOChr.fa \
-I sample_markdup.bam \
--known-sites /home/BIB/Databases/GATK_Knownsites_HG37/1000_omni2.5.b37.vcf.gz \
--known-sites /home/BIB/Databases/GATK_Knownsites_HG37/dbsnp_138.b37.vcf.gz \
--known-sites /home/BIB/Databases/GATK_Knownsites_HG37/Mills_and_1000G_gold_standard.indels.b37.vcf.gz \
-O sample_recal_data.table
# 2. Apply BQSR 
gatk ApplyBQSR \
-I SAMPLE_markdup.bam \
-R /home/BIB/Databases/HumanGenome_HG37/hg19_NOChr.fa \
--bqsr-recal-file sample_recal_data.table \
-O sample_recal.bam

#index
samtools index sample_recal.bam

#variant calling by HaplotypeCaller - for GERMLINE mutations
-I SRR13857280_recal.bam \
-R hg19_NOChr.fa \
-O SRR13857279.vcf.gz &

#variant calling by Mutect2 - for SOMATIC mutations 
 gatk Mutect2 \
-R hg19_NOChr.fa \
-I SRR13857279_recal.bam \
-I SRR13857280_recal.bam \
-tumor  sm value \
-normal sm value \
-O somatic.vcf.gz &

#gatk filteration - for somatic 
gatk GetPileupSummaries \
-I SRR13857279_recal.bam \
-V mutect2/small_exac_common_3.vcf.gz \
-L mutect2/small_exac_common_3.vcf.gz \
-O tumor_pileups.table 
##gatk filteration - for germline
gatk GetPileupSummaries \
-I SRR13857280_recal.bam \
-V mutect2/small_exac_common_3.vcf.gz \
-L mutect2/small_exac_common_3.vcf.gz \
-O normal_pileups.table

#CalculateContamination
gatk CalculateContamination \
-I tumor.pileups.table \
-matched normal.pileups.table \
-O contamnation.table \
--tumor-segmentation segments.table 

# somatic filteration - 

# filtermutectcalls - for somatic 
gatk FilterMutectCalls \
  -R hg19_NoChr.fa \
  -V somatic.unfiltered.vcf.gz \
  --contamination-table contamination.table \
  --tumor-segmentation segments.table \
  -O somatic.filtered.vcf.gz

  #selectvariants 
  gatk SelectVariants \
  -R hg19_NoChr.fa \
  -V somatic.filtered.vcf.gz \
  --exclude-filtered \
  -O somatic.PASS.vcf.gz

 #Normalize VCF variants
  bcftools norm -m -both somatic.filtered.pass.vcf -o somatic.filtered.split.pass.vcf
  #Filter VCF 
  bcftools view -e 'ALT="*"' somatic.filtered.split.pass.vcf  -o somatic.filtered.split.filter.pass.vcf
 
# germline filteration 
# SelectVariants - SNP 
 gatk SelectVariants \
-R hg19_NOChr.fa \
-V SAMPLE.vcf.gz \
-select-type SNP \
-O SAMPLE.snps.vcf.gz
#SelectVariant - INDEL
gatk SelectVariants \
-R hg19_NOChr.fa \
-V SAMPLE.vcf.gz \
-select-type INDEL \
-O SAMPLE.indels.vcf.gz
# VariantFilteration - SNP 
 gatk VariantFiltration \
-R hg19_NOChr.fa \
-V SAMPLE.snps.vcf.gz \
-O SAMPLE.snps.filtered.vcf.gz \
--filter-name "QD2" --filter-expression "QD < 2.0" \
--filter-name "FS60" --filter-expression "FS > 60.0" \
--filter-name "MQ40" --filter-expression "MQ < 40.0" \
--filter-name "SOR3" --filter-expression "SOR > 3.0" \
--filter-name "MQRankSum-12.5" --filter-expression "MQRankSum < -12.5" 
--filter-name "ReadPosRankSum-8" --filter-expression "ReadPosRankSum < -8.0"

# VariantFilteration - INDELS 
 gatk VariantFiltration \
-R  hg19_NOChr.fa \
-V SAMPLE.indels.vcf.gz \
-O SAMPLE.indels.filtered.vcf.gz \
--filter-name "QD2" --filter-expression "QD < 2.0" \
--filter-name "FS200" --filter-expression "FS > 200.0" \
--filter-name "SOR10" --filter-expression "SOR > 10.0" \
--filter-name "ReadPosRankSum-20" --filter-expression "ReadPosRankSum < -20.0"

#SelectVariants - SNPS
 gatk SelectVariants \
-V SAMPLE.snps.filtered.vcf.gz \
--exclude-filtered true \
-O SAMPLE.snps.pass.vcf.gz
#SelectVariants - INDELS
gatk SelectVariants \
-V SAMPLE.indels.filtered.vcf.gz \
--exclude-filtered true \
-O SAMPLE.indels.pass.vcf.gz

#Merging SNPS and INDELS vcf.gz files 
gatk MergeVcfs \
-I SAMPLE.snps.pass.vcf.gz \
-I SAMPLE.indels.pass.vcf.gz \
-O SAMPLE.germline.pass.vcf.gz

#Normalize VCF variants 
bcftools norm -m -both Sample_PASS.vcf -o Sample.split.pass.vcf
#Filter VCF 
bcftools view -e 'ALT="*"' Sample.split.pass.vcf  -o Sample.split.filter.pass.vcf





