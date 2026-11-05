# Variant Calling Pipeline – Commands and Methodology

This document describes the command-line workflow used for tumor-normal whole-exome sequencing (WES) variant analysis.

## 1. SRA Data Download

Download the sequencing data using SRA Toolkit.

```bash
prefetch SRR13857279
prefetch SRR13857280
```

## 2. FASTQ Conversion

Convert SRA files into paired-end FASTQ files.

```bash
fastq-dump --split-files --gzip SRR13857279
fastq-dump --split-files --gzip SRR13857280
```

Expected files:

- SRR13857279_1.fastq.gz
- SRR13857279_2.fastq.gz
- SRR13857280_1.fastq.gz
- SRR13857280_2.fastq.gz

## 3. Raw Read Quality Control

Tool: FastQC

Assess the quality of raw sequencing reads.

```bash
fastqc SRR13857279_1.fastq.gz SRR13857279_2.fastq.gz

fastqc SRR13857280_1.fastq.gz SRR13857280_2.fastq.gz
```

## 4. Adapter Trimming and Quality Filtering

Tool: Trimmomatic v0.39

Remove adapter contamination and low-quality bases.

**Tumor sample**

```bash
trimmomatic PE \
SRR13857279_1.fastq.gz SRR13857279_2.fastq.gz \
SRR13857279_1p.fastq.gz SRR13857279_1u.fastq.gz \
SRR13857279_2p.fastq.gz SRR13857279_2u.fastq.gz \
ILLUMINACLIP:adapters.fa:2:30:10 \
LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
```

**Normal sample**

```bash
trimmomatic PE \
SRR13857280_1.fastq.gz SRR13857280_2.fastq.gz \
SRR13857280_1p.fastq.gz SRR13857280_1u.fastq.gz \
SRR13857280_2p.fastq.gz SRR13857280_2u.fastq.gz \
ILLUMINACLIP:adapters.fa:2:30:10 \
LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
```

## 5. Post-trimming Quality Control

Assess the quality of the paired trimmed reads.

```bash
fastqc SRR13857279_1p.fastq.gz SRR13857279_2p.fastq.gz

fastqc SRR13857280_1p.fastq.gz SRR13857280_2p.fastq.gz
```

## 6. Reference Genome Alignment

Tool: BWA

Align trimmed paired-end reads against the human reference genome.

**Tumor sample**

```bash
bwa mem hg19_NoChr.fa \
SRR13857279_1p.fastq.gz \
SRR13857279_2p.fastq.gz \
> tumor.sam
```

**Normal sample**

```bash
bwa mem hg19_NoChr.fa \
SRR13857280_1p.fastq.gz \
SRR13857280_2p.fastq.gz \
> normal.sam
```

## 7. SAM to BAM Conversion

Tool: SAMtools

```bash
samtools view -b tumor.sam -o tumor.bam

samtools view -b normal.sam -o normal.bam
```

## 8. BAM Sorting and Indexing

```bash
samtools sort tumor.bam -o tumor_sorted.bam

samtools sort normal.bam -o normal_sorted.bam

samtools index tumor_sorted.bam

samtools index normal_sorted.bam
```

## 9. Read Group Assignment

Tool: GATK AddOrReplaceReadGroups

Assign sample-specific read groups.

**Tumor**

```bash
gatk AddOrReplaceReadGroups \
-I tumor_sorted.bam \
-O tumor_rg.bam \
-RGID 1 \
-RGLB lib1 \
-RGPL ILLUMINA \
-RGPU unit1 \
-RGSM Tumor
```

**Normal**

```bash
gatk AddOrReplaceReadGroups \
-I normal_sorted.bam \
-O normal_rg.bam \
-RGID 2 \
-RGLB lib1 \
-RGPL ILLUMINA \
-RGPU unit2 \
-RGSM Normal
```

## 10. Duplicate Marking

Tool: Picard MarkDuplicates

Identify and mark duplicate sequencing reads.

**Tumor**

