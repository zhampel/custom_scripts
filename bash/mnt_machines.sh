#!/bin/bash

global_mounting_dir="$1"
#global_mounting_dir="${HOME}/MNTMachines"

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

# Lookup username of named machine
function idfile_lookup {
  local idfile=`ssh -G ${1} | awk '/^identityfile / { print $2 }'`
  echo ${idfile}
}

# Mount requested machine
function mymnt {
  machine=${1}
  echo "Mounting ${machine} machine..."

  # Mounting directory
  m_dir=${global_mounting_dir}/${machine}

  # If mounting directory dne, make it
  [ ! -d ${m_dir} ] && mkdir ${m_dir}

  # Get hostname address of machine
  hname=$(hname_lookup ${machine})
  echo "  with HOSTNAME:  ${hname}"

  # Get hostname address of machine
  usrname=$(username_lookup ${machine})
  echo "  with USERNAME:  ${usrname}"

  # RSA identify file
  rsa_file=$(idfile_lookup ${machine})
  # Check that only one IdentityFile is listed, no default.
  #[ ${#rsa_file} -eq 1 ] || { echo "IdentityFile may not be properly defined in .ssh/config."; return 0; }
  echo "  with IDENTITYFILE:  ${rsa_file}"

  #echo "sudo sshfs -o allow_other,defer_permissions,IdentityFile=${rsa_file} ${usrname}@${hname}: ${m_dir}"
  #echo "sshfs -o allow_other,defer_permissions,IdentityFile=${rsa_file} ${usrname}@${1}: ${m_dir}"
  # SSHFS command to mount
  if [ -f ${rsa_file} ]; then
    eval `sshfs -o allow_other,defer_permissions,IdentityFile=${rsa_file} ${usrname}@${machine}: ${m_dir}`
    #sshfs -o allow_other,defer_permissions,IdentityFile=${rsa_file} ${usrname}@${1}: ${m_dir}
    #sshfs -o allow_other,defer_permissions,IdentityFile=${rsa_file} ${usrname}@${hname}: ${m_dir}
    #sudo sshfs -o allow_other,defer_permissions,IdentityFile=${rsa_file} ${usrname}@${hname}: ${m_dir}
    echo "Successfully mounted to ${m_dir}"
  else
    #sshfs -o allow_other,defer_permissions ${usrname}@${hname}: ${m_dir}
    #sudo sshfs -o allow_other,defer_permissions ${usrname}@${hname}: ${m_dir}
    echo "Successfully mounted to ${m_dir}"
  fi
}

# Unmount requested machine
function unmntme {
  machine=${1}
  echo "Unmounting ${machine} machine..."

  # Mounting directory
  m_dir=${global_mounting_dir}/${machine}
  
  # If mounting directory dne, exit
  [ ! -d ${m_dir} ] && echo "Mounted directory does not exist. Exiting..." || \
  sudo diskutil unmount force ${m_dir} && echo "Successfully unmounted."
  #if [ ! -d ${m_dir} ]; then 
  #  echo "Mounted directory does not exist. Exiting..."
  #else
  #  sudo diskutil unmount force ${m_dir}
  #  #sudo umount -f ${m_dir}
  #  echo "Successfully unmounted."
  #fi
}
