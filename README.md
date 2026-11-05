# variant-calling-pipeline

#somatic and germline  variant calling pipeline 

## project overview 

In this project i analyzed tumor-normal data to identify germline and somatic variants.The analysis included quality control,trimming,alignment,variant calling,variant filtering , VEP annotation and functional interpretation.

### Dataset 

- Data source : NCBI Sequence Read Archive (SRA) 
- Data type : Whole-exome sequencing (WXS)
- Samples : Tumor and normal
- SRA accessions - SRR13857279 & SRR13857280
- Reference genome : GRCh37/hg19
- Variant analyses : Somatic and germline Variant calling

# Somatic and Germline Variant Calling Pipeline

A complete bioinformatic workflow designed for paired tumor-normal whole-exome sequencing (WXS) data analysis, following GATK best practices. This pipeline takes raw sequencing data from the NCBI Sequence Read Archive (SRA) through quality control, alignment, pre-processing, variant calling, filtering, and functional annotation.

---

##  Project Overview

* **Data Source:** NCBI Sequence Read Archive (SRA)
* **Data Type:** Whole-Exome Sequencing (WXS)
* **Samples:** Tumor (`SRR13857279`) & Matched Normal (`SRR13857280`)
* **Reference Genome:** GRCh37 / hg19
* **Variant Analyses:** Somatic & Germline Variant Calling

---

##  Prerequisites & Dependencies

Ensure the following tools are installed and available in your system's `PATH` (or managed via Conda/Docker):

* `sratoolkit` (>= 2.11)
* `FastQC` (>= 0.11)
* `Trimmomatic` (>= 0.39)
* `bwa` (>= 0.7.17)
* `samtools` (>= 1.12)
* `picard` (>= 2.25)
* `gatk4` (>= 4.2)
* `ensembl-vep` (>= 104)

---

##  Repository Structure

```text
├── scripts/
│   ├── 01_download.sh
│   ├── 02_fastqc.sh
│   ├── 03_trimmomatic.sh
│   ├── 04_bwa_align.sh
│   ├── 05_sam_to_bam.sh
│   ├── 06_sort_bam.sh
│   ├── 07_index_bam.sh
│   ├── 08_add_read_groups.sh
│   ├── 09_mark_duplicates.sh
│   ├── 10_bqsr.sh
│   ├── 11_germline_calling.sh
│   ├── 12_mutect2_somatic.sh
│   └── 13_vep_annotation.sh
├── data/          # Input/Output data directories (git-ignored)
└── README.md
