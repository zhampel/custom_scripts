#!/bin/bash

# Setup tunnel to named machine
function ipytunnel {
  # Input machine name
  machine=$1
  if [ ${machine} ];
  then
    ssh -N -f -L localhost:8888:localhost:8889 ${machine}
  else
    echo "Please provide a machine into which to ssh."
  fi
}

# Find process running tunnel to kill
function ipyfind {
  # Process id
  id=`ps aux | grep 'ssh' | awk '/localhost/{print$2}'`
  # Process full info
  info=`ps aux | grep 'ssh' | awk '/localhost/{print}'`

  # Only if id found, return
  if [ ${id} ];
  then
    echo -e "Process id: \t\t\c"
    echo ${id}

    echo -e "Process info: \t\t\c"
    echo ${info}
  fi
}

# Kill process
function ipykill {
  # Process id
  process_id=`ps aux | grep 'ssh' | awk '/localhost/{print$2}'`
  # Only if id found, then ask to kill
  if [ ${process_id} ];
  then
    echo -e "Kill process ${process_id}? [Y,n] \c"
    read DO_IT
    if [[ ${DO_IT} == "Y" || ${DO_IT} == "y" ]]; then
            echo "Killing ${process_id}"
            kill -9 ${process_id}
    else
            echo "Not killing ${process_id}"
    fi
  else
    echo "No running tunnel process to kill."
  fi

}
