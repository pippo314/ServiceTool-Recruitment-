#! /bin/bash

# This script reads the services from services.txt saves them into an array ss[]
# so that each service is bing to a unique numeric code. The services are then shown
# with the code and the status and here the user can choose to press the number 
# of a service and decide to start it, stop it or go back to the services list.

# to run this script over ssh, openssh-server or similar must be installed on the remote
# machine

# I couldn't satisfy the requirement of auto-refreshing the services infos so 
# I decided to have a button to manually refresh the list from the file.

declare -a ss
separator="==================================="
format="%-15s %8s %10s\n"

function readFile () {
  N=0
  while read -r line; do
    ss[N++]=$line
  done < services.txt
}

function manageService () {
  # argument 1 is the code of the service
  while true; do
    clear -x
    echo "Service management"
    echo "${separator}${separator}"
    echo ${ss[$1]} "service is:" $(systemctl is-active ${ss[$1]})"."
    echo -e "\nPress 1 to start it, 2 to stop it, q to return to previous menu."
    read -n 1 -s code
    case $code in
      1)
        sudo systemctl start ${ss[$1]}
        ;;
      2)
        systemctl stop ${ss[$1]}
        ;;
      q)
        return
        ;;
      *)
        echo "Invalid input."
        ;;
    esac
  done
}

readFile

while true; do
  clear
  printf "$format" "Service" "Number" "Status"
  printf "%s\n" $separator
  for (( i=0; i<N; i++))
  do
    printf "$format" ${ss[i]} $(($i+1)) $(systemctl is-active ${ss[i]})
  done
  echo -e "\nPress the service number you want to manage, q to exit or r to refresh."
  read -n 1 -s input
  if [[ $input == "q" ]]
  then
    break
  elif [[ $input == "r" ]]
  then
    readFile
    echo "Refreshing..."
    sleep 0.9
  elif [[ $input -le $N ]]
  then
    manageService $(( $input - 1))
  else
    echo "Incorrect input, try again."
    sleep 1
  fi
done
