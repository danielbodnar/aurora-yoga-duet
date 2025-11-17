#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# This script documents expected hardware IDs for Lenovo Yoga Duet 7 13IML05
# These IDs are used by udev rules and libwacom for proper device detection

echo "=== Expected Hardware IDs for Yoga Duet 7 13IML05 (82AS) ==="

# Document expected device IDs (for reference in libwacom and udev rules)
cat > /usr/share/doc/aurora-yoga-duet/hardware-ids.txt << 'EOF'
# Lenovo Yoga Duet 7 13IML05 (82AS) Expected Hardware IDs
# Last updated: 2024

## CPU
Intel Core i5-10210U or i7-10510U (Ice Lake)
PCI ID: 8086:8a12 (Iris Plus Graphics)

## Touchscreen/Digitizer (ELAN)
# Common ELAN IDs for Yoga Duet 7:
# i2c:04F3:2A49 (variant 1)
# i2c:04F3:2A4A (variant 2)
# i2c:04F3:2A62 (variant 3)
# i2c:04F3:2A69 (variant 4)
# Run: libwacom-list-local-devices to confirm actual ID on your device

## WiFi
Intel WiFi 6 AX201
PCI ID: 8086:a0f0 or 8086:02f0

## Bluetooth
Intel Bluetooth
USB ID: 8087:0026

## Audio
Intel Ice Lake PCH-LP cAVS
PCI ID: 8086:34c8

## Camera (Front)
USB ID varies by firmware version

## IR Camera (Windows Hello)
USB ID varies

## Accelerometer/Gyroscope
BOSH BMI160 or similar
IIO device - iio:deviceX

## To get actual IDs from your device, run:
# lspci -nn
# lsusb
# libwacom-list-local-devices
# cat /sys/bus/iio/devices/*/name

EOF

mkdir -p /usr/share/doc/aurora-yoga-duet

# Create a helper script to run on the actual device
cat > /usr/bin/yoga-gather-hardware-info << 'EOF'
#!/bin/bash
# Gather hardware information from Yoga Duet 7
# Run this script to update libwacom definitions with correct device IDs

echo "=== Lenovo Yoga Duet 7 Hardware Information ==="
echo "Run date: $(date)"
echo ""

echo "=== DMI Information ==="
cat /sys/class/dmi/id/product_name 2>/dev/null || echo "Not available"
cat /sys/class/dmi/id/product_serial 2>/dev/null || echo "Not available"
echo ""

echo "=== PCI Devices ==="
lspci -nn 2>/dev/null || echo "lspci not available"
echo ""

echo "=== USB Devices ==="
lsusb 2>/dev/null || echo "lsusb not available"
echo ""

echo "=== Input Devices ==="
cat /proc/bus/input/devices 2>/dev/null | grep -A 10 "ELAN\|Wacom\|Pen\|Touch" || echo "No input devices found"
echo ""

echo "=== Libwacom Devices ==="
if command -v libwacom-list-local-devices &> /dev/null; then
    libwacom-list-local-devices
else
    echo "libwacom-list-local-devices not available"
fi
echo ""

echo "=== IIO Sensors ==="
for dev in /sys/bus/iio/devices/iio:device*; do
    if [[ -d "$dev" ]]; then
        echo "Device: $(basename $dev)"
        cat "$dev/name" 2>/dev/null || echo "  Name: unknown"
    fi
done
echo ""

echo "=== Graphics ==="
lspci -nn | grep -i vga || echo "No VGA device found"
echo ""

echo "=== WiFi ==="
lspci -nn | grep -i network || echo "No network device found"
echo ""

echo "=== Bluetooth ==="
lsusb | grep -i bluetooth || echo "No Bluetooth device found"
echo ""

echo "=== Recommended Actions ==="
echo "1. If touchscreen/stylus ID differs from libwacom definition:"
echo "   sudo nano /usr/share/libwacom/lenovo-yoga-duet-7.tablet"
echo "   Update DeviceMatch with your actual i2c:04F3:XXXX ID"
echo ""
echo "2. If accelerometer not detected:"
echo "   Check iio-sensor-proxy: systemctl status iio-sensor-proxy"
echo ""
echo "3. Save this output for bug reports:"
echo "   yoga-gather-hardware-info > ~/yoga-hardware-info.txt"
EOF
chmod +x /usr/bin/yoga-gather-hardware-info

echo "=== Hardware detection helpers installed ==="
echo "Run 'yoga-gather-hardware-info' on your device to gather hardware IDs"

echo "::endgroup::"
