#!/bin/bash
#
# utility script to convert unprocessed files to dat (space separated values)
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

HOST=`hostname`
if [ ! -d ${OUTDIR}/done/${HOST} ]; then
  mkdir -p ${OUTDIR}/done/${HOST}
fi

# unprocessed files:  *.out
# processed files: *.dat

cd ${OUTDIR}/cur

for file in `ls -1 *out`
do
  if [ `stat -c %s ${file}` -gt 0 ]; then
    DAT=`echo ${file} | sed 's/.out/.csv/g'`
    cat ${file} | sed 's/ \+/ /g' | grep -v memory | grep -v free > ${OUTDIR}/done/${HOST}/$DAT
    echo "Processed ${file} as ${DAT}"
    mv ${file} ${OUTDIR}/raw 2>/dev/null
  fi
done

cd ${OUTDIR}/raw

for file in `ls -1 *out`
do
  if [ ! -f ${OUTDIR}/done/${HOST}/${file} ]; then
    if [ `stat -c %s ${file}` -gt 0 ]; then
      DAT=`echo ${file} | sed 's/.out/.dat/g'`
      cat ${file} | sed 's/ \+/ /g' | grep -v memory | grep -v free > ${OUTDIR}/done/${HOST}/$DAT
      echo "Processed ${file} as ${DAT}"
      mv -f ${file} ${OUTDIR}/raw 2>/dev/null
    fi
  fi
done

cd ${OUTDIR}
rm -f ${OUTDIR}/done_${HOST}.tgz
cd ${OUTDIR}/done
tar -cf - ./${HOST} | gzip -9c > ${OUTDIR}/done_${HOST}.tgz
echo "Packaged processed data in archive: ${OUTDIR}/done_${HOST}.tgz"

exit 0
