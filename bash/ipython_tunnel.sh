#!/bin/bash

# Setup tunnel to named machine
function ipytunnel {
  # Input is IP or machine name alias (from .ssh/config)
  machine=$1
  [ "${machine}" ] && \
  ssh -N -f -L localhost:8888:localhost:8889 ${machine} || \
  echo "Please provide a valid machine into which to ssh."
}

# Find process running tunnel to kill
function ipyfind {
  # Process id
  process_id=`ps aux | grep 'ssh' | awk '/localhost/{print$2}'`
  # Process full info
  process_info=`ps aux | grep 'ssh' | awk '/localhost/{print}'`

  #[ "${1}" ] && echo ${process_info} | grep '${1}'
  
  # Only if id found, return
  { [ "${process_id}" ] && echo -e "Process id: \t\t\c" && echo ${process_id} && \
  echo -e "Process info: \t\t\c" && echo ${process_info}; } || \
  echo "No relevant processes found."
}

# Kill process
function ipykill {
  # Process id via input or from listed processes
  [ "${1}" ] && process_id=${1} || process_id=`ps aux | grep 'ssh' | awk '/localhost/{print$2}'`

  # If process id not provided or not found running, then nothing to do.
  [ ! "${process_id}" ] || [ ! `ps aux | awk '{print $2 }' | grep ${process_id}` ] && \
  echo "No running tunnel process to kill." && return 0;

  # Otherwise, request input to kill
  echo -e "Kill process ${process_id}? [Y,n] \c" && read DO_IT && \
  do_it=`echo "${DO_IT}" | awk '{ print tolower($1) }'` && \
  [ ${do_it} == "y" ] && \
  echo "Killing ${process_id}" && kill -9 ${process_id} || \
  echo "Not killing ${process_id}"
}
