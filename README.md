# Basher


> Basher takes the hassle out of setting up directories for a new project. Automatically generates both local and remote git repositories, links them and sends out your first push. Magic.



## Installation and setup

Download the zip or clone the repo then place then place the contents in a folder on your dive. I recommend your dropbox folder so you have access across devices.

Open the basher_config.cfg in your text editor and fill in the variables listed.

You must execute ```$ bash basher.sh``` from it's directory or use an alias to execute it anywhere.

To start Basher with an alias, add this line to your .bash_profile. Call the alias whatever you like.
```alias basher='bash ~/directory/to/basher.sh'```

Run ```$ bash basher.sh -test``` to get started.

Further examples will be shown using the alias 'basher'.

## Usage

Basher is currently built to handle a single workflow. One that uses Git for version control and Apache servers for hosting multiple sites. If this sounds like you then Basher's your new best friend.

Be sure to open the basher_config.cfg file before you head to the terminal and fill out your server info. Once that's done run ```$ basher -test``` to check your work. Basher will let you know if something is amiss.


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
Code examples coming soon
```



## Change Log
### current v1.0

#### Ready for public release
* Moved to a function based script.
* Configuration file allows for general use.
* More robust error handling for local and SSH processes.
* Adds Apache virtual hosts support.
