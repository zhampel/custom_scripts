#!/bin/bash

# Initialize full path in .bashrc or similar
global_mounting_dir="$1"


# General ssh/config lookup function
# Keywords such as hostname, user, identityfile 
function sshconfig_lookup {
  # Usage: sshconfig_lookup machine_name ssh_config_keyword
  keyword=${2}
  local keyval=`ssh -G ${1} | awk '/^'${keyword}' / { print $2 }'`
  echo ${keyval}
}


# Mount requested machine
function mymnt {
  # Input is machine name (from .ssh/config)
  machine=${1}

  # Full path of mounting directory
  m_dir=${global_mounting_dir}/${machine}

  # If mounting directory dne, make it
  [ ! -d ${m_dir} ] && mkdir ${m_dir}

  # Check if already mounted.
  is_mnt=`mount | grep "on ${m_dir}"`
  # If not then mount, otherwise return from function.
  { [ -z "${is_mnt}" ] && echo "Mounting ${machine} to directory ${m_dir}"; } || \
  { echo -e "\tMachine ${machine} already mounted to ${m_dir}. Exiting..." && return 0; }

  # Get hostname address of machine
  hoststring="hostname"
  hname=$(sshconfig_lookup ${machine} ${hoststring})
  ping -c 1 ${hname} &> /dev/null || \
  { echo -e "\tMachine ${machine} with hostname ${hname} not reachable as defined. Exiting..." && return 0; }
  echo -e "\twith HOSTNAME:  ${hname}"

  # Get username associated with machine, defaults to local user
  userstring="user"
  usrname=$(sshconfig_lookup ${machine} ${userstring})
  [ -z ${usrname} ] && usrname=`whoami`
  echo -e "\twith USERNAME:  ${usrname}"

  # Get RSA identify file
  identitystring="identityfile"
  rsa_file=$(sshconfig_lookup ${machine} ${identitystring})

  # Check that only one IdentityFile is listed.
  # If not, suggest defaults before exiting.
  arr=($rsa_file)
  [ ${#arr[@]} -eq 1 ] || \
  { echo "IdentityFile for ${machine} machine not specified in ~/.ssh/config."; \
  echo -e "\tPlease specify or consider from amongst default options:"; \
  echo -e "\t${rsa_file}"; return 0; }

  # Test that specified RSA file exists
  [ -f ${rsa_file} ] || { echo "IdentifyFile ${rsa_file} does not exist. Exiting..."; return 0; }
  echo -e "\twith IDENTITYFILE:  ${rsa_file}"

  eval `sshfs -o allow_other,defer_permissions,IdentityFile=${rsa_file} ${usrname}@${machine}: ${m_dir}` && \
  echo "Successfully mounted ${machine} to ${m_dir}" || \
  echo "Unsuccessful mount of ${machine} to ${m_dir}"
}


# Unmount requested machine
function unmntme {
  # Input is machine name (from .ssh/config)
  machine=${1}

  # Full path of mounting directory
  m_dir=${global_mounting_dir}/${machine}
 
  # Check if mounting directory even exists.
  [ ! -d ${m_dir} ] && echo "Mounting directory does not exist. Exiting..." && return 0

  # Check if already mounted.
  is_mnt=`mount | grep "on ${m_dir}"`

  # If mounted, unmount, otherwise return from function.
  [ ! -z "${is_mnt}" ] && \
  sudo diskutil unmount force ${m_dir} && echo "Successfully unmounted." || \
  echo "Machine ${machine} not mounted. Exiting..."
}
