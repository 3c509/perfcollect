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
if [ ! -d ${OUTDIR} ]; then
  echo "Unable to find capture data, exiting"
  exit 1
fi

cd ${OUTDIR}

FOUND=0
for file in `ls -1  ${OUTDIR}/cur/*out`
do
  if [ `stat -c %s ${file}` -eq 0 ]; then 
    echo "removing ${file}"
    rm -f ${file}
    FOUND=1
  fi
done

if [ $FOUND -eq 0 ]; then
  echo "No files to delete"
fi

PROC=0
PROC=`ps -ef | grep ^$USER | egrep '(iostat|vmstat)' | grep -v grep | wc -l` 
if [ ${PROC} -gt 0 ]; then
  echo "Killing orphaned data collection processes.... "
  echo "=================================================="
  ps -ef | grep ^$USER | egrep '(iostat|vmstat)' | grep -v grep
  ps -ef | grep ^$USER | egrep '(iostat|vmstat)' | grep -v grep | awk '{print $2}' | xargs kill -9
fi

PROC=`ps -ef | grep ^$USER | egrep '(iostat|vmstat)' | grep -v grep | wc -l` 
if [ ${PROC} -eq 0 ]; then
  echo "No orphaned processes running"
else
  echo "Problem cleaning up orphaned processes"
fi

rm -f ${OUTDIR}/cur/.running

exit 0
