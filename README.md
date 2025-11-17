# Aurora Yoga Duet

Aurora Linux customized for the **Lenovo Yoga Duet 7 13IML05 (82AS)** tablet/laptop hybrid.

## Device Specifications

- **Model**: Lenovo Yoga Duet 7 13IML05
- **Type**: 82AS0019US
- **Serial**: YX011CGT
- **CPU**: Intel 10th Gen (Ice Lake) Core i5/i7
- **GPU**: Intel Iris Plus Graphics
- **Display**: 13.0" 2160x1350 touchscreen
- **Digitizer**: ELAN touchscreen with AES 2.0 stylus support
- **Pen**: Lenovo Digital Pen (4096 pressure levels)
- **Sensors**: Accelerometer/Gyroscope for auto-rotation
- **WiFi**: Intel WiFi 6 AX201
- **Bluetooth**: 5.0

## Features

This image includes everything from [Aurora](https://github.com/ublue-os/aurora) plus:

### Tablet/2-in-1 Support
- **Auto-rotation** via iio-sensor-proxy
- **Touchscreen gestures** via touchegg
- **On-screen keyboard** (Maliit for KDE)
- **Stylus support** with custom libwacom definitions
- **Tablet mode helpers** (`yoga-tablet-mode`, `yoga-rotate-screen`)

### Intel Optimizations
- **Intel graphics** acceleration (intel-media-driver, libva)
- **Thermal management** via thermald
- **Power management** via TLP (optimized for tablet use)
- **Intel GPU tweaks** (PSR, FBC, GuC enabled)

### Power Management
- **TLP** with Yoga Duet-specific configuration
- **Battery charge thresholds** (if supported by EC)
- **WiFi power saving** on battery
- **USB autosuspend** enabled

## Installation

### Rebase from Existing Fedora Atomic

```bash
# Rebase to Aurora Yoga Duet
rpm-ostree rebase ostree-unverified-registry:ghcr.io/danielbodnar/aurora-yoga-duet:latest

# Reboot
systemctl reboot
```

### Fresh Install (ISO)

Download the ISO from [Releases](https://github.com/danielbodnar/aurora-yoga-duet/releases) and boot from USB.

## Building Locally

### Prerequisites

- Podman or Docker
- Just command runner (`curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash`)

### Build Commands

```bash
# Build container image
just build

# Build with specific Aurora base tag
just build aurora-yoga-duet latest stable

# Build QCOW2 VM image
just build-qcow2

# Build ISO installer
just build-iso

# Run in VM (for testing)
just run-vm
```

### Available Just Commands

```bash
just --list
```

## GitHub Actions Setup

### First-Time Setup

When forking this repository, the GitHub Actions workflow may fail with a 403 error on the first run. This is because the GitHub Container Registry package doesn't exist yet. There are two ways to resolve this:

#### Option 1: Wait for Automatic Creation (Recommended)

The workflow is configured to automatically create the package on first push to the `main` branch. Simply:

1. Ensure GitHub Actions is enabled in your fork (Settings → Actions → General)
2. Push a commit to the `main` branch (or your repository's default branch)
3. The package should be created automatically

> **Note:** Manually triggering the workflow (via "Run workflow") will not create the package unless you select the default branch as the source. For most users, pushing to the default branch is the most reliable method. If you get a 403 error, try option 2.

#### Option 2: Manual First Push

If the automatic creation fails, you can create the package manually:

```bash
# Login to GHCR
echo $GITHUB_TOKEN | podman login ghcr.io -u <your-username> --password-stdin

# Build the image
just build

# Tag and push manually
podman tag localhost/aurora-yoga-duet:latest ghcr.io/<your-username>/aurora-yoga-duet:latest
podman push ghcr.io/<your-username>/aurora-yoga-duet:latest
```

After the first successful push, subsequent GitHub Actions runs should work automatically.

### Workflow Triggers

The build workflow triggers on:
- Push to `main` branch
- Pull requests to `main`
- Weekly schedule (Sundays at 3:00 AM UTC)
- Manual workflow dispatch

### Signing Keys

To enable image signing with cosign:

1. Generate a signing key pair:
   ```bash
   cosign generate-key-pair
   ```

2. Add the private key to repository secrets as `SIGNING_SECRET`
3. Commit the public key (`cosign.pub`) to the repository

## Post-Installation Setup

### 1. Verify Tablet Hardware

```bash
# Check touchscreen
libinput list-devices | grep -i touch

# Check accelerometer
iio-sensor-proxy-test

# Check stylus/digitizer
libwacom-list-local-devices
```

### 2. Configure Auto-Rotation

Auto-rotation should work out of the box via iio-sensor-proxy. To disable:

```bash
# Disable auto-rotation temporarily
gsettings set org.gnome.settings-daemon.plugins.orientation active false

# For KDE, use System Settings > Display and Monitor > Display Configuration
```

### 3. Stylus Calibration

If stylus tracking is inaccurate:

```bash
# Calibrate using xinput (X11) or libinput-gestures
xinput_calibrator
```

### 4. Power Management

TLP is pre-configured for optimal battery life:

```bash
# Check TLP status
sudo tlp-stat -s

# View battery status
sudo tlp-stat -b

# Edit configuration
sudo nano /etc/tlp.d/99-yoga-duet.conf
```

## Helper Scripts

### Tablet Mode Toggle

```bash
# Enable tablet mode
yoga-tablet-mode on

# Disable tablet mode
yoga-tablet-mode off

# Check status
yoga-tablet-mode status
```

### Screen Rotation

```bash
# Rotate screen
yoga-rotate-screen normal
yoga-rotate-screen left
yoga-rotate-screen right
yoga-rotate-screen inverted
```

## Troubleshooting

### Touchscreen Not Working

1. Check if ELAN driver is loaded:
   ```bash
   dmesg | grep -i elan
   ```

2. Verify input device:
   ```bash
   cat /proc/bus/input/devices | grep -A 5 ELAN
   ```

### Stylus Not Detected

1. Check libwacom:
   ```bash
   libwacom-list-local-devices
   ```

2. Verify tablet definition is installed:
   ```bash
   ls -la /usr/share/libwacom/lenovo-yoga-duet*.tablet
   ```

### Auto-Rotation Not Working

1. Check iio-sensor-proxy service:
   ```bash
   systemctl status iio-sensor-proxy
   ```

2. Test accelerometer:
   ```bash
   iio-sensor-proxy-test
   ```

### Battery Draining Quickly

1. Check TLP status:
   ```bash
   sudo tlp-stat
   ```

2. Check power consumption:
   ```bash
   powertop --auto-tune
   ```

## Customizing

### Adding Your Own Libwacom Definition

If the included tablet definition doesn't match your device:

1. Get your device ID:
   ```bash
   libwacom-list-local-devices
   ```

2. Edit `/usr/share/libwacom/lenovo-yoga-duet-7.tablet`:
   ```bash
   sudo nano /usr/share/libwacom/lenovo-yoga-duet-7.tablet
   ```

3. Update `DeviceMatch` with your device ID (e.g., `i2c:04F3:XXXX`)

## Contributing

1. Fork this repository
2. Create your feature branch
3. Commit your changes (use conventional commits)
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file.

## Acknowledgments

- [Universal Blue](https://universal-blue.org/) for Aurora and the immutable Fedora ecosystem
- [Fedora Project](https://fedoraproject.org/) for the base operating system
- [libwacom](https://github.com/linuxwacom/libwacom) for tablet support
- Lenovo for (eventually) providing Linux driver support

## Related Projects

- [Aurora](https://github.com/ublue-os/aurora) - Base image
- [Universal Blue](https://github.com/ublue-os) - Cloud-native Fedora images
- [libwacom](https://github.com/linuxwacom/libwacom) - Tablet configuration database
