#!/bin/bash

# Command line utility for rx
# Written by Ryan Song

function checkHackRF() {
	hackrf_info | grep -i "Found HackRF" > temp.txt
	if [ $? -ne 0 ]; then
		echo "Error: HackRF device not found"
		rm temp.txt
		exit 1
	fi
	rm temp.txt
}

function generateLog() {
	mkdir -p logs
	dateStamp=$(date "+%F-%T")
	fileName=${dateStamp}_rx.log
	touch ./logs/$fileName
}

checkHackRF
generateLog
python ./python/endurosat_frame_rx.py | tee ./logs/$fileName


# Example getopts code in case commandline tool gets big enough that we need arguments
# function handleOptions() {
# 	# Call getopt to validate the provided input. 
# 	options=$(getopt -q -o le:d: --long help -- "$@")
# 	if [ $? -ne 0 ]; then 
#     	echo "Incorrect arguments provided. Run script with --help for more information"
#     	exit 1	
# 	fi
# 	eval set -- "$options"
# 	while true; do
#     	case "$1" in
#     		-l) freeSyncStatus
# 				shift;;
# 			-e)	enableFreeSync $2
# 				shift 2;;
# 			-d) disableFreeSync $2
# 				shift 2;;
# 			--help)
# 				helpMessage;
# 				shift;;
#     		--) shift
#   				break;;
#     	esac
# 	done
# 	exit 0;
# }