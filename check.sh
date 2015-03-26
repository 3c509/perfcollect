#!/bin/bash
#
# utility script to remove zero length files from aborted captures
#

# data capture directory
OUTDIR="/var/tmp/datacap"

##############################################################################
#
#  DO NOT MODIFY BELOW HERE
#
##############################################################################

PROC=0
PROC=`ps -ef | grep ^$USER | egrep '(iostat|vmstat)' | grep -v grep | wc -l` 
if [ ${PROC} -gt 0 ]; then
  echo "Found data collection processes... run cleanup.sh if you wish to abort them"
  echo "======================================================================================="
  ps -ef | grep ^$USER | egrep '(iostat|vmstat)' | grep -v grep
else
  echo "No data collection running"
fi

exit 0
