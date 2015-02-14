# Basher
##### Your git/apache piping robot ![basherlogo](http://cl.ly/Zh0J/basher-logo-small.jpg)


> Basher removes the hassle of piping setup for new web projects. By automatically generating both local and remote git repositories, Basher removes 99% of the steps necessary for getting your site online. Once that's done, Basher links these directories and sends out your first push. Magic.


## Usage

Basher is currently built to handle a single workflow - one that uses Git for version control and Apache servers for hosting multiple sites. If this sounds like you, then Basher's your new best friend.

By default, Basher will ask for a new domain name (.com, .net, .org). Once you confirm the name, a local and two remote directories will be created each with a git repo initialized and linked.

>  You can read more about why two git repos are a good idea [here](http://git-scm.com/book/en/v2/Git-on-the-Server-Getting-Git-on-a-Server).

Next, a new virtual host file is created in Apache and your server is restarted to account for the change. If all goes as planned, you can visit your new site immediately (assuming you already have DNS for the domain pointing to your server).

To make updates to your site, simply push from your local directory to have changes go live immediately.


## Installation and setup

Download the zip or clone the repo then place then place the contents in a folder on your dive. I recommend your dropbox folder so you have access across devices.

Be sure to open the basher_config.cfg file before you head to the terminal and fill out all the variables listed. Once that's done run ```$ bash basher.sh -test``` to check your work. Basher will let you know if something is amiss.

You must execute ```$ bash basher.sh``` from it's directory or use an alias to execute it anywhere.

To start Basher with an alias, add this line to your .bash_profile. Call the alias whatever you like.
```alias basher='bash ~/directory/to/basher.sh'```

Run ```$ bash basher.sh``` or use your alias to get started.

Further examples will be shown using the alias 'basher'.


#### Terminal Commands

##### $ basher
> ```$ basher``` to start a new project in under 10 seconds
including local and remote site directories and apache virtual hosts.

> example: yournewsite.com

##### $ basher -help or -h
> ```$ basher -help``` to get some basic help.

##### $ basher -remove or -r
> ```$ basher -remove``` to remove a remote directory.

##### $ basher -subdirectory or -sub or -s
> ```$ basher -subdirectory``` to start a new sub-directory project without apache configuration.

> example: 100.100.100.10/newsubdirectory

##### $ basher -test or -t
> ```$ basher -test``` to test your configuration file against your SSH.

##Code structure and contribution

Interested in helping develop Basher further? Killer, hit me up on Twitter [@michaelschultz](http://twitter.com/@michaelschultz) or leave a message on the http://github.com/michaelwschultz/Basher issues page.


```bash
Need some examples? Let me know what I should put here.
```



## Change Log
### current v1.0

##### Ready for public release
* Moved to a function based script.
* Configuration file allows for general use.
* More robust error handling for local and SSH processes.
* Adds Apache virtual hosts support.
