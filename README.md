# Homepage Install and Update Scripts
These are scripts to easily install and update [Homepage](https://gethomepage.dev/installation/) from source.

Right now these are set to be verbose but can be changed by removing `-x` at the top of each script.

## Requirements
The following packages are installed:
- node.js
- npm
- pnpm
- curl

`sudo apt install curl node.js npm`

`sudo npm install -g pnpm`

## Usage - Install Homepage
Download `install.sh`.

wget -O install.sh 

Make the scrip executable.

`sudo chmod +x install.sh`

Run the script.

`sudo ./install.sh`

## Usage - Update Homepage
Download `update.sh`.

wget -O update.sh 

Make the scrip executable.

`sudo chmod +x update.sh`

Run the script.

`sudo ./update.sh`

## Configuration Directory Location

`/opt/homepage/config/`

## References
These scripts are similar to the LXC Homepage scripts from [Proxmox VE Helper-Scripts](https://community-scripts.github.io/ProxmoxVE/scripts?id=homepage), but tailored for my personal use and used within the server instead of Proxmox.

## License

[MIT](https://github.com/jnbolsen/homepage-scripts/blob/main/LICENSE.md)
