#!/usr/bin/bash

usage()
{
  echo "usage: writeBed_bedtools.sh [[-s score_threshold] [-m merge_threshold] [-i input_bedgraph] [-o output_bed]]"
}

input=
score_th=0.8
merge_th=500
output=dREG_out.bed

while [ "$1" != "" ]; do
  case $1 in
    -s | --score_th ) shift
                      score_th=$1
                      ;;
    -m | --merge_th ) shift
                      merge_th=$1
                      ;;
    -i | --input )    shift
                      input=$1
                      ;;
    -o | --output )   shift
                      output=$1
                      ;;
    -h | --help )     usage
                      exit
                      ;;
    * )               usage
                      exit 1
  esac
  shift
done

if [ ! -e "$input" ]; then
  echo "Input bedGraph not found"
  exit 1
fi

echo "Input: $input"
echo "Output: $output"
echo "Score threshold: $score_th"
echo "Merge threshold: $merge_th"

## Create bed files larger than the specified threshold.
echo "Converting bedGraph to bed"
prefix=$(echo $input | sed 's/.bedGraph//')

# Get peaks passing threshold.
awk 'BEGIN{OFS="\t"} ($4 > '"$score_th"') {print $1, $2-50, $3+50, $4}' $input | sort -k1,1 -k2,2n > $prefix.threshold_pass.temp.bed

# Merge.
bedtools merge -i $prefix.threshold_pass.temp.bed -d $merge_th > $prefix.threshold_pass.merge.temp.bed

# Get max score in each peak.
bedtools map -a $prefix.threshold_pass.merge.temp.bed -b $prefix.threshold_pass.temp.bed -c 4 -o max | awk 'BEGIN{OFS="\t"} {print $1, $2, $3, "enhancer_"NR, $4}' > $prefix.temp.bed

# Duplicate found transcripts to + and - strand
sed 's/$/\t-/' $prefix.temp.bed > minus.temp.bed
sed 's/$/\t+/' $prefix.temp.bed > plus.temp.bed
cat minus.temp.bed plus.temp.bed > $output

# Clean temporary files.  
rm -f $prefix.threshold_pass.temp.bed $prefix.threshold_pass.merge.temp.bed minus.temp.bed plus.temp.bed $prefix.temp.bed

echo -e "\nDone."
