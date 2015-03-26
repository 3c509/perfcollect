#!/bin/bash
#
# captures disk, memory, and cpu performance statistics in to dat files for post processing
#
# script requires iostat, vmstat
#
# Usage:
#
# startcapture.sh 
#
#   without arguments it will capture data for 24 hours
#   you can override default capture period of 24 hours with an argument
#
# startcapture -h <# of hrs>
#

# data capture directory, leave as default if possible... if this is changed you must change the other scripts as well...
OUTDIR="/var/tmp/datacap"

HOST=`hostname`

###################################################################################################
#
#  DO NOT MODIFY BELOW HERE
#
###################################################################################################
rotateCursor()
{
  case $toggle
  in
    1)
      echo -n $1" \ "
      echo -ne "\r"
      toggle="2"
    ;;

    2)
      echo -n $1" | "
      echo -ne "\r"
      toggle="3"
    ;;

    3)
      echo -n $1" / "
      echo -ne "\r"
      toggle="4"
    ;;

    *)
      echo -n $1" - "
      echo -ne "\r"
      toggle="1"
    ;;
  esac
}

if [ ! -d ${OUTDIR}/done/${HOST} ]; then
  mkdir -p ${OUTDIR}/done/${HOST}
fi
mkdir -p ${OUTDIR}
mkdir -p ${OUTDIR}/cur
mkdir -p ${OUTDIR}/done
mkdir -p ${OUTDIR}/raw

# override with -h argument 

# Run every INTERVAL seconds
# Reccomendation:  60  (once a minute)
INTERVAL="60"

# Run for a total of COUNT times
# Reccomendation: 1440 (1 day ... assuming 60 second INTERVAL)
COUNT="1440"

while getopts ":h:" opt; do
  case $opt in
    h)
      NUMTEST=`echo $OPTARG | awk '$0 ~/[^0-9]/ { print "NOT_INTEGER" }'`
      if [ -z ${NUMTEST} ]; then
        if [ $OPTARG -gt 0 ]; then
          echo "Overiding defaults with custom duration: $OPTARG hr(s)" >&2
          INTERVAL="60"
          COUNT=`expr $OPTARG \* 60`
        fi
      elif [ ${NUMTEST} == "NOT_INTEGER" ]; then
        echo "Error: argument to -h must be a number"
        exit 1
      fi
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

DATESTR=`date +%d%b%Y-%H%M.%S`

which iostat 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
  echo "Unable to find iostat, exiting..."
  echo "Install program and/or adjust PATH variable"
  exit 1
fi

which vmstat 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
  echo "Unable to find vmstat, exiting..."
  echo "Install program and/or adjust PATH variable"
  exit 1
fi

TOTALSEC=`expr 60 \* ${COUNT}`
TOTALMIN=`expr ${TOTALSEC} / 60`
TOTALHRS=`expr ${TOTALMIN} / 60`

if [ -f ${OUTDIR}/cur/.running ]; then
  echo "Error: Data Collection is running, verify check.sh. If not running remove file: ${OUTDIR}/cur/.running"
  exit 1
fi

if [ ${TOTALMIN} -gt 90 ]; then
  echo "Starting data collection for ${TOTALHRS} hours at ${DATESTR}"
else 
  echo "Starting data collection for ${TOTALMIN} minutes at ${DATESTR}"
fi

# create semaphore to denote that data collection is running
touch ${OUTDIR}/cur/.running

# capture extended disk statistics 
iostat -dx ${INTERVAL} ${COUNT} | awk '/^sd/ {print strftime("%d_%b_%H:%M:%S"),$0}' > ${OUTDIR}/cur/${DATESTR}_iostat_dx.out  & 

# capture throughput disk statistics
iostat -dk ${INTERVAL} ${COUNT} | awk '/^sd/ {print strftime("%d_%b_%H:%M:%S"),$0}' > ${OUTDIR}/cur/${DATESTR}_iostat_dk.out  & 

# capture memory and cpu statistics
vmstat -a ${INTERVAL} ${COUNT} | awk '/^/ {print strftime("%d_%b_%H:%M:%S"),$0}' > ${OUTDIR}/cur/${DATESTR}_vmstat_a.out  &

COUNT=0
while [ ${COUNT} -lt ${TOTALSEC} ]
do
  rotateCursor "Processing data, please wait..."
  sleep 1
  COUNT=`expr 1 + ${COUNT}`
done
  
echo "Finished data collection at `date +%d%b%Y-%H%M.%S`"

cd ${OUTDIR}/cur

for file in `ls -1 ${DATESTR}*out`
do
  if [ `stat -c %s ${file}` -gt 0 ]; then
    DAT=`echo ${file} | sed 's/.out/.dat/g'`
    cat ${file} | sed 's/ \+/ /g' | grep -v memory | grep -v free > ${OUTDIR}/done/${HOST}/$DAT
    echo "Processed ${file} as ${OUTDIR}/done/${HOST}/${DAT}"
    mv -f ${file} ${OUTDIR}/raw 2>/dev/null
  fi
done

# clean up semaphore
rm -f ${OUTDIR}/cur/.running

cd ${OUTDIR}
rm -f ${OUTDIR}/done_${HOST}.tgz
cd ${OUTDIR}/done
tar -cvf - ./${HOST} | gzip -9c > ${OUTDIR}/done_${HOST}.tgz
echo "Packaged processed data in archive: ${OUTDIR}/done_${HOST}.tgz"

exit 0
