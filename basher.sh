#!/bin/bash
# Basher takes the hassle out of setting up directories for a new project.
# Automatically generates both local and remote git repositories,
# links them and sends out your first push. Magic.

## TOC ##

# CONSTANTS
# FUNCTIONS
#   HELPERS
#   METHODS
# MAIN



#### CONSTANTS

# Locates Basher directory and checks for config file
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Inline text colors
TGREEN=$(tput setaf 2)
TRED=$(tput setaf 1)
TDEFAULT=$(tput sgr0)

#### END OF CONSTANTS


#### FUNCTIONS

## Helpers

# Display colorized information output
function timportant() {
  COLOR=${TGREEN}
  RESET=${TDEFAULT}
  MESSAGE=${@:-"${RESET}Error: No message passed"}
  echo -e "${COLOR}${MESSAGE}${RESET}"
}

# Display colorized warning output
function twarn() {
  COLOR=${TRED}
  RESET=${TDEFAULT}
  MESSAGE=${@:-"${RESET}Error: No message passed"}
  echo -e "${COLOR}${MESSAGE}${RESET}"
}

# Check for Internet connection
function check_internet {
  WGET="/usr/bin/wget"

  if [[ ! $(ping -c1  google.com) ]]; then
    twarn "\n Looks like you aren't connected to the Internet, please connect and try again."
    exit 1
  fi
}

# Locate config file
function read_config {
  if [[ -r $DIR/basher-config.cfg ]]; then
    source ${DIR}/basher-config.cfg
    CONFIG_AVAILABLE=true
  else
    twarn "\nNo config file found - check ${DIR}/basher-config.cfg\n"
    exit 1
  fi
}

function test_config {
  echo -e "\nTesting ${DIR}/basher-config.cfg...."

  # check config file for variable entries
  if [[ -z "$LOCAL_DIRECTORY" ]]; then
    twarn "Local directory missing"
  fi
  if [[ -z "$SERVER_ADDRESS" ]]; then
    twarn "Server address missing"
  fi
  if [[ -z "$REPOS_DIRECTORY" ]]; then
    twarn "Repos directory missing"
  fi
  if [[ -z "$SITES_DIRECTORY" ]]; then
    twarn "Sites directory missing"
  fi
  if [[ -z "$SITES_AVAILABLE" ]]; then
    twarn "Sites-available directory missing"
  fi
  if [[ -z "$SITES_ENABLED" ]]; then
    twarn "Sites-enabled directory missing"
  fi
  if [[ "$LOCAL_DIRECTORY" != ""
    && "$SERVER_ADDRESS" != ""
    && "$REPOS_DIRECTORY" != ""
    && "$SITES_DIRECTORY" != ""
    && "$SITES_AVAILABLE" != ""
    && "$SITES_ENABLED" != "" ]]; then
    echo -e "Testing SSH access and directory locations...\n"
  else
    twarn "\nFill in all variables in ${DIR}/basher-config.cfg and run \$ basher -test again."
    exit 1
  fi

  # check if directory exists on server
  ssh $SERVER_ADDRESS "
    if [[ ! -d "$REPOS_DIRECTORY" ]]; then
      echo "Repos directory missing"
    fi
    if [[ ! -d "$SITES_DIRECTORY" ]]; then
      echo "Sites directory missing"
    fi
    if [[ ! -d "$SITES_AVAILABLE" ]]; then
      echo "Sites-available directory missing"
    fi
    if [[ ! -d "$SITES_ENABLED" ]]; then
      echo "Sites-enabled directory missing"
    fi
    if [[ -d "$REPOS_DIRECTORY" && "$SITES_DIRECTORY" && "$SITES_AVAILABLE" && "$SITES_ENABLED" ]]; then
      echo "Everything looks good! Run \$ basher to get started."
    else
      echo "Double check ${DIR}/basher-config.cfg then run \$ basher -test again."
    fi
  "
}
## end of helpers


## Methods
function begin_bashing {

  if [[ "$CONFIG_AVAILABLE" = false ]]
    then
      twarn "\nNo inline configuration available at this time."
      twarn "Please edit your ${DIR}/basher-config.cfg file manually."
  else
    echo -e ${TGREEN}'
        ____  ___   _____ __  ____________
       / __ )/   | / ___// / / / ____/ __ \
      / __  / /| | \__ \/ /_/ / __/ / /_/ /
     / /_/ / ___ |___/ / __  / /___/ _, _/
    /_____/_/  |_/____/_/ /_/_____/_/ |_|\n'${TDEFAULT}

    timportant "\n( ͡° ͜ʖ ͡°) Basher here, let's get started."

    ask_name "I'm all set, ready to go? [y/n]"
  fi
}


