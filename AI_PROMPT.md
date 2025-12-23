# AI prompt
This file provides guidance to an AI model when working with code in this repository.

## Script purpose
This script automates the installation or update of Homepage, a self-hosted startpage/dashboard for your server, by downloading the latest release from GitHub, building it, and setting it up with systemd.

## Variables used
- `APP`: Name of the application (homepage)
- `LOCAL_IP`: Local IPv4 address of the machine
- `RELEASE`: Latest Github release tag for Homepage
- `VERSION_FILE`: Path to file storing the currently installed version
- `DOMAIN`: Internal network domain, if available
- `INSTALLED_VERSION`: Current version read from `VERSION_FILE`
- `NEW_INSTALLATION`: Boolean flag indicating if this is a new install

## Directories
- Installation: `/opt/homepage`
- Homepage configuration: `/opt/homepage/config`
- Download: `/tmp`
- `VERSION_FILE` location: `/opt`

## Script summary
1. Set initial variables
   - `APP`, `LOCAL_IP`, `RELEASE`, `VERSION_FILE`, and `DOMAIN`.
2. Validation checks
   - Ensure `RELEASE` and `LOCAL_IP` are valid.
   - Check that script runs as root.
   - Confirm `curl` and `npm` are installed.
3. Determine installation type
   - If `VERSION_FILE` does not exist → new installation.
   - If `VERSION_FILE` exists but doesn't match `RELEASE` → update.
   - If version matches → exit (no action needed).
4. System preparation
   - Update system packages.
   - Upgrade `pnpm` (install if missing).
5. Download and extract source
   - Download latest release tarball using GitHub API.
   - Extract into `/tmp`.
6. Copy files to install directory
   - Move extracted source to `/opt/homepage`.
7. Cleanup
   - Remove temporary files in `/tmp`.
8. New installation steps only
   - Copy skeleton config files from `src/skeleton` to `/opt/APP/config`.
   - Create `.env` file with `HOMEPAGE_ALLOWED_HOSTS` variable, which adds `LOCAL_IP:3000` and `APP.DOMAIN:3000`.
   - Set up systemd service file.
9. Build & install dependencies
   - Run `pnpm install`.
   - Run `pnpm build`.
10. Finalize
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
- The script assumes curl, npm, and pnpm are available.
- It uses systemd for service management.
- Config files and environment variables are preserved during updates.
- This approach ensures consistent, reproducible deployments of Homepage.
- Create and populate version file with new release version.
- Reload systemd and enable the service only for new installations, otherwise restart the service only.
