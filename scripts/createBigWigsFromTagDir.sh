#!/bin/bash

usage()
{
  echo "usage: createBigWigsFromTagdir.sh [[-i tagdir_folder] [-c chromInfo] [-o output_folder]]"
}

input=
output=
chrom=

while [ "$1" != "" ]; do
  case $1 in
    -i | --input )    shift
                      input=$1
                      ;;
    -o | --output )   shift
                      output=$1
                      ;;
    -c | --chrom )    shift
                      chrom=$1
                      ;;
    -h | --help )     usage
                      exit
                      ;;
    * )               usage
                      exit 1
  esac
  shift
done

if [ ! -d "$input" ]; then
  echo "Input tagdir folder not found"
  exit 1
fi

if [ ! -e "$chrom" ]; then
  echo "Chromatin info not found"
  exit 1
fi

if [ "$output" == "" ]; then
  output=$input
fi

name=${input##*/}

out_plus=${output}/${name}_plus_fs1e20.bigWig
out_minus=${output}/${name}_minus_fs1e20.bigWig

makeUCSCfile $input -o $out_plus -bigWig $chrom -noadj -fsize 1e20 -strand +
makeUCSCfile $input -o $out_minus -bigWig $chrom -noadj -fsize 1e20 -strand -

echo -e "\nDone."
