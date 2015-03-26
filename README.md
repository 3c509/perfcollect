#
# Linux performance collection utility   
#
#     Version 2
#
# -- Alex Theodore <atheodore@edgewit.com>
#
# Tested on RHEL 6.x
#

// Usage
The script startcapture.sh collects statistics on io, memory, and cpu.  The script can be ran as a normal user.  

By default the data collection runs for 24 hours.  It will generate several DAT files for post processing in the /var/tmp/datacap directory.  

The duration of the data collection can be modified with the -h argument.  This will allow you to specify a custom duration in hours.

(Example: capture data for 3 hours)
./startcapture.sh -h 3

It is recommended to run the script using at(1) so that it can be ran in the background, allowing the user to disconnect from the system.

(example)
$ at now
> $HOME/perfcollect/startcapture.sh
> ^D
$

Upon completion the script pacages up the DAT files in /var/tmp/datacap/done.tgz 

// Utilities
The script check.sh can be used to check if the data collection processes are running.

The script cleanup.sh can be used to stop data collection processes and remove zero length captured files.

The script processcapture.sh can be used to manually convert data files to DAT files.  The script also will create an archive of the processed data for transfer.  This is normally not required to be ran as the startcapture.sh will convert the data files.
