# Custom Functionality
Useful custom scripts I use in my setups.
There are various functionalities included here, and can be accessed
in the appropriate sections:

[Setup](#initial-setup)  
[Requirements](#requirements)  
[Tunneling & Mounting](#tunneling-and-mounting)  
[VIM](#vim)


## Initial Setup
My recommendation for quick setup is to clone the repo as hidden in the home directory. E.g.,

`git clone https://github.com/zhampel/custom_scripts.git ~/.custom_scripts`

Then, one can add in sourcing lines in `~/.bashrc` (`~/.bash_profile` on a MacOS)
to have access to the functions on the cmd line.
For me these lines are:

```
source ${HOME}/.custom_scripts/bash/ipython_tunnel.sh
source ${HOME}/.custom_scripts/bash/mnt_machines.sh /Users/${USER}/MNTMachines
```

If you only want specific functionalities, relevant lines are listed in respective sections below.


## Requirements

For SSH tunneling functions, one must have `bash>3`.
Current Linux machines should have at least `bash>=4`,
but for some reason MacOS still holds out at `3.X`.
The output of `bash --version` on my machine gives `3.2.57`.
Thus, to upgrade bash on the terminal on a mac 
(via [homebrew](https://brew.sh/)):

```
brew update && install bash
sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
chsh -s /usr/local/bin/bash
```


## Tunneling & Mounting

### Setup

#### Lines in .bashrc
To setup the SSH and mounting functions, the following lines must be included
in `~/.bashrc` (`~/.bash_profile` on MacOS):

```
source ${HOME}/.custom_scripts/bash/ipython_tunnel.sh
source ${HOME}/.custom_scripts/bash/mnt_machines.sh /Users/${USER}/MNTMachines
```

assuming that this repo was cloned to `~/.custom_scripts`.
This simply gives cmd line access to functions in those two shell scripts.
The argument to `mnt_machines.sh` is the local directory where I access mounted
remote machines.
You can change that to anywhere appropriate, but if you keep that line as I wrote it,
run `mkdir /Users/${USER}/MNTMachines` to avoid a directory dne (does not exist) error.


#### SSH Configuration
The SSH and drive mounting capabilities also require the use of 
a SSH configuration file, i.e. `~/.ssh/config`.
This file contains the necessary information for logging into remote machines.
Here's an example with parameters defined which should facilitate smooth operation:

```
Host ex-machina
    HostName 10.33.0.97
    ForwardAgent yes
    ForwardX11 yes
    IdentityFile /Users/aiava/.ssh/id_rsa
    User ava
```

The first line `Host` defines a simple name, an alias, for the computer with
IP address identified by the `HostName` keyword below.
The following two lines assist in running graphics applications remotely,
and are not necessary for remote cmd line work.
The `IdentityFile` keyword points to the local SSH identification file (i.e. the one without the .pub extension) used for secure access.
This file can be generated locally via `ssh-keygen` or provided via some other service.
Finally, the `User` parameter is the username that you'll use on the remote machine, i.e. `ex-machina`.


### Usage

#### Mounting a Machine
To mount a remote machine and thus have access to its files on your local desktop,
mount it like so, using `ex-machina` as the example remote computer above: `mymnt ex-machina`

It will request user `ava`'s password for the SSH key file.
Simple as that.
You should now find a directory `/Users/${USER}/ex-machina` that points to the home folder on that machine!

To unmount: `unmntme ex-machina`

*Nota bene*:  
- On the terminal, you ***must not be inside*** the mounting directory (`/Users/${USER}/ex-machina` in this case),
as it can cause major hang ups in MacOS Finder and terminal.
Wait till successfully mounting before navigating to the directory via the Finder.

In summary:  
1. To mount: `mymnt ex-machina`  
2. Access files in `MNTMachines/ex-machina` directory  
3. To unmount: `unmtme ex-machina`


#### Tunneling to a Machine
If you have a remote machine running a jupyter notebook that you want to access locally,
you have to first run some lines in both locations.
E.g. on ex-machina, run `jupyter notebook --no-browser --port=8889`, which says
to start a jupyter session without spinning up a browser,
and allow us to listen on ***remote*** port 8889.
Then we can access that session locally by running `ipytunnel ex-machina 8889`, requiring password as usual.
This will spit out a ***local*** port number between 8888-8988, something like this:
`Connected to lambda via port id 8890 with process id 36197`.
Open up a browser and go to `localhost:8890`.
You should now be able to play with the jupyter notebook locally!
To kill the session, run `ipykill 36197` or if you can't recall the process id, 
it can be found via `ipyfind ex-machina`.

*Nota bene*: 
- Allowable port numbers (both local and remote) are limited to the range [8888, 8988].
So only 100 remote notebooks can be opened at once....  
- If there are multiple sessions with `ex-machina` opened, then `ipyfind ex-machina` will show them all, 
or if you remember the local port 8890 `ipyfind 8890` will print the relevant process id.  
- Keep in mind that to have multiple notebooks running on the same ***remote*** server,
they each require different ports, hence the explicit inclusion in the `ipytunnel` command.
Thus, to have two notebooks running on `ex-machina` I would do `jupyter notebook --no-browser --port=8889`
and `jupyter notebook --no-browser --port=8890`, for example.

In summary:

On remote machine `ex-machina`  
1. `jupyter notebook --no-browser --port=ZZZZ`  

On local machine  
2. `ipytunnel ex-machina ZZZZ`  
3. Get ***local*** port XXXX from output of (2), open `localhost:XXXX` in browser.  
4. Work  
5. `ipyfind ex-machina` or `ipyfind XXXX`  
6. `ipykill YYYY`


## VIM

I almost exclusively use VIM as my text editor for 
[reasons](https://www.tecmint.com/reasons-to-learn-vi-vim-editor-in-linux/).

### Run Control File: vimrc
There are a number of nice default that I've found or stolen over the years,
which are included in my `.vimrc` file so that they are default.
To use them yourself, softlinks would be fine or simply copy the file into your home directory:

`cp ~/.custom_scripts/vim/vimrc ~/.vimrc`

Don't forget that period in `~/.vimrc`, otherwise VIM won't use this run-control file.

### Colors
Additionally, I prefer using the distinguished colorscheme, as it's easy on the eyes
and it's already specified in the `.vimrc` included here for your enjoyment.
Simply copy/paste the file `distinguished.vim` into the vim colors directory:

`cp ~/.custom_scripts/vim/colors/distinguished.vim ~/.vim/colors/`

If you desire not to use the distinguished colorscheme and thus don't copy the file, 
no worries, VIM will grab the default scheme.