```bash
java -jar picard.jar MarkDuplicates \
I=tumor_rg.bam \
O=tumor_markdup.bam \
M=tumor_metrics.txt
```

**Normal**

```bash
java -jar picard.jar MarkDuplicates \
I=normal_rg.bam \
O=normal_markdup.bam \
M=normal_metrics.txt
```

## 11. Base Quality Score Recalibration (BQSR)

Tool: GATK

Use known variant databases for base quality score recalibration.

Reference and known-sites files must be compatible with the reference genome and its contig naming convention.

### 12.1 Build recalibration table

**Tumor**

```bash
gatk BaseRecalibrator \
-R hg19_NoChr.fa \
-I tumor_markdup.bam \
--known-sites 1000_omni2.5.b37.vcf.gz \
--known-sites dbsnp_138.b37.vcf.gz \
--known-sites Mills_and_1000G_gold_standard.indels.b37.vcf.gz \
-O tumor_recal_data.table
```

**Normal**

```bash
gatk BaseRecalibrator \
-R hg19_NoChr.fa \
-I normal_markdup.bam \
--known-sites 1000_omni2.5.b37.vcf.gz \
--known-sites dbsnp_138.b37.vcf.gz \
--known-sites Mills_and_1000G_gold_standard.indels.b37.vcf.gz \
-O normal_recal_data.table
```

### 12.2 Apply BQSR

**Tumor**

```bash
gatk ApplyBQSR \
-R hg19_NoChr.fa \
-I tumor_markdup.bam \
--bqsr-recal-file tumor_recal_data.table \
-O tumor_recal.bam
```

**Normal**

```bash
gatk ApplyBQSR \
-R hg19_NoChr.fa \
-I normal_markdup.bam \
--bqsr-recal-file normal_recal_data.table \
-O normal_recal.bam
```

Index recalibrated BAM files.

```bash
samtools index tumor_recal.bam
samtools index normal_recal.bam
```

## 13. Germline Variant Calling

Tool: GATK HaplotypeCaller

Identify candidate germline variants from the normal sample.

```bash
gatk HaplotypeCaller \
-R hg19_NoChr.fa \
-I normal_recal.bam \
-O normal.germline.vcf.gz
```

## 14. Somatic Variant Calling

Tool: GATK Mutect2

Identify candidate somatic variants by comparing tumor and matched normal samples.

```bash
gatk Mutect2 \
-R hg19_NoChr.fa \
-I tumor_recal.bam \
-I normal_recal.bam \
-tumor Tumor \
-normal Normal \
-O somatic.unfiltered.vcf.gz
```

The tumor and normal sample names must match the SM values assigned in the read groups.

## 15. Somatic Variant Filtering

### 15.1 GetPileupSummaries

Estimate allele frequencies using a suitable common-variant resource.

**Tumor**

```bash
gatk GetPileupSummaries \
-I tumor_recal.bam \
-V small_exac_common_3.vcf.gz \
-L small_exac_common_3.vcf.gz \
-O tumor_pileups.table
```

**Normal**

```bash
gatk GetPileupSummaries \
-I normal_recal.bam \
-V small_exac_common_3.vcf.gz \
-L small_exac_common_3.vcf.gz \
-O normal_pileups.table
```

### 15.2 CalculateContamination

```bash
gatk CalculateContamination \
-I tumor_pileups.table \
-matched normal_pileups.table \
-O contamination.table \
--tumor-segmentation segments.table
```

### 15.3 FilterMutectCalls

```bash
gatk FilterMutectCalls \
-R hg19_NoChr.fa \
-V somatic.unfiltered.vcf.gz \
--contamination-table contamination.table \
--tumor-segmentation segments.table \
-O somatic.filtered.vcf.gz
```

### 15.4 Select PASS variants

```bash
gatk SelectVariants \
-R hg19_NoChr.fa \
-V somatic.filtered.vcf.gz \
--exclude-filtered true \
-O somatic.PASS.vcf.gz
```

