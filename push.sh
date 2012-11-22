#!/bin/bash

# Author: Gergely Fodemesi fgergo@gmail.com
# License: GNU GPL v2
# Original source: http://code.google.com/p/pusher/

# Usage
# on local fs:
#	tar cf - myfiletree|gzip|push.sh
# on Linux using ssh between remote file trees:
#	tar cf - myfiletree|gzip|ssh user@host "`cat push.sh`"
# on Windows in bash using plink (e.g. with saved session information) between remote file trees:
#	tar cf - myfiletree|gzip|plink -batch -load mysavedputtysession -m push.sh
# on Plan9: please reconsider.

# Description
#
# push.sh transfers and stores data received on
# standard input in:
# 	~/pushed/YYYY/MMDD/0/0.tar.gz
# where YYYY/MMDD/ represents the current date,
# similar to the plan9 dump filesystem.
# If ~/pushed/YYYY/MMDD/0/ already exists
# 1/1.tar.gz is created, if 1/ exists
# 2/2.tar.gz is created etc.

# On success sha256sum of transferred data is reported on stdout.

# Data on standard input shall practically be tarred and gzipped.
# To represent different pushed data, change $push_file_suffix below.

# Requirements
# 	locally: please have a look at the usage examples.
# 	on target OS: bash, sha256sum 

# Concurrency: safe for concurrent use.

# Planned features: none.

# Bugs: none. yet.

# Settings, change if needed.

# $pushed_home is the home directory for $pushed_root
pushed_home=~
# $pushed_root is the root directory of pushes
pushed_root=pushed
# $pushed_file_suffix is the default suffix of the pushed file
pushed_file_suffix=tar.gz
# $max_pushes is the maximum number of daily pushes
max_pushes=100

# End of settings

# Code starts here

# Exit on error
die() {
	echo "push.sh error: " $1
	exit 1
}

# Query current date for the directory structure
yyyy=`date +%Y`
mmdd=`date +%m%d`

# Walk to $pushed_home and create
# directories to store pushed file
cd $pushed_home
if [ "$?" -ne "0" ]; then
	die "could not walk to $pushed_home"
fi

mkdir $pushed_root 2> /dev/null
cd $pushed_root
if [ "$?" -ne "0" ]; then
	die "could not walk to $pushed_home/$pushed_root"
fi

mkdir $yyyy 2> /dev/null
cd $yyyy
if [ "$?" -ne "0" ]; then
	die "could not walk to $pushed_home/$pushed_root/$yyyy"
fi

mkdir $mmdd 2> /dev/null
cd $mmdd
if [ "$?" -ne "0" ]; then
	die "error: could not walk to $pushed_home/$pushed_root/$yyyy/$mmdd"
fi

# Begin critical section

# Create $pushed_file directory, repeat until created,
# or if tried for more than $max_pushes times.

for ((i=0; i<=$max_pushes; i++))
do
	try_file=$i
	mkdir $try_file 2> /dev/null
	if [ "$?" -eq "0" ]; then
		break
	fi
done
cd $try_file
if [ "$?" -ne "0" ]; then
	die "error: could not walk to $pushed_home/$pushed_root/$yyyy/$mmdd/$try_file/"
fi

# End critical section

# Store data read from stdin
cat - > $try_file.$pushed_file_suffix.part
if [ "$?" -ne "0" ]; then
	die "error: could not transfer data to $pushed_home/$pushed_root/$yyyy/$mmdd/$try_file/$try_file.$pushed_file_suffix.part"
fi

# Remove .part suffix
mv $try_file.$pushed_file_suffix.part $try_file.$pushed_file_suffix
if [ "$?" -ne "0" ]; then
	die "could not remove .part suffix from $try_file.$pushed_file_suffix.part"
fi

# Remove write access to transferred file and directory
chmod a-w $try_file.$pushed_file_suffix
if [ "$?" -ne "0" ]; then
	die "could not remove write access to $try_file"
fi

chmod a-w $pushed_home/$pushed_root/$yyyy/$mmdd/$try_file/
if [ "$?" -ne "0" ]; then
	die "could not remove write access to $pushed_home/$pushed_root/$yyyy/$mmdd/$try_file/"
fi

# Report sha256sum of transferred data to support integrity check after the transfer.
sha256sum $try_file.$pushed_file_suffix|awk '{print $1}'
