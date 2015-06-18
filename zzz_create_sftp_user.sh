#!/bin/bash

function myHelp() {
  printf "__Help__\n"
  printf "  Requires a user name:\t\t-u 'USER'\n"
  printf "  Requires a valid NFS path:\t-n '/nfs/ftp/PATH/TO/Profile'\n\n"
}

function lcase_User() {
  echo $myUser_In | tr '[A-Z]' '[a-z]'
}

function verify_Input() {
  # Verify that we have a username and NFS path
  if [[ -z "$myUser_In" || -z "$myNFS_In" ]]; then
    myHelp
    exit 1
  fi

  # Verify the user name isn't taken
  grep -wq $myUser /etc/passwd
  if [ $? -eq 1 ]; then
    printf "That user name is available.\n"
  else
    printf "That user name is already taken!\n"
    exit 1
  fi
}

function createUser() {
  # Create the NFS path
  sudo -u ftp mkdir -p $myNFS_In
  # Chmod the final location to sticky GID
  sudo -u ftp chmod 2775 $myNFS_In
  # Create the SFTP user account
  sudo /usr/sbin/useradd -u 2003 -g 2003 -o -d $myNFS_In -p $(openssl passwd -1 $myPass_In1) -s /usr/bin/rssh $myUser 1>/dev/null 2>/dev/null
  # Copy into base files
  grep -i $myUser /etc/passwd | sudo tee -a /etc/passwd.base >/dev/null
  sudo grep -i $myUser /etc/shadow | sudo tee -a /etc/shadow.base >/dev/null
  # Inform the user the account's been created
  printf "New SFTP user account created, please test manually.\n\n"
}



#
#
# Begin script
## Ensure we've the user name and NFS path passed to us
while getopts "u:n:" option; do
  case "${option}" in
    u) myUser_In=${OPTARG};;
    n) myNFS_In=${OPTARG};;
    *) myHelp;;
  esac
done

## Lower case the user name (for in case)
myUser=$( lcase_User )

## Verify my Input
verify_Input

## Prompt for the password
printf "\nPlease enter the user's password: "
read -s myPass_In1
printf "\nPlease confirm the user's password: "
read -s myPass_In2
while [ $myPass_In1 != $myPass_In2 ]; do
  printf "\n\nPasswords do not match.\n\n"

  printf "\nPlease enter the user's password: "
  read -s myPass_In1
  printf "\nPlease confirm the user's password: "
  read -s myPass_In2
done

# Output some quick debug messages
printf "\n\n"
printf "Have a user of '$myUser'.\n"
printf "Have a pass of '$myPass_In1'.\n"
printf "Have a NFS of '$myNFS_In'.\n\n"

## Create the new SFTP account
createUser

## Exit cleanly
exit 0

