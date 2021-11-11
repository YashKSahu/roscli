#!/bin/bash

## Colours and font styles
## Syntax: echo -e "${FOREGROUND_COLOUR}${BACKGROUND_COLOUR}${STYLE}Hello world!${RESET_ALL}"

# Escape sequence and resets
ESC_SEQ="\x1b["
RESET_ALL="${ESC_SEQ}0m"
RESET_BOLD="${ESC_SEQ}21m"
RESET_UL="${ESC_SEQ}24m"

# Foreground colours
FG_BLACK="${ESC_SEQ}30m"
FG_RED="${ESC_SEQ}31m"
FG_GREEN="${ESC_SEQ}32m"
FG_YELLOW="${ESC_SEQ}33m"
FG_BLUE="${ESC_SEQ}34m"
FG_MAGENTA="${ESC_SEQ}35m"
FG_CYAN="${ESC_SEQ}36m"
FG_WHITE="${ESC_SEQ}37m"
FG_BR_BLACK="${ESC_SEQ}90m"
FG_BR_RED="${ESC_SEQ}91m"
FG_BR_GREEN="${ESC_SEQ}92m"
FG_BR_YELLOW="${ESC_SEQ}93m"
FG_BR_BLUE="${ESC_SEQ}94m"
FG_BR_MAGENTA="${ESC_SEQ}95m"
FG_BR_CYAN="${ESC_SEQ}96m"
FG_BR_WHITE="${ESC_SEQ}97m"

# Background colours (optional)
BG_BLACK="40m"
BG_RED="41m"
BG_GREEN="42m"
BG_YELLOW="43m"
BG_BLUE="44m"
BG_MAGENTA="45m"
BG_CYAN="46m"
BG_WHITE="47m"

# Font styles
FS_REG="0m"
FS_BOLD="1m"
FS_UL="4m"

#Error printing function
echo_error()
{
	echo -e "${FG_RED}$1${RESET_ALL}"
}
#echo_error "helo"

#Info printing function
echo_info()
{
	echo -e "${FG_GREEN}$1${RESET_ALL}"
}

ws=$(echo $ROS_PACKAGE_PATH | awk '{split($0,a,":"); print a[1]}') 
cd "$ws/$1"
echo -e "${FG_GREEN}Entered into ${FG_YELLOW}${PWD}${RESET_ALL}"

if [ -d "launch" ] ; then
	cd launch
	array=($(ls *.launch))
	pid_array=("${array[@]/*/-1}")
	#echo ${pid_array[@]}
	echo "Found these launch files:"
	echo "-------------------------"
	#echo ${array[@]}
	size=${#array[@]}
	for i in "${!array[@]}"; do 
  	printf "%s %s\n" " $((i+1)))" "${array[$i]}"
	done
	echo "-------------------------"
	echo "Enter 'q' to quit"
	while true ; do
		printf "Enter Choice: "
		read value
		if [ "$value" = "q" ] ; then
			#echo ${pid_array[@]}
			#Kill all childs and background processes at exit
			trap 'jobs -rp | xargs -r kill' EXIT
			exit		
		fi
		
		if (( value < 1 || value > size )) ; then
			#echo -e "${FG_RED}Invalid Input!!${RESET_ALL}"
			echo_error "Invalid Input!!"
		else
			if [ "${pid_array[value-1]}" = "-1" ] ; then
				echo_info " roslaunch $1 ${array[((value-1))]}"
				roslaunch $1 ${array[((value-1))]} 1> /dev/null 2>/dev/null &	
				pid=$!
				pid_array[value-1]=$pid	
			else
				kill_pid=${pid_array[value-1]}
				kill -INT $kill_pid	#GOD level
				pid_array[value-1]=-1
			fi
		fi
	done
	
else
	echo_error "$ws/$1/launch not found!!"
fi
