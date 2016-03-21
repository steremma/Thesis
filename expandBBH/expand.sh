﻿#!/bin/bash
set -e

# There are 2 distinct parts in this process. First, expand the already existing profiles
# (both .blast and .bh) of the old organisms with matches to the new organisms. This only
# requires appending lines to already existing files.
# Second, create new .blast and .bh files for the new organisms against both old and new organisms.

# ATTENTION: I am assuming the existence of the BH_output and Blast_output
#            directories, filled with the already processed organisms.

# Check number of arguments.
if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
    echo "USAGE: expand.sh <newFastaDirectory> <oldFastaDirectory> <newOrgFile> <oldOrgFile>"
    exit 1
fi

# Check that BH_output and Blast_output do exist.
if [ ! -d "BH_output" ]; then
	echo "directory BH_output does not exist!"
	exit 1
fi
if [ ! -d "Blast_output" ]; then
	echo "directory Blast_output does not exist!"
	exit 1
fi

# Read arguments
NEW_FASTA_DIR=$1
OLD_FASTA_DIR=$2
NEW_ORGS=$3
OLD_ORGS=$4
# The Virtual Organization should be read as an additional argument.
VO="see"

# Combine old and new organism identifier files (GenomeOLD - GenomeNEW)
FULL_ORGS="GenomeBoth"
cat $OLD_ORGS $NEW_ORGS > $FULL_ORGS

# Combine old and new fasta files to create the full blast database (assuming the .faa extension).
NEW_DB="newDatabase.faa"
OLD_DB="oldDatabase.faa"
FULL_DB="fullDatabase.faa"
cat $NEW_FASTA_DIR/*.faa > $NEW_DB
cat $OLD_FASTA_DIR/*.faa > $OLD_DB
cat $OLD_DB $NEW_DB > $FULL_DB

# Blast and profile the old organisms vs the new database.
./submitAll.sh $NEW_DB $OLD_FASTA_DIR $NEW_ORGS $VO

# Blast and profile the new organisms vs the full database.
./submitAll.sh $FULL_DB $NEW_FASTA_DIR $FULL_ORGS $VO

# Clean up
rm $NEW_DB
rm $OLD_DB
rm $FULL_DB
