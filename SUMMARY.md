# Summary
This file provides a summary of what the install script does.

> [!TIP]
> It can also provide guidance to an AI model when working with this script.

## Script purpose
This script automates the installation or update of Homepage, a self-hosted startpage/dashboard for your server, by downloading the latest release from GitHub, building it, and setting it up with systemd.

## Variables used
- `APP`: Name of the application (homepage)
- `LOCAL_IP`: Local IPv4 address of the machine
- `RELEASE`: Latest Github release tag for Homepage
- `VERSION_FILE`: Path to file storing the currently installed version
- `DOMAIN`: Internal network domain, if available
- `INSTALLED_VERSION`: Current version (if installed), read from `VERSION_FILE`
- `NEW_INSTALLATION`: Boolean flag indicating if this is a new install

## Directories used
- Installation: `/opt/homepage`
- Working (cleaned after installation): `/tmp`
- Configuration: `/opt/homepage/config`

## Script summary
1. Set initial variables
   - `APP`, `LOCAL_IP`, `RELEASE`, `VERSION_FILE`, and `DOMAIN`.
2. Validation checks
   - Ensure `RELEASE` and `LOCAL_IP` are valid.
   - Check that script runs as root.
   - Confirm curl, node.js, and npm are installed.
3. Determine installation type
   - If `VERSION_FILE` does not exist → new installation.
   - If `VERSION_FILE` exists but `INSTALLED_VERSION` doesn't match `RELEASE` → update.
   - If `INSTALLED_VERSION` matches `RELEASE` → exit (no action needed).
4. System preparation
   - Update and upgrade system packages.
   - Install or upgrade pnpm.
5. Download and extract source
   - Download latest release tarball using GitHub API into `/tmp`.
   - Extract.
6. Copy files to install directory and cleanup
   - Copy extracted source to `/opt/homepage`.
   - Remove download and extracted files in `/tmp`.
7. New installation steps only
   - Copy default config files from `src/skeleton` to `/opt/APP/config`.
   - Create `.env` file with `HOMEPAGE_ALLOWED_HOSTS` variable, which adds `localhost:3000`, `LOCAL_IP:3000`, and `APP.DOMAIN:3000`.
   - Set up systemd service file.
8. Build & install dependencies
   - Run `pnpm install`.
   - Run `pnpm build`.
9. Finalize
   - Write new version to `VERSION_FILE`.
   - For new installs:
     - Reload systemd daemon.
     - Enable the service.
     - Start the service.
   - For updates:
     - Restart the service only.

## Key features implemented
- Idempotent behavior: Won't reinstall if already up-to-date.
- Supports both fresh install and updates.
- Uses pnpm for dependency management.
- Automatically sets up systemd service.
- Handles cleanup and configuration appropriately.

## Notes
- Systemd is used for service management.
- Config files and environment variables are preserved during updates.
- This approach ensures consistent, reproducible deployments of Homepage.
- Create and populate version file with new release version.
- Reload systemd and enable the service only for new installations, otherwise restart the service only.