# ask for directory name
function ask_name {
  echo -e "\n"

  if [[ "$SUB_DIRECTORY" = true ]]; then
    read -e -p "Basher: What domain will you attach this subdomain to? (don't forget the .com) -> " SITENAME
    read -e -p "Basher: What do you want to call your new subdirectory? -> " SUBDIRECTORYNAME

  else
    read -e -p "Basher: What's the domain name? (don't forget the .com) -> " SITENAME
  fi

  if [[ "$SUB_DIRECTORY" = true ]]; then
    echo -e "Ok, ${TGREEN}$SUBDIRECTORYNAME.$SITENAME${TDEFAULT} it is.\n"
  else
    echo -e "Ok, ${TGREEN}$SITENAME${TDEFAULT} it is.\n"
  fi

  read -n 1 -r -p "$1"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    return 1;
  else
    echo -e "\n"
    ask_name "( ͡ಠ ʖ̯ ͡ಠ) For real this time? [y/n]"
  fi
}


# Remote setup of git repositories and apache virtual hosts
function build_remote_directory {
  timportant "\nBasher: Logging into server via SSH...\n"

  if [[ "$SUB_DIRECTORY" = true ]]; then
    # SSH into server and create git enabled directories
    ssh $SERVER_ADDRESS "
      export SITENAME='${SITENAME}';
      export SUBDIRECTORYNAME='${SUBDIRECTORYNAME}';
      cd $REPOS_DIRECTORY
      mkdir ${SUBDIRECTORYNAME}.${SITENAME}.git
      cd ${SUBDIRECTORYNAME}.${SITENAME}.git
      git init --bare
      cd hooks
      echo -e '#!/bin/sh
      cd ${SITES_DIRECTORY}/${SUBDIRECTORYNAME}.${SITENAME}/
      git --git-dir ${SITES_DIRECTORY}/${SUBDIRECTORYNAME}.${SITENAME}/.git pull origin master
      ' >> post-receive
      chmod +x post-receive

      cd $SITES_DIRECTORY
      mkdir ${SUBDIRECTORYNAME}.$SITENAME
      cd ${SUBDIRECTORYNAME}.$SITENAME
      git init
      git remote add origin ${REPOS_DIRECTORY}/${SUBDIRECTORYNAME}.${SITENAME}.git

      echo -e '<VirtualHost *:80>
        ServerAdmin admin@$SITENAME
        ServerName $SUBDIRECTORYNAME.$SITENAME
        ServerAlias www.$SUBDIRECTORYNAME.$SITENAME
        DocumentRoot ${SITES_DIRECTORY}/$SUBDIRECTORYNAME.$SITENAME
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
      </VirtualHost>' >> ${SITES_AVAILABLE}/${SUBDIRECTORYNAME}.${SITENAME}.conf

      a2ensite ${SUBDIRECTORYNAME}.${SITENAME}.conf >> /dev/null 2>&1
      service apache2 restart
    " # end remote SSH work

  elif [[ "$DOMAIN_ONLY" = true ]]; then
    # SSH into server and create git enabled directories
    ssh $SERVER_ADDRESS "
      export SITENAME='${SITENAME}';
      cd $SITES_DIRECTORY
      mkdir $SITENAME

      echo -e '<VirtualHost *:80>
        ServerAdmin admin@$SITENAME
        ServerName $SITENAME
        ServerAlias www.$SITENAME
        DocumentRoot ${SITES_DIRECTORY}/$SITENAME
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
      </VirtualHost>' >> ${SITES_AVAILABLE}/${SITENAME}.conf

      a2ensite ${SITENAME}.conf >> /dev/null 2>&1
      service apache2 restart
    " # end remote SSH work
    
  else
    # SSH into server and create git enabled directories
    ssh $SERVER_ADDRESS "
      cd $REPOS_DIRECTORY
      mkdir ${SITENAME}.git
      cd ${SITENAME}.git
      git init --bare
      cd hooks
      echo -e '#!/bin/sh
      cd ${SITES_DIRECTORY}/${SITENAME}/
      git --git-dir ${SITES_DIRECTORY}/${SITENAME}/.git pull origin master
      ' >> post-receive
      chmod +x post-receive

      cd $SITES_DIRECTORY
      mkdir $SITENAME
      cd $SITENAME
      git init
      git remote add origin ${REPOS_DIRECTORY}/${SITENAME}.git

      echo -e '<VirtualHost *:80>
        ServerAdmin admin@$SITENAME
        ServerName $SITENAME
        ServerAlias www.$SITENAME
        DocumentRoot ${SITES_DIRECTORY}/$SITENAME
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
      </VirtualHost>' >> ${SITES_AVAILABLE}/${SITENAME}.conf

      a2ensite ${SITENAME}.conf >> /dev/null 2>&1
      service apache2 restart
    " # end remote SSH work
  fi

  timportant "\nBasher: Serverside directories created and linked.\n"
}


# ask for directory name
function ask_removal_name {
  echo -e "\n"
  read -e -p "Basher: Which directory would you like to remove? -> " SITENAME
  echo -e "Ok, ${TGREEN}$SITENAME${TDEFAULT} it is.\n"

  read -n 1 -r -p "$1"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    return 1;
  else
    echo -e "\n"
    ask_removal_name "Basher: For real this time? [y/n]"
  fi
}


