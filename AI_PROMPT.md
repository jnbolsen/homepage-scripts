# AI Prompt
This file provides guidance to an AI model when working with code in this repository.

## Repository overview
This repository contains a script that installs and updates Homepage from source.

<https://github.com/jnbolsen/homepage-scripts>

### Variables
- `APP`: homepage.
- `LOCAL_IP`: Local IPv4 address of machine.
- `RELEASE`: Latest release version, pulled from the Homepage Github repository.
- `VERSION_FILE`: Location of version file, where current version installed is listed.
- `INSTALLED_VERSION`: Installed version, pulled from `VERSION_FILE`.
- `NEW_INSTALLATION`: True mean new installation, false means update existing installation.

## Directories
- Installation directory: `/opt/homepage`
- Working directory: '/tmp`
- Version file location: `/opt`

## Script summary
- Set variables `APP`, `LOCAL_IP`, and `RELEASE`.
- Checks if `RELEASE` variable was fetched correctly, `LOCAL_IP` variable was fetched correctly, script is running as root, curl is installed, and npm is installed.
- Checks for the presence of `VERSION_FILE`. If it does not exist, proceed as a new installation. If it exists and does not match current release, proceed as update. If it exists and matches current release, exit.
- Updates packages, upgrades packages, and updates pnpm (or installs if not present).
- Downloads source code from the Hopeage Github repository using `RELEASE` tag and places it in `/tmp`.
- Extracts the source code in `/tmp`.
- Copies extracted directory from `/tmp` to `/opt/{$APP}`.
- Cleans up `/tmp`.
- Does the following if it is a new installation, otherwise skip for update only.
  - Copy `/opt/${APP}/src/skeleton/*` to the config directory `/opt/${APP}/config/`. The files in `/src/skeleton` are default configuration files. Do not copy these to the config directory if there is an existing install, as it is assumed that config files are already present.
  - Create and populate environment file `.env` with allowed hosts using variable `HOMEPAGE_ALLOWED_HOSTS`. Do not create this if there is an existing install, as it is assumed to already be created.
  - Create a systemd service `${APP}.service`. Do not create this if there is an existing install, as it is assumed to already be created.
- Install dependencies with pnpm.
- Build with pnpm.
- Create and populate version file with new release version.
- Reload systemd and enable the service only for new installations, otherwise restart the service only.
