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
    -i | --input )   shift
                      input=$1
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

## Create bed files larger than the specified threshold.
echo "Converting $input"
prefix=$(echo $input | sed 's/.bedGraph//')

# Get peaks passing threshold.
awk 'BEGIN{OFS="\t"} ($4 > '"$score_th"') {print $1, $2-50, $3+50, $4}' $input | sort -k1,1 -k2,2n > $prefix.threshold_pass.bed

# Merge.
bedtools merge -i $prefix.threshold_pass.bed -d $merge_th > $prefix.threshold_pass.merge.bed

# Get max score in each peak.
bedtools map -a $prefix.threshold_pass.merge.bed -b $prefix.threshold_pass.bed -c 4 -o max | awk 'BEGIN{OFS="\t"} {print $1, $2, $3, "enhancer_"NR, $4}' > $prefix.bed

# Duplicate found transcripts to + and - strand
sed 's/$/\t-/' $input > minus
sed 's/$/\t+/' $input > plus
cat minus plus > $output

# Clean temporary files.  
rm -f $prefix.threshold_pass.bed $prefix.threshold_pass.merge.bed minus plus $prefix.bed

echo -e "\nDone"
