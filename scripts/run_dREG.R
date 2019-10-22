## Detection of Regulatory DNA Sequences using GRO-seq data.
## dREG

args <- commandArgs(T)

# Pre-trained model
load(as.character(args[1]))

# bigWigs
plusFile <- as.character(args[2])
minusFile <- as.character(args[3])

# Output
outFile <- as.character(args[4])

# number of CPUs
cpus <- as.numeric(args[5])

library(dREG)

# Scan all positions in the genome for informative ones (here we use the default values)
#
# Parameters:
#
# bw_path: String indicating file path to bigwig file representing the plus strand.
# bw_minus_path: String indicating file path to bigwig file representing the minus strand,
#   If specified, takes the windows that pass the step in both bigWig files.(intersection)
# depth: Integer value indicating minimum number of reads to return.
# window: Integer value indicating window distance between to search for #depth reads [bp].
# step: Integer value indicating step distance for window list.
# use_OR: Logical value indicating if the center positions in minus bigwig file are merged into the results.
#   If false, the intersection operation will be performed to the center positions of plus bigwig and from minus bigwig.
# use_ANDOR: Logical value indicating if the center positions will be merged from the two results.
#   a) Intersection operation with the conditions: window interval=1000 depth>=0.
#   b) Union operation with with the conditions: window interval=100 depth >=2.
# debug: Logical value indication the process detail is outputted.

inf_positions <- get_informative_positions(bw_path = plusFile, bw_minus_path = minusFile, depth = 0, window = 400,
                                          step = 50, use_OR = F, use_ANDOR = T, debug = T)

cat("Number of informative gene loci: ", nrow(inf_positions), "\n")

# Evaluate regulatory potential
#
# Parameters:
#
# gdm: Genomic data model return by 'genomic_data_model'.
# asvm: A pre-trained SVM model from the e1071 package returned by 'regulatory_svm'.
# positions: Data frame with 2 columns indicating the universe of positions to test and evaluate(chrom,chromCenter).
#   It can be returned by 'get_informative_positions'.
# bw_plus_path: String value indicating file path to bigWig file representing the plus strand.
# bw_minus_path: String value indicating file path to bigWig file representing the minus strand.
# batch_size: Number of positions to evaluate at once (more might be faster, but takes more memory).
# ncores: Number of CPU cores in parallel computing.
# use_rgtsvm: Indictating whether the predict will be performed on GPU through the Rgtsvm package.
# debug: Logical value indicating the process detail is outputted.

system.time(pred_val <- eval_reg_svm(gdm = gdm, asvm = asvm, positions = inf_positions,
                                        bw_plus_path = plusFile, bw_minus_path = minusFile,
                                        batch_size = 50000, ncores = cpus, use_rgtsvm = F, debug = T))

final_data <- data.frame(inf_positions, pred_val)
options("scipen"=100, "digits"=4)
write.table(final_data, outFile, row.names = F, col.names = F, quote = F, sep = "\t")


