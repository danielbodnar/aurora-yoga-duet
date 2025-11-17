#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Yoga Duet 7 13IML05 (82AS) specific packages
# Hardware: Intel 10th Gen (Ice Lake), ELAN touchscreen/stylus, accelerometer

# Tablet and 2-in-1 support packages
YOGA_PACKAGES=(
    # Sensor/accelerometer support for auto-rotation
    iio-sensor-proxy
    
    # Intel graphics and media acceleration
    intel-media-driver
    libva-intel-driver
    libva-utils
    
    # Intel thermal management
    thermald
    
    # Power management
    powertop
    tlp
    tlp-rdw
    
    # Touchscreen and stylus support
    libwacom
    libwacom-data
    xf86-input-wacom
    
    # Multi-touch gestures
    touchegg
    
    # On-screen keyboard (KDE provides Maliit)
    maliit-keyboard
    maliit-framework
    
    # Bluetooth audio codecs (for wireless accessories)
    pipewire-codec-aptx
    
    # Additional firmware
    linux-firmware
    intel-gpu-firmware
    
    # Input testing and debugging
    evtest
    libinput-utils
)

echo "Installing ${#YOGA_PACKAGES[@]} Yoga Duet 7 specific packages..."
dnf5 -y install "${YOGA_PACKAGES[@]}" || {
    echo "Warning: Some packages may not be available, installing what we can..."
    for pkg in "${YOGA_PACKAGES[@]}"; do
        dnf5 -y install "$pkg" || echo "Package $pkg not available"
    done
}

# Enable services for tablet functionality
echo "Enabling tablet-related services..."
systemctl enable iio-sensor-proxy.service || true
systemctl enable thermald.service || true
systemctl enable tlp.service || true
systemctl enable touchegg.service || true

# Disable conflicting services
systemctl disable power-profiles-daemon.service || true  # Conflicts with TLP

echo "::endgroup::"
