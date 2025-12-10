# Homepage-scripts
These are scripts to install and update homepage. They are similar to [ttek's homepage lxc scripts](https://community-scripts.github.io/ProxmoxVE/scripts?id=homepage), but used within a server instead of proxmox and tailored for my personal use.

## Requirements
The following packages are installed:
- node.js
- npm
- pnpm
- curl

`sudo apt install curl node.js npm`

`sudo npm install -g pnpm`

## Using - Install Homepage
1. Clone the repository in a directory of your choosing.  Usually the user home directory.
2. Make the scrip executable, `sudo chmod +x install.sh`.
3. Run the script, `sudo ./install.sh`

## Using - Update Homepage
1. Clone the repository in a directory of your choosing, if you have not already.  Usually the user home directory.
2. Make the scrip executable, `sudo chmod +x update.sh`.
3. Run the script, `sudo ./update.sh`

## Configuration Directory Location

`/opt/homepage/config/`
