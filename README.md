
perfcollect
==============

Collects Linux system performance info for post processing and analysis.

It relies on iostat, and vmstat for data collection of performance
statistics.  

One of the main goals of this utility is to provide a simple way to 
capture system performance data for post processing.  The linux-perf2 
package can take the data from perfcollect and build charts using gnuplot

*perfcollect has been tested on RHEL 6.x*



Description
--------------
Perfcollect consists of serveral scripts.  The main script, **startcapture.sh** collects statistics on disk IO, memory, and cpu.  

*All of the scripts in perfcollect an be ran as a normal user.*

The default behaviour of running *startcapture.sh* without arguments

- will run for 24 hours  
- will generate logfiles ending in the filename of .dat  
- logfiles will be kept in the output directory */var/tmp/datacap*

The duration of the data collection can be specified to run for a specific number of hours with the -h argument. 

- The minumum incrmennt for data collection is 1 hour. 

**Important**

It is recommended to run the script using at(1) so that it can be ran in the background, allowing the user to disconnect from the system.  *Utilities like tmux or screen will also work.*

(example)
$ at now
> $HOME/perfcollect/startcapture.sh
> ^D
$


** Finding your data **
--------------

Upon completion the script archives up the logfiles in */var/tmp/datacap/done.tgz*

**Examples**
--------------

Capture data for 3 hours
./startcapture.sh -h 3

Capture data for 48 hours
./startcapture.sh -h 48

**Utilities**
--------------

There are several utility scripts provide to provide assistance.

*check.sh* 
- checks if the data collection processes are running.

*cleanup.sh*
- Stops data collection processes and removes invalid logfiles

*processcapture.sh*
- converts data files into *dat files
- this script automatically gets called from the startcapture.sh script
- use this when startcapture.sh gets interrupted and you want to process data

