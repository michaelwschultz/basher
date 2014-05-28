#!/bin/bash
#
# This bash script takes the hassle out of prepping repositories for new sites.
# Automatically generates both local and remote git repositories, then links them
# and sends out your first push. Magic.
#
# Written 4/13/2014 @michaelschultz
# Updated 5/27/14

# ABOUT
# This script was written to drastically decrease the ammount of steps needed
# to setup a new hosted git directory on both your local and remote machines.


# Aborts on error
# set -e

# Setup
##############################
# Function to ask confirmation
function askname {
	echo -e "\n"
	read -e -p "Basher: What should I call the new directory? -> " SITENAME
	echo -e "Basher: Ok, ${success}$SITENAME${normal} it is."

    read -n 1 -r -p "$1"
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
            return 1;
    else
            askname "Basher: For real this time? [y/n]"
    fi
}


# TODO Need to make sure these colors work accross termial apps.
# Adds the ability to bold text inside the terminal
bold=`tput bold`
success=`tput setf 2`
fail=`tput setf 4`
normal=`tput sgr0`
##############################


# START
# Beginning of Website Basher script
# Name a new directory
echo -e ${success}'
    ____  ___   _____ __  ____________     ___ ____
   / __ )/   | / ___// / / / ____/ __ \   <  // __ \
  / __  / /| | \__ \/ /_/ / __/ / /_/ /   / // / / /
 / /_/ / ___ |___/ / __  / /___/ _, _/   / // /_/ /
/_____/_/  |_/____/_/ /_/_____/_/ |_|   /_(_)____/'${normal}

echo -e "\n###############################"
echo -e "${success}Basher here, let's get started.${normal}"
echo -e "###############################"

# Feel free to mute me by commenting this line, you terrible human.
# say -v "Zarvox" "Basher here, let's get started."

askname "Basher: Ready to bash? [${success}y${normal}/${fail}n${normal}]"


# Start server setup
echo -e "${success}\n\nBasher: SSHing into server...${normal}"

# TODO Need to ask user for their login or just have them edit this file before running it.
# This also needs to account for a possible port number.
ssh -t user@ipaddress "export SITENAME='$SITENAME';
cd ~/repos
mkdir $SITENAME.git
cd $SITENAME.git
git init --bare
cd hooks
touch post-receive
echo -e '#!/bin/sh' >> post-receive
echo -e 'cd /home/user/www/$SITENAME/' >> post-receive
echo -e 'git --git-dir /home/user/www/$SITENAME/.git pull' >> post-receive
chmod +x post-receive

cd ~/www
mkdir $SITENAME
cd $SITENAME
git init
git remote add origin /home/user/repos/$SITENAME.git"

echo -e "${success}Basher: Serverside directories created and linked.${normal}"

# Creat local directory

# TODO Change the wording to past tense. "Created local directory."
echo -e "${success}\n\nBasher: Creating local directory...${normal}"
cd ~/Sites
mkdir $SITENAME
cd $SITENAME
git init

# TODO Need to ask user for their login or just have them edit this file before running it.
git remote add origin ssh://user@ipaddress/home/user/repos/$SITENAME.git
touch readme.md

# TODO Need to ask user for their twitter handle or just have them edit this file before running it.
echo "$SITENAME - created by @michaelschultz" >> readme.md
echo "Site directory built with custom bash script, http://github.com/michaelwschultz/basher created by @michaelschultz" >> readme.md
echo -e "${success}Basher: Local directory created and linked.${normal}"
git add .
git commit -m"initial commit by Basher"
# git status
git push --set-upstream origin head

echo -e "${success}Basher: Initial commit pushed to server.${normal}"

echo -e "${success}\nBasher: All done. Good luck on the new project!${normal}"
echo -e '
    ____  ___   _____ __  ____________     ____  __  ________
   / __ )/   | / ___// / / / ____/ __ \   / __ \/ / / /_  __/
  / __  / /| | \__ \/ /_/ / __/ / /_/ /  / / / / / / / / /
 / /_/ / ___ |___/ / __  / /___/ _, _/  / /_/ / /_/ / / /
/_____/_/  |_/____/_/ /_/_____/_/ |_|   \____/\____/ /_(_)'
echo -e "drops mic\n\n"
# afplay ~/Dropbox/Files/Applications/new_website_ready.m4a

# TODO Probably just remove this. It's a nice to have but we can't open the site folder if we don't know the local dir.
cd ~/Sites/$SITENAME
open ~/Sites/$SITENAME

exit
# FINISHED
