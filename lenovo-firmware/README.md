# Lenovo Yoga Duet 7 Firmware and Drivers

This directory contains firmware and drivers extracted from Lenovo's official sources.

## Device Information

- **Model**: Lenovo Yoga Duet 7 13IML05
- **Type**: 82AS0019US
- **Serial**: YX011CGT
- **Support URL**: https://pcsupport.lenovo.com/us/en/products/laptops-and-netbooks/yoga-series/yoga-duet-7-13iml05/82as/82as0096us/yx011cgt/downloads/driver-list

## Source Files

### From Lenovo COPR (epel-8-x86_64)

Downloaded from: https://copr.fedorainfracloud.org/coprs/lenovo/updates/

- `libwacom-1.3-2.el8.src.rpm` - Source RPM containing Lenovo tablet definitions
- `libwacom-data-1.3-2.el8.noarch.rpm` - Binary package with tablet data files

**Note**: These packages are from June 2020 (5 years old) and contain older tablet definitions. The Yoga Duet 7 may not be included, requiring custom definitions.

### Required Windows Drivers to Extract

Since the Lenovo support page requires JavaScript and the COPR is outdated, you need to:

1. Visit the Lenovo support page in a browser
2. Download these driver categories:
   - **BIOS Update** - Latest firmware
   - **Intel Graphics Driver** - Contains GuC/HuC firmware
   - **Audio (Realtek)** - Sound configuration
   - **Touchscreen** - ELAN digitizer driver (contains calibration data)
   - **Bluetooth** - Intel Bluetooth firmware
   - **WiFi** - Intel AX201 driver

### Extraction Process

1. **Download drivers** from Lenovo support page
2. **Extract using** cabextract, 7z, or unzip (depending on format)
3. **Look for** .inf files (contain hardware IDs and configurations)
4. **Extract firmware** .bin files if present

Example:
```bash
# Extract Windows driver package
cabextract driver.cab

# Find INF files (contain device IDs)
find . -name "*.inf" -exec grep -l "04F3" {} \;

# Extract actual firmware binaries
find . -name "*.bin" -type f
```

## libwacom Package Analysis

The Lenovo COPR libwacom (1.3-2) contains:

- 255 tablet definition files
- Multiple ELAN digitizer definitions (04F3:xxxx)
- Lenovo ThinkPad/Yoga models (but NOT Yoga Duet 7)

Key files for reference:
- `elan-29b6.tablet` - ASUS ZenBook with similar ELAN digitizer
- `isdv4-*.tablet` - Lenovo ThinkPad models

## Custom Tablet Definition

Since the Yoga Duet 7 is not in the old libwacom package, we created:

- `/system_files/shared/usr/share/libwacom/lenovo-yoga-duet-7.tablet`
- `/system_files/shared/usr/share/libwacom/lenovo-digital-pen.stylus`

These need to be updated with actual device IDs from your hardware. Run:
```bash
yoga-gather-hardware-info
```

## Intel Sound Open Firmware (SOF)

The Lenovo COPR also contains:
- `alsa-sof-firmware-1.4.2-7.el8` - Intel SOF firmware

This is already included in Fedora's linux-firmware package, so we don't need to extract it separately.

## Important Notes

1. **Windows drivers are proprietary** - We extract only hardware IDs and configuration data
2. **Firmware binaries** - Intel already provides these in linux-firmware package
3. **BIOS updates** - Must be done via fwupd or Windows (not image build)
4. **Calibration data** - Touchscreen calibration is device-specific

## Future Work

- [ ] Extract exact ELAN digitizer ID from actual device
- [ ] Verify accelerometer configuration
- [ ] Test stylus pressure sensitivity calibration
- [ ] Validate TLP power management settings
- [ ] Check if additional SOF firmware is needed
