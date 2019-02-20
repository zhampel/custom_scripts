#!/bin/bash

global_mounting_dir="${HOME}/MMachines"

# Lookup hostname IP of named machine
function hname_lookup {
  local hostname=`ssh -G ${1} | awk '/^hostname / { print $2 }'`
  echo ${hostname}
}

# Lookup username of named machine
function username_lookup {
  local username=`ssh -G ${1} | awk '/^user / { print $2 }'`
  echo ${username}
}

# Mount requested machine
function mymnt {
  echo "Mounting $1 machine..."

  # Mounting directory
  m_dir=${global_mounting_dir}/$1

  # If mounting directory dne, make it
  if [ ! -d ${m_dir} ]; then
    mkdir ${m_dir}
  fi

  # Get hostname address of machine
  hname=$(hname_lookup $1)
  echo "  with HOSTNAME:  ${hname}"

  # Get hostname address of machine
  usrname=$(username_lookup $1)
  echo "  with USERNAME:  ${usrname}"

  # RSA identify file
  rsa_file="~/.ssh/id_rsa_${1}"

  # SSHFS command to mount
  if [ -f ${rsa_file} ]; then
    sudo sshfs -o allow_other,defer_permissions,IdentityFile=${rsa_file} ${usrname}@${hname}: ${m_dir}
    echo "Successfully mounted to ${m_dir}"
  else
    sudo sshfs -o allow_other,defer_permissions ${usrname}@${hname}: ${m_dir}
    echo "Successfully mounted to ${m_dir}"
  fi
}

# Unmount requested machine
function unmntme {
  echo "Unmounting $1 machine..."

  # Mounting directory
  m_dir=${global_mounting_dir}/$1
  
  # If mounting directory dne, exit
  if [ ! -d ${m_dir} ]; then
    echo "Mounted directory does not exist. Exiting..."
  else
    sudo umount -f ${m_dir}
    echo "Successfully unmounted."
  fi
}
