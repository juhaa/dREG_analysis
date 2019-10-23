# dREG analysis scripts

This repository contains necessary packages, scripts, and a conda environment required for dREG analysis.

R packages included in this repo:

* [dREG version 1.0.5](https://github.com/Danko-Lab/dREG/tree/6571b7df142efeb7d8beb894b487b4b1cb829d17/dREG)
* [bigWig](https://github.com/andrelmartins/bigWig/tree/d25a16e4c853c8fe3a59151820c9f1ace924cbd6/bigWig)

## Installation

A conda environment is provided for installing most of the dependencies. More information about conda: <https://docs.conda.io/en/latest/>

```bash
git clone https://github.com/juhaa/dREG_analysis.git
cd dREG_analysis/
conda env create -f dreg_environment.yml
conda activate dreg
R CMD INSTALL R_packages/bigWig/
R CMD INSTALL R_packages/dREG/
```

Additionally, [HOMER](http://homer.ucsd.edu/homer/index.html) is required for creating bigWig files from tagdirs.

```bash
conda install -c bioconda homer
```

### Notes
* Tested on Linux
* OS X seems to have problems when installing bigWig package, possibly related to the Clang compiler

## Usage

### Step 1: Creating bigWigs

```bash
tagdir=/my/tagdir/
chrom=/my/chromInfo.txt
sh scripts/createBigWigsFromTagdir.sh -i $tagdir -c $chrom
```

### Step 2: Run dREG (SLURM)

Set correct parameters in (`scripts/singlejob.sbatch`) and then run

```bash
sbatch scripts/singlejob.sbatch
```

## References
[Danko, C. G., Hyland, S. L., Core, L. J., Martins, A. L., Waters, C. T., Lee, H. W., ... & Siepel, A. (2015). Identification of active transcriptional regulatory elements from GRO-seq data. Nature methods, 12(5), 433-438.](https://www.nature.com/articles/nmeth.3329)
