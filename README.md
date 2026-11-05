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

# Whole Exome Sequencing (WES) Variant Calling and Annotation

## Project Overview

This project demonstrates a bioinformatics workflow for identifying, processing, filtering and annotating genetic variants from whole-exome sequencing (WES) data using a tumor-normal paired sample approach.

## Dataset Information

- **Study:** Breast cancer
- **Tumor sample:** SRR13857279
- **Normal sample:** SRR13857280
- **Sequencing type:** Whole Exome Sequencing (WES)
- **Reference genome:** GRCh37 / hg19

## Bioinformatics Workflow

| Step | Tool | Purpose |
|---|---|---|
| 1 | FastQC | Raw read quality assessment |
| 2 | Trimmomatic | Adapter and quality trimming |
| 3 | BWA | Reference genome alignment |
| 4 | SAMtools | BAM processing and indexing |
| 5 | GATK | Variant calling |
| 6 | BCFtools | Variant processing and filtering |
| 7 | Ensembl VEP | Functional variant annotation |

## Key Findings

- Processed tumor and matched normal sequencing data.
- Identified approximately 2,297 candidate somatic variants during the analysis.
- Investigated TP53 as a candidate somatic variant.
- Examined COL4A1 and SDHB among candidate germline findings.
- Performed functional annotation using Ensembl VEP.

## Skills Demonstrated

- Linux command-line operations
- NGS data processing
- Quality control and read trimming
- Sequence alignment
- Variant calling and filtering
- Tumor-normal variant analysis
- Functional annotation

## Project Status

Completed as an educational bioinformatics project.

## Disclaimer

This project is for educational and research-learning purposes. The findings are not intended for clinical diagnosis or treatment decisions.
