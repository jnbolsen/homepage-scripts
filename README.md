# HOMEPAGE-SCRIPTS
These are scripts to easily install and update [Homepage](https://gethomepage.dev/installation/) on an Ubuntu server. They are similar to the LXC Homepage scripts from [Proxmox VE Helper-Scripts](https://community-scripts.github.io/ProxmoxVE/scripts?id=homepage), but tailored for my personal use and used within the server instead of Proxmox.

Right now these are set to be verbose but can be changed by removing `-x` at the top of each script.

## Requirements
The following packages are installed:
- node.js
- npm
- pnpm
- curl

`sudo apt install curl node.js npm`

`sudo npm install -g pnpm`

## Using - Install Homepage
1. Clone the repository in a directory of your choosing, usually the user home directory.

git clone `https://github.com/jnbolsen/ezarr.git`

2. Make the scrip executable - `sudo chmod +x install.sh`.
3. Run the script - `sudo ./install.sh`.

## Using - Update Homepage
1. Clone the repository in a directory of your choosing, if you have not already, usually the user home directory.
2. Make the scrip executable - `sudo chmod +x update.sh`.
3. Run the script - `sudo ./update.sh`.

## Configuration Directory Location

`/opt/homepage/config/`
