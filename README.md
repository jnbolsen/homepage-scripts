# Homepage install and update scripts
This script installs [Homepage](https://gethomepage.dev/installation/) from source or updates it if already installed and a newer version is available.

> [!NOTE]
> The script installs dependencies and builds using pnpm [as recommended](https://gethomepage.dev/installation/source/). The latest verison is installed globally using npm.

## Requirements
The following packages are installed:
- node.js
- npm
- curl

```bash
sudo apt install curl node.js npm
```

```bash
sudo npm install -g pnpm
```

## Usage - Install Homepage
Download `install.sh`.

```bash
wget -O install.sh https://raw.githubusercontent.com/jnbolsen/homepage-scripts/refs/heads/main/install.sh
```

Make the scrip executable.

```bash
sudo chmod +x install.sh
```

Run the script.

```bash
sudo ./install.sh
```

## Configuration directory location

`/opt/homepage/config/`

## Tested environments
Ubuntu 22.04, 24.04, and 25.10 <br />
Debian 12 and 13

## Reference
These scripts are similar to the LXC Homepage scripts from [Proxmox VE Helper-Scripts](https://community-scripts.github.io/ProxmoxVE/scripts?id=homepage), but tailored for my personal use and used within the server instead of Proxmox.

## License

[MIT](https://github.com/jnbolsen/homepage-scripts/blob/main/LICENSE.md)