# Remove site from server
function remove_directory_from_server {
  ask_removal_name "I'm all set, ready to go? [y/n]"

  if [[ $SITENAME =~ .*\.\.* ]]; then
    echo -e "\n"
    ssh $SERVER_ADDRESS "
      export SITENAME='$SITENAME';
      rm -rf ${REPOS_DIRECTORY}/${SITENAME}.git/
      rm -rf ${SITES_DIRECTORY}/${SITENAME}/

      rm ${SITES_AVAILABLE}/${SITENAME}.conf
      rm ${SITES_ENABLED}/${SITENAME}.conf
      service apache2 restart
    "
  else
    ssh $SERVER_ADDRESS "
      export SITENAME='$SITENAME';
      rm -rf ${REPOS_DIRECTORY}/${SITENAME}.git/
      rm -rf ${SITES_DIRECTORY}/${SITENAME}/
    "
  fi

  timportant "\nRemote directory removed.\n"
}


# Create local directory and push initial commit
function local_setup {
  timportant "Basher: Creating local directory...\n"
  cd $LOCAL_DIRECTORY

  if [[ "$SUB_DIRECTORY" = true ]]; then
    mkdir $SUBDIRECTORYNAME.$SITENAME
    cd $SUBDIRECTORYNAME.$SITENAME
    git init
    git remote add origin ssh://${SERVER_ADDRESS}/${REPOS_DIRECTORY}/${SUBDIRECTORYNAME}.${SITENAME}.git
    echo -e "${SUBDIRECTORYNAME}.${SITENAME} - created $(date)\n
    Setup using @michaelschultz custom bash script,
    http://github.com/michaelwschultz/basher
    " >> README.md
  else
    mkdir $SITENAME
    cd $SITENAME
    git init
    git remote add origin ssh://${SERVER_ADDRESS}/${REPOS_DIRECTORY}/${SITENAME}.git
    echo -e "${SITENAME} - created $(date)\n
    Setup using @michaelschultz custom bash script,
    http://github.com/michaelwschultz/basher
    " >> README.md
  fi

  timportant "\nBasher: Local directory created and linked.\n"

<<"COMMENT"
# Replace source path and remove COMMENT to add git-changelog (optional)
# https://github.com/michaelwschultz/Changelog-for-Git
# start git-changelog
  cd .git/hooks
cat <<-EOF > post-commit
#!/bin/sh
# Run git-changelog immediately after every commit
source ~/path/to/git-changelog.sh
# End
EOF
  chmod +x post-commit
  cd ../../
# ends git-changelog
COMMENT

  git add .
  git commit -m"initial commit by Basher"
  timportant "\nBasher: Pushing to server...\n"
  git config remote.origin.push HEAD
  git push --set-upstream origin head

  timportant "\nBasher: Initial commit pushed to server.\n"

  if [[ "$SUB_DIRECTORY" = true ]]; then
    open $LOCAL_DIRECTORY/$SUBDIRECTORYNAME.$SITENAME/
  else
    open $LOCAL_DIRECTORY/$SITENAME/
  fi

}

function finish_message {
  timportant "\n\n( ͡ ͜ʖ ͡ ) All done. Good luck on the new project!\n"
  echo -e ${TGREEN}'
      ____  ___   _____ __  ____________     ____  __  ________
     / __ )/   | / ___// / / / ____/ __ \   / __ \/ / / /_  __/
    / __  / /| | \__ \/ /_/ / __/ / /_/ /  / / / / / / / / /
   / /_/ / ___ |___/ / __  / /___/ _, _/  / /_/ / /_/ / / /
  /_____/_/  |_/____/_/ /_/_____/_/ |_|   \____/\____/ /_/\n'

}

## end of methods

#### END OF FUNCTIONS


#### MAIN

case "$1" in
  "-config" | "-c")
    read_config
    CONFIG_AVAILABLE=false
    begin_bashing
    echo -e "\nLet me know if editing the config inline would be useful, @michaelschultz on Twitter."
    ;;
  "-domain" | "-d")
    DOMAIN_ONLY=true
    read_config
    check_internet
    begin_bashing
    test_config
    build_remote_directory
    finish_message
    ;;
  "-help" | "-h")
    echo -e "\n-help \t\t -h \tNot much here at the moment."
    echo -e "-remove \t -r \tRemove directories you've created from your server."
    echo -e "-subdirectory \t -s \tCreate a sub directory under a current domain."
    echo -e "\nReview the README.md or contact @michaelschultz on Twitter."
    echo -e "http://github.com/michaelwschultz/basher"
    ;;
  "-remove" | "-r")
    read_config
    remove_directory_from_server
    ;;
  "-subdirectory" | "-sub" | "-s")
    SUB_DIRECTORY=true
    read_config
    check_internet
    begin_bashing
    test_config
    build_remote_directory
    local_setup
    finish_message
    ;;
  "-test" | "-t")
    TEST_CONFIG=true
    read_config
    check_internet
    test_config
    ;;
  *)

  read_config
  check_internet
  begin_bashing
  test_config
  build_remote_directory
  local_setup
  finish_message
esac

echo -e "\n"
exit


#### END OF MAIN

# FINISHED
