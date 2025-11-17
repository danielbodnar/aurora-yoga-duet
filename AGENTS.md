# AGENTS.md - Aurora Yoga Duet

Custom Aurora image for Lenovo Yoga Duet 7 13IML05 (82AS) tablet/laptop.

## Build Commands
```bash
just build                           # Build container image
just build-ghcr                      # Build for GitHub Container Registry
just lint                            # Run shellcheck on scripts
just check                           # Validate Just syntax
just clean                           # Remove build artifacts
```

## Code Style Guidelines
- **Shell scripts**: Use `set -ouex pipefail` at script start
- **Shebang**: Use `#!/usr/bin/bash` or `#!/usr/bin/env bash`
- **Package installs**: Use `dnf5 -y install` (not dnf or yum)
- **Naming**: Files in kebab-case, scripts numbered for execution order (00-, 01-, 02-)
- **Error handling**: Fail fast with pipefail; no silent failures
- **Formatting**: End files with newline, no trailing whitespace

## Project Structure
- `Containerfile` - Uses Aurora as base, adds Yoga-specific customizations
- `build_files/yoga/` - Yoga Duet 7 specific build scripts (executed in numeric order)
- `build_files/shared/` - Main build orchestration
- `system_files/` - Static configuration files copied into image
- `lenovo-firmware/` - Lenovo-specific firmware and drivers
- `disk_config/` - Bootc image builder configurations

## Key Files for Tablet Support
- `build_files/yoga/00-yoga-duet-packages.sh` - Tablet/stylus/sensor packages
- `build_files/yoga/01-lenovo-firmware.sh` - Intel GPU, TLP, udev rules
- `build_files/yoga/02-yoga-duet-tweaks.sh` - KDE tablet mode, helper scripts
- `system_files/shared/usr/share/libwacom/*.tablet` - Custom tablet definitions

## Key Constraints
- Base image: `ghcr.io/ublue-os/aurora` (not raw Fedora)
- Must pass `bootc container lint`
- Uses conventional commits for git history
- Never commit `cosign.key` (signing secret)
- Target device: Lenovo Yoga Duet 7 13IML05 (82AS0019US)
