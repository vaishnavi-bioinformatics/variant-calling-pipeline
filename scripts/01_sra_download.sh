# Download SRA data 
prefetch SRR13857279
prefetch SRR13857280

# Convert SRA files to FASTQ 
fastq-dump --split-files SRR13857279
fastq-dump --split-files SRR13857280 



