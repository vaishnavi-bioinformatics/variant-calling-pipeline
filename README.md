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

## Workflow 

STEP 1: Data Download 

Tool : fastq-dump 

Download the raw sequencing data from the NCBI SRA.

STEP 2: Quality Control -

Tool : FastQC

Assessing the raw sequencing reads, including per base sequence quality,Per tile sequence quality,Per sequence quality scores,Per base sequence content,Per sequence GC content,Per base N content,
Sequence Length Distribution,Sequence Duplication Levels,Overrepresented sequences,Adapter Content.

STEP 3: Quality trimming - 

Tool : Trimmomatic 

removes adapter and low-quality sequences - low quality bases, ambiguous nucleotides and short reads.

STEP 4: Alignment -

Tool - BWA 

BWA (Burrows-Wheeler Aligner) is the industry-standard software package for mapping low-divergent sequencing reads against a large reference genome (like human hg19).

STEP 5: Converting SAM file to BAM file - 

Tools - SAMTOOLS 

SAM files are converted to BAM files as they are compressed, binary versions of SAM files.

STEP 6: Sort the BAM File -

Tools - SAMTOOLS 

BAM file is sorted by the genomic coordinates,Sorting organizes them by chromosome and genomic position.

STEP 7: Index the BAM File -

Tools - SAMTOOLS 

Indexing creates a companion .bai file (input_sorted.bam.bai), which allows tools to quickly jump to any genomic region without reading the entire file.

STEP 8: AddOrReplaceReadGroups

Tools - AddOrReplaceReadGroups 

The AddOrReplaceReadGroups tool is specifically used to add, fix, or replace Read Group (RG) metadata in the BAM file.

STEP 9: marked duplicates

Tools - picard MarkDuplicates

The duplicates are marked and the duplication rate is given in the metrices.txt file 
