#!/bin/bash
#
# create-work-dir.sh 
#
# Support script for pulling the necessary files to a ready to
# use working directory in the local machine.
#
dir_path=$HOME/my_working_dir

# Create working directory with everything from run folder
cp -pr $OPENCOG_SOURCE_DIR/opencog/nlp/ull-parser/run $dir_path

# Copy configuration files
cp $OPENCOG_SOURCE_DIR/opencog/nlp/learn/run/config/* $dir_path/config/

# Copy shared run files
cp -pr $OPENCOG_SOURCE_DIR/opencog/nlp/learn/run/nonbreaking_prefixes $dir_path/
cp $OPENCOG_SOURCE_DIR/opencog/nlp/learn/run/split-sentences.pl $dir_path/
