#!/usr/bin/env bash

# SSH ports in use
declare -A USED_PORTS
declare -A USED_PROCS


# Function to print current  associative arrays
function array_check {
  echo ""
  echo "Checking current state of port & process id arrays..."
  # USED_PORTS
  echo USED_PORTS has ${#USED_PORTS[@]} elements
  for key in ${!USED_PORTS[@]}; do echo -e "\tkey" $key "with value" ${USED_PORTS[${key}]}; done
  # USED_PROCS
  echo USED_PROCS has ${#USED_PROCS[@]} elements
  for key in ${!USED_PROCS[@]}; do echo -e "\tkey" $key "with value" ${USED_PROCS[${key}]}; done
}


# Add port and process id to arrays
function add_port_proc {
  local_port=$1
  pid=$2
  USED_PORTS["${local_port}"]="${pid}"
  USED_PROCS["${pid}"]="${local_port}"
}


# Function to check localhost port usage
function port_checker {
  port_val=$1
  proc_val=${USED_PROCS["${port_val}"]}
  if [ ! -z ${proc_val} ]; then
    echo "Port id ${port_val} has associated process id ${proc_val}."
  else
    echo "Port id ${port_val} has no associated process."
  fi
}


# Remove port & process from list based on port id
function port_remover {
  port_val=$1
  proc_val=${USED_PORTS["${port_val}"]}
  if [ ! -z ${proc_val} ]; then
    echo "Removing port id ${port_val} and assoc process id ${proc_val} from dicts..."
    unset USED_PROCS["${proc_val}"]
    unset USED_PORTS["${port_val}"]
  else
    echo "Port id ${port_val} has no associated process. Exiting..."
  fi
}


# Function to check localhost process usage
function proc_checker {
  proc_val=$1
  port_val=${USED_PROCS["${proc_val}"]}
  if [ ! -z ${port_val} ]; then
    echo "Port id ${port_val} has associated process id ${proc_val}."
  else
    echo "Process id ${proc_val} has no associated ports."
  fi
}


# Remove port & process from list based on process id
function proc_remover {
  proc_val=$1
  port_val=${USED_PROCS["${proc_val}"]}
  if [ ! -z ${port_val} ]; then
    echo "Removing port id ${port_val} and assoc process id ${proc_val} from dicts..."
    unset USED_PROCS["${proc_val}"]
    unset USED_PORTS["${port_val}"]
  else
    echo "Process id ${proc_val} has no associated ports. Exiting..."
  fi
}


# Function to assign a port
function port_getter {
  # Currently only 100 diff ports allowed
  first_port=8888
  final_port=8988

  # Start at first_port
  test_port=${first_port}
  
  # Default is 'there are elements in dict'
  cond=true

  # Check if dict has any elements
  n_vals=${#USED_PORTS[@]}
  [ "$n_vals" -eq 0 ] && cond=false
  #|| cond=true

  while $cond
  do
    # Access key-value pair (string)
    test_key=${USED_PORTS["${test_port}"]}
    # Bash test if port key value pair is in dict
    # If yes and value less than final port limit, then increment, else exit
    cond=false
    [ ! -z ${test_key} ] && [ "${final_port}" -gt "${test_port}" ] && test_port=$(( ${test_port}+1 )) && cond=true
    #|| cond=false
  done

  # Return final test port number
  select_port=${test_port}
  echo "${select_port}"
}


# Setup tunnel to named machine
function ipytunnel {
  # Input is IP or machine name alias (from .ssh/config)
  machine=$1
  # Identify available port
  local_port=$(port_getter)

  # Ensure proper input, attempt to ssh 
  [ "${machine}" ] && \
  ssh -N -f -L localhost:${local_port}:localhost:8889 ${machine} || \
  { echo "Please provide a valid machine into which to ssh." && return; }
 
  # Get process ID of ssh service (non-trivial race condition...)
  # unix.stackexchange.com/questions/230615/predicting-the-pid-of-previously-started-ssh-command
  pid=$(pgrep -f "localhost:${local_port}:localhost:8889 ${machine}")

  # Update port & process assoc arrays
  add_port_proc ${local_port} ${pid}
  #USED_PORTS["${local_port}"]="${pid}"
  #USED_PROCS["${pid}"]="${local_port}"
  echo ""
  echo "Connected to ${machine} via port id ${local_port} with process id ${pid}."
}


# Find process running tunnel to kill
function ipyfind {

  echo ""
  search_key='ssh'
  [ ! -z ${1} ] && search_key="${1}"

  # Get process id(s)
  process_id=`ps aux | grep ${search_key} | awk '/localhost/{print$2}'`
  # Get process(es) full info
  process_info=`ps aux | grep ${search_key} | awk '/localhost/{print}'`

  # Make list of ids
  process_list=( ${process_id} )
  # Get total number of processes
  num_procs=${#process_list[@]}
  # Username delimiter for splitting info string
  user_delimiter=${USER}
  
  # Only if process(es) found, return
  { [ ${num_procs} -gt 0 ] && \
  echo -e ${num_procs} "process(es) assoc. w/" ${search_key} && \
  echo -e "Process id(s): \t\t\c" && echo ${process_id} && \
  echo -e "Process info:" && \
  echo "${process_info}" | sed -e 's/"${user_delimiter}"/  /g'; } || \

  echo "No relevant processes found."
}


# Kill process
function ipykill {
 
  search_key='ssh'
  [ ! -z ${1} ] && search_key="${1}"

  # Process id via input or from listed processes
  process_id=`ps aux | grep ${search_key} | awk '/localhost/{print$2}'`
  # Make list of ids
  process_list=( ${process_id} )
  # Get total number of processes
  num_procs=${#process_list[@]}

  # If more than one, print info for guidance
  [ ${num_procs} -gt 1 ] && ipyfind ${search_key} && \
  echo "More than 1 processes associated with ${search_key}." && \
  echo "Please enter from Process id(s) list above or ctrl-c to cancel." && \
  echo -e "Enter process id: \c" && read process_id

  # If process id not provided or not found running, then nothing to do.
  [ ! "${process_id}" ] || [ ! `ps aux | awk '{print $2 }' | grep ${process_id}` ] && \
  echo "No running process with id ${process_id} to kill." && return 0;

  # Otherwise, request input to kill
  { echo -e "Kill process ${process_id}? [Y,n] \c" && read DO_IT && \
  do_it=`echo "${DO_IT}" | awk '{ print tolower($1) }'` && \
  [ ${do_it} == "y" ] && \
  echo "Killing ${process_id}" && \
  kill -9 ${process_id} && \
  proc_remover ${process_id}; } || \

  echo "Not killing process with id ${process_id}"
}
