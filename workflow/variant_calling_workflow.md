

```mermaid
flowchart TD
    A[Tumor FASTQ files] --> C[FastQC]
    B[Normal FASTQ files] --> C
    C --> D[Trimmomatic]
    D --> E[BWA Alignment]
    E --> F[SAMtools BAM Processing]
    F --> G[GATK Variant Calling]
    G --> H[GATK Mutect2 Variant Calling]
    H --> I[BCFtools Filtering]
    I --> J[VCF Files]
    J --> K[Ensembl VEP Annotation]
    K --> L[Annotated Variants]
    L --> M[Variant Interpretation]
