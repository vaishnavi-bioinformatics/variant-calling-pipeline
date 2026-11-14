# Variant Calling – Results Summary

## 1. Somatic Variant Analysis

Somatic variant calling was performed using **GATK Mutect2** on matched tumor-normal whole-exome sequencing (WES) samples aligned to **GRCh37**.

### Candidate Variants

Three variants in DNA-damage response and tumor-suppressor genes (`TP53`, `ATR`) were prioritized for downstream analysis.

| Gene | Genomic Position (GRCh37) | Ref | Alt | Consequence | VEP Impact |
| :--- | :--- | :---: | :---: | :--- | :---: |
| **TP53** | `chr17:7578190` | `T` | `G` | Missense (`p.Tyr220Ser`) | `MODERATE` |
| **ATR** | `chr3:142188396` | `C` | `T` | Missense (`p.Arg2112His`) | `MODERATE` |
| **ATR** | `chr3:142238599` | Complex deletion | `C` | Splice acceptor-related | `HIGH` |

### Tumor-Normal Sequencing Evidence

| Gene | Tumor `DP` | Tumor `AD` (Ref, Alt) | AD-derived VAF | Normal `AD` (Ref, Alt) | Filter |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **TP53** | 133 | `74, 59` | **44.4%** | `87, 0` | `PASS` |
| **ATR** | 51 | `48, 3` | **5.88%** | `51, 0` | `PASS` |
| **ATR** | 231 | `227, 4` | **1.73%** | `170, 0` | `PASS` |



### Variant Interpretation

- **`TP53 p.Tyr220Ser`:** Demonstrated substantial alternate-read support (59 alternate reads; 44.4% AD-derived VAF) in the tumor sample. Franklin's computed classification was **Pathogenic**.
- **`ATR p.Arg2112His`:** Demonstrated low alternate-read support (3 alternate reads; 5.88% AD-derived VAF). Franklin's computed classification was **VUS** (Variant of Uncertain Significance).
- **`ATR` splice-related deletion:** Demonstrated very low alternate-read support (4 alternate reads; 1.73% AD-derived VAF), despite its `HIGH` predicted VEP impact. Franklin's computed classification was **VUS**.


---

## 2. Germline Variant Analysis

Germline variant calling was performed using **GATK HaplotypeCaller** on the matched normal sample.

Two variants were identified for downstream functional and clinical interpretation:

| Gene | Position (GRCh37) | Ref | Alt | Genotype | AD (Ref, Alt) | DP | VAF | Consequence |
|---|---|---|---|---|---|---:|---:|---|
| SDHB | chr1:17349159 | G | A | 0/1 | 35, 37 | 72 | 51.4% | Missense |
| COL14A1 | chr8:121220474 | G | A | 0/1 | 50, 40 | 90 | 44.4% | Missense |

Both variants showed heterozygous genotypes in the  annotation results.

### Variant Interpretation

- **`SDHB` (chr1:17349159 G>A):** A missense variant with a heterozygous genotype (`0/1`). The variant had 37 alternate reads out of 72 total reads, corresponding to an AD-derived VAF of 51.4%.

- **`COL14A1` (chr8:121220474 G>A):** A missense variant with a heterozygous genotype (`0/1`). The variant had 40 alternate reads out of 90 total reads, corresponding to an AD-derived VAF of 44.4%.


---

## 3. Functional & Clinical Annotation

- **Ensembl Variant Effect Predictor (VEP):** Used to annotate gene consequences, transcript effects, protein-level changes (`HGVSc`/`HGVSp`), variant identifiers, and available in-silico functional predictions.
- **Franklin by Genoox:** Used to review clinical variant classifications and supporting evidence under the ACMG/AMP framework.

---

## 4. Summary & Conclusions

- The analysis involved a matched tumor-normal WES workflow encompassing read quality control, alignment, somatic and germline variant calling, filtration, and functional annotation.
- Somatic prioritization highlighted a high-read-support candidate in **`TP53` (`p.Tyr220Ser`)**, alongside two low-VAF candidates in **`ATR`**.
- Germline analysis identified variants in **`COL14A1`** and **`SDHB`**.
- Integrating sequencing metrics (`AD`, `DP`, and AD-derived VAF) with functional predictions and clinical classification evidence helps avoid over-interpreting low-support variant calls.

