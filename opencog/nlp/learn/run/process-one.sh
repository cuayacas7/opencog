#!/bin/bash
#
# process-one.sh <mode> <lang> <filename> <cogserver-host> <cogserver-port>
#
# Support script for batch parsing of plain-text files.
# Sentence-split one file, submit it, via perl script, to the parser.
# When done, move the file over to a 'finished' directory.
#
# Example usage:
#    ./process-one.sh mst en Barbara localhost 17001
#

# Set up assorted constants needed to run.
lang=$2
filename="$3"
coghost="$4"
cogport=$5
splitter=./split-sentences.pl
splitdir=split-articles


# Gets mode of counter for the cogserver
case $1 in
   pairs)
      subdir=submitted-articles
      observe="observe-text"
      ;;
   mst)
      subdir=mst-articles
      observe="observe-mst"
      ;;
   mst-extra)
      subdir=mst-articles
      observe="observe-mst-extra"
      ;;
esac


# Punt if the cogserver has crashed. The grep is looking for the
# uniquely-named config file.
# haveserver=`ps aux |grep cogserver |grep opencog-$lang`
# if [[ -z "$haveserver" ]] ; then
# 	exit 1
# fi
# Alternate cogserver test: use netcat to ping it.
haveping=`echo foo | nc $coghost $cogport`
if [[ $? -ne 0 ]] ; then
	exit 1
fi

# Split the filename into two parts
base=`echo $filename | cut -d \/ -f 1`
rest=`echo $filename | cut -d \/ -f 2-6`

echo "Processing file >>>$rest<<<"


# Create directories if missing
mkdir -p $(dirname "$splitdir/$rest")
mkdir -p $(dirname "$subdir/$rest")

# Sentence split the article itself
cat "$filename" | $splitter -l $lang >  "$splitdir/$rest"

# Submit the split article
cat "$splitdir/$rest" | ./submit-one.pl $coghost $cogport $observe

# Punt if the cogserver has crashed (second test,
# before doing the mv and rm below)
# haveserver=`ps aux |grep cogserver |grep opencog-$lang`
# if [[ -z "$haveserver" ]] ; then
# 	exit 1
# fi
haveping=`echo foo | nc $coghost $cogport`
if [[ $? -ne 0 ]] ; then
	exit 1
fi

# Move article to the done-queue
mv "$splitdir/$rest" "$subdir/$rest"
rm "$base/$rest"
