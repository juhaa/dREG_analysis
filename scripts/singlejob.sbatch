#!/bin/bash
#SBATCH -J dREG
#SBATCH --nodes=1
#SBATCH --cpus-per-task=40
#SBATCH --time=1-00:00:00
#SBATCH --mem=376G
#SBATCH --ntasks=1
#SBATCH -o dREG_slurm.out

# Active conda environment for dREG
conda activate dreg

# Set parameters for the run
THREADS=40 # Should be the same as "--cpus-per-task" value in slurm params
SCORE_TH=0.8 # Score threshold for passing sequences
MERGE_TH=500 # Merge threshold for proximal sequences
DREG_DIR=$HOME/dREG_analysis

MODEL=$DREG_DIR/model/v1.0.5/asvm.getTrainSet.RData

# Input bigWigs
BW_PLUS_FILE=$DREG_DIR/data/example_plus_fs1e20.bigWig
BW_MINUS_FILE=$DREG_DIR/data/example_minus_fs1e20.bigWig

# Output bedGraph and bed files
OUT_BEDGRAPH=$DREG_DIR/out/dREG_out.bedGraph
OUT_BED=$DREG_DIR/out/dREG_out.bed

# Run dREG
Rscript $DREG_DIR/scripts/run_dREG.R $MODEL $BW_PLUS_FILE $BW_MINUS_FILE $OUT_BEDGRAPH $THREADS

# Make bed file out of bedGraph
sh $DREG_DIR/scripts/writeBed_bedtools.sh -s $SCORE_TH -m $MERGE_TH -i $OUT_BEDGRAPH -o $OUT_BED

