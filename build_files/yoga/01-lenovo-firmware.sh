#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Install Lenovo Yoga Duet 7 13IML05 specific firmware and configurations
# Device: 82AS0019US / S/N: YX011CGT
# Hardware IDs:
# - Intel Ice Lake (10th gen) CPU/GPU
# - ELAN touchscreen digitizer
# - Intel WiFi 6 AX201
# - Lenovo Digital Pen (AES protocol)

echo "=== Installing Lenovo Yoga Duet 7 firmware ==="

# Copy custom libwacom tablet definition if provided
if [[ -d /ctx/system_files/shared/usr/share/libwacom ]]; then
    echo "Installing custom libwacom tablet definitions..."
    cp -v /ctx/system_files/shared/usr/share/libwacom/*.tablet /usr/share/libwacom/ 2>/dev/null || true
    cp -v /ctx/system_files/shared/usr/share/libwacom/*.stylus /usr/share/libwacom/ 2>/dev/null || true
fi

# Intel i915 (Iris Plus Graphics) optimizations
echo "Configuring Intel graphics..."
cat > /usr/lib/modprobe.d/i915-yoga-duet.conf << 'EOF'
# Intel Ice Lake (Iris Plus Graphics) optimizations for Yoga Duet 7
options i915 enable_guc=3
options i915 enable_fbc=1
options i915 enable_psr=1
options i915 fastboot=1
EOF

# Power saving for Intel sound
cat > /usr/lib/modprobe.d/snd-hda-intel-yoga.conf << 'EOF'
# Intel HDA audio power saving
options snd_hda_intel power_save=1
options snd_hda_intel power_save_controller=Y
EOF

# ELAN touchscreen/digitizer configurations
echo "Configuring ELAN touchscreen/digitizer..."
cat > /usr/lib/udev/rules.d/99-yoga-duet-touchscreen.rules << 'EOF'
# Lenovo Yoga Duet 7 13IML05 ELAN touchscreen/digitizer
# Improve touchscreen response and palm rejection

# ELAN touchscreen - set libinput calibration
ACTION=="add|change", KERNEL=="event*", SUBSYSTEM=="input", \
  ENV{ID_INPUT_TOUCHSCREEN}=="1", ENV{ID_VENDOR_ID}=="04f3", \
  ENV{LIBINPUT_CALIBRATION_MATRIX}="1 0 0 0 1 0"

# Enable tap-to-click for touchscreen
ACTION=="add|change", KERNEL=="event*", SUBSYSTEM=="input", \
  ENV{ID_INPUT_TOUCHSCREEN}=="1", \
  ENV{LIBINPUT_ATTR_CLICK_METHOD_ENABLED}="1"
EOF

# Accelerometer/gyroscope configuration for screen rotation
echo "Configuring accelerometer..."
cat > /usr/lib/udev/rules.d/99-yoga-duet-sensors.rules << 'EOF'
# Lenovo Yoga Duet 7 accelerometer calibration
# Adjust orientation matrix if screen rotation is incorrect

# Generic IIO accelerometer rules
ACTION=="add|change", KERNEL=="iio:device*", SUBSYSTEM=="iio", \
  ATTR{name}=="accel_3d", \
  ENV{IIO_SENSOR_PROXY_TYPE}="iio-poll-accel"
EOF

# TLP power management configuration for Yoga Duet 7
echo "Configuring TLP for Yoga Duet 7..."
cat > /etc/tlp.d/99-yoga-duet.conf << 'EOF'
# TLP configuration for Lenovo Yoga Duet 7 13IML05
# Optimized for tablet/2-in-1 usage with battery longevity

# CPU frequency scaling
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_SCALING_GOVERNOR_ON_BAT=powersave

# Intel CPU energy/performance policies
CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance
CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power

# Intel GPU frequency limits
INTEL_GPU_MIN_FREQ_ON_AC=0
INTEL_GPU_MIN_FREQ_ON_BAT=0
INTEL_GPU_MAX_FREQ_ON_AC=0
INTEL_GPU_MAX_FREQ_ON_BAT=0
INTEL_GPU_BOOST_FREQ_ON_AC=0
INTEL_GPU_BOOST_FREQ_ON_BAT=0

# WiFi power saving
WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on

# Battery charge thresholds (if supported by EC)
# Uncomment if Lenovo EC supports these
#START_CHARGE_THRESH_BAT0=75
#STOP_CHARGE_THRESH_BAT0=80

# Runtime PM for devices
RUNTIME_PM_ON_AC=auto
RUNTIME_PM_ON_BAT=auto

# USB autosuspend (tablet may have fewer USB devices)
USB_AUTOSUSPEND=1
EOF

# Thermald configuration for Ice Lake
echo "Configuring thermald for Intel Ice Lake..."
# thermald should auto-detect, but we can provide hints
mkdir -p /etc/thermald
cat > /etc/thermald/thermal-cpu-cdev-order.xml << 'EOF'
<?xml version="1.0"?>
<!-- Thermald cooling device order for Yoga Duet 7 -->
<CoolingDevices>
  <CoolingDevice>
    <Type>rapl_controller</Type>
    <Order>1</Order>
  </CoolingDevice>
  <CoolingDevice>
    <Type>intel_pstate</Type>
    <Order>2</Order>
  </CoolingDevice>
  <CoolingDevice>
    <Type>cpufreq</Type>
    <Order>3</Order>
  </CoolingDevice>
</CoolingDevices>
EOF

echo "::endgroup::"