## 16. Somatic VCF Normalization

Tool: BCFtools

Split multiallelic records and normalize variants against the reference genome.

```bash
bcftools norm \
-f hg19_NoChr.fa \
-m -both \
somatic.PASS.vcf.gz \
-Oz \
-o somatic.normalized.vcf.gz

bcftools index somatic.normalized.vcf.gz
```

Remove spanning deletion alleles if required for downstream analysis.

```bash
bcftools view \
-e 'ALT="*"' \
somatic.normalized.vcf.gz \
-Oz \
-o somatic.final.vcf.gz
```

## 17. Germline Variant Filtering

### 17.1 Select SNPs

```bash
gatk SelectVariants \
-R hg19_NoChr.fa \
-V normal.germline.vcf.gz \
-select-type SNP \
-O normal.snps.vcf.gz
```

### 17.2 Select INDELs

```bash
gatk SelectVariants \
-R hg19_NoChr.fa \
-V normal.germline.vcf.gz \
-select-type INDEL \
-O normal.indels.vcf.gz
```

### 17.3 SNP Variant Filtration

```bash
gatk VariantFiltration \
-R hg19_NoChr.fa \
-V normal.snps.vcf.gz \
-O normal.snps.filtered.vcf.gz \
--filter-name "QD2" --filter-expression "QD < 2.0" \
--filter-name "FS60" --filter-expression "FS > 60.0" \
--filter-name "MQ40" --filter-expression "MQ < 40.0" \
--filter-name "SOR3" --filter-expression "SOR > 3.0" \
--filter-name "MQRankSum-12.5" --filter-expression "MQRankSum < -12.5" \
--filter-name "ReadPosRankSum-8" --filter-expression "ReadPosRankSum < -8.0"
```

### 17.4 INDEL Variant Filtration

```bash
gatk VariantFiltration \
-R hg19_NoChr.fa \
-V normal.indels.vcf.gz \
-O normal.indels.filtered.vcf.gz \
--filter-name "QD2" --filter-expression "QD < 2.0" \
--filter-name "FS200" --filter-expression "FS > 200.0" \
--filter-name "SOR10" --filter-expression "SOR > 10.0" \
--filter-name "ReadPosRankSum-20" --filter-expression "ReadPosRankSum < -20.0"
```

### 17.5 Select PASS SNPs and INDELs

```bash
gatk SelectVariants \
-R hg19_NoChr.fa \
-V normal.snps.filtered.vcf.gz \
--exclude-filtered true \
-O normal.snps.pass.vcf.gz
```

```bash
gatk SelectVariants \
-R hg19_NoChr.fa \
-V normal.indels.filtered.vcf.gz \
--exclude-filtered true \
-O normal.indels.pass.vcf.gz
```

### 17.6 Merge SNP and INDEL VCF Files

```bash
gatk MergeVcfs \
-I normal.snps.pass.vcf.gz \
-I normal.indels.pass.vcf.gz \
-O normal.germline.pass.vcf.gz
```

## 18. Germline VCF Normalization

```bash
bcftools norm \
-f hg19_NoChr.fa \
-m -both \
normal.germline.pass.vcf.gz \
-Oz \
-o normal.germline.normalized.vcf.gz

bcftools index normal.germline.normalized.vcf.gz
```

## 19. Functional Variant Annotation

Tool: Ensembl Variant Effect Predictor (VEP)

Annotate the processed variants to identify their predicted functional consequences.

Reference assembly: GRCh37.

Annotation can include:
- Gene and transcript information
- Consequence terms
- Amino acid changes
- Existing variant identifiers
- Clinical significance where available


## 20. Notes

- Tumor and normal samples were processed separately before paired somatic variant calling.
- HaplotypeCaller was used for germline variant identification.
- Mutect2 was used for tumor-normal somatic variant analysis.
- Variant filtering and functional annotation were performed as separate stages.
- Reference genome and known-sites database compatibility are essential for reproducibility.

