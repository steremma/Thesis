#!/bin/bash
set -e
# This script collects output from all grid jobs
# I assume the existence of multiple
# directories named: steremma_<identifier>, each of them containing
# 1 blast (.blast extension) and 1 phylogenetic (.bh extension) output file.

if [ "$#" -ne 1 ]; then
    echo "USAGE: collect_output.sh <organisms.txt>"
    E_ARGS=85
    exit $E_ARGS
fi

ORGANISMS=$1

mkdir -p Blast_output
mkdir -p BH_output

mv `find jdl_collection/steremma_* -name "*.blast"` Blast_output/
mv `find jdl_collection/steremma_* -name "*.bh"` BH_output/

rm -r jdl_collection/steremma_*

if [ ! -d "BH_output" ]; then
	echo "directory BH_output does not exist!"
	exit 1
fi

cd BH_output
for file in `ls`; do
	if [[ $file == *.bh ]]; then
		stripped_file="${file%.*}"
		echo $stripped_file
		awk -v var="$stripped_file" '{F=substr($0,23,8);print >> var"_"F".bh";close(F)}' $file
		rm $file
	fi
done
cd ..

# Combine BH files to create BBH files. Default output directory is BBH/ .
javac javaTools/combineBH/*.java
java javaTools/combineBH/CombineBH BH_output $ORGANISMS



