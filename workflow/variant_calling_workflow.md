

```mermaid
flowchart TD
    A[Tumor FASTQ files] --> C[FastQC]
    B[Normal FASTQ files] --> C
    C --> D[Trimmomatic]
    D --> E[BWA Alignment]
    E --> F[SAMtools BAM Processing]
    F --> G[GATK Variant Calling]
    G --> H[BCFtools Filtering]
    H --> I[VCF Files]
    I --> J[Ensembl VEP Annotation]
    J --> K[Annotated Variants]
    K --> L[Variant Interpretation]
