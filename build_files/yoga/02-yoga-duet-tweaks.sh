#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

echo "=== Applying Yoga Duet 7 system tweaks ==="

# KDE Plasma tablet mode configuration
echo "Configuring KDE Plasma for tablet mode..."
mkdir -p /etc/xdg/plasma-workspace/env
cat > /etc/xdg/plasma-workspace/env/yoga-duet-tablet.sh << 'EOF'
#!/bin/bash
# Enable tablet mode detection for Yoga Duet 7
# KDE will automatically switch to tablet mode when accelerometer detects orientation change

# Export for Qt/Plasma
export QT_QUICK_CONTROLS_MOBILE=0
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_ENABLE_HIGHDPI_SCALING=1

# Plasma tablet mode will be handled by iio-sensor-proxy
EOF
chmod +x /etc/xdg/plasma-workspace/env/yoga-duet-tablet.sh

# Touch-friendly defaults for KDE
echo "Setting touch-friendly KDE defaults..."
mkdir -p /etc/xdg/kdeglobals.d
cat > /etc/xdg/kdeglobals.d/yoga-duet-touch.conf << 'EOF'
[KDE]
SingleClick=true
ScrollbarLeftClickNavigatesByPage=false

[General]
fixed=Noto Sans Mono,11,-1,5,50,0,0,0,0,0
font=Noto Sans,11,-1,5,50,0,0,0,0,0
menuFont=Noto Sans,11,-1,5,50,0,0,0,0,0
smallestReadableFont=Noto Sans,9,-1,5,50,0,0,0,0,0
toolBarFont=Noto Sans,11,-1,5,50,0,0,0,0,0
EOF

# libinput configuration for touchscreen and stylus
echo "Configuring libinput for touchscreen..."
mkdir -p /etc/libinput
cat > /etc/libinput/local-overrides.quirks << 'EOF'
# Lenovo Yoga Duet 7 touchscreen quirks
[Lenovo Yoga Duet 7 Touchscreen]
MatchUdevType=touchscreen
MatchBus=i2c
MatchVendor=0x04F3
AttrSizeHint=293x165
AttrTouchSizeRange=80:60
AttrPalmSizeThreshold=1000

[Lenovo Yoga Duet 7 Stylus]
MatchUdevType=tablet
MatchBus=i2c
MatchVendor=0x04F3
AttrTabletSmoothing=0.5
EOF

# Improve touchpad/touch response
mkdir -p /etc/libinput/local-overrides.d
cat > /etc/libinput/local-overrides.d/99-yoga-duet.conf << 'EOF'
# Additional libinput tweaks for Yoga Duet 7
# Reduce touch latency and improve palm rejection
EOF

# GRUB configuration for better tablet experience
echo "Configuring GRUB for tablet mode..."
if [[ -f /etc/default/grub ]]; then
    # Add kernel parameters for better tablet support
    if ! grep -q "i915.enable_psr=1" /etc/default/grub; then
        sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="i915.enable_psr=1 i915.enable_fbc=1 /' /etc/default/grub
    fi
fi

# Disable auto-rotate lock by default (user preference)
# User can enable/disable via KDE settings

# Create helper script for tablet mode toggle
echo "Creating tablet mode helper scripts..."
cat > /usr/bin/yoga-tablet-mode << 'EOF'
#!/bin/bash
# Toggle tablet mode for Yoga Duet 7
# Usage: yoga-tablet-mode [on|off|status]

case "$1" in
    on)
        qdbus org.kde.KWin /Tablet org.kde.KWin.TabletModeManager.setTabletMode true
        echo "Tablet mode enabled"
        ;;
    off)
        qdbus org.kde.KWin /Tablet org.kde.KWin.TabletModeManager.setTabletMode false
        echo "Tablet mode disabled"
        ;;
    status)
        if qdbus org.kde.KWin /Tablet org.kde.KWin.TabletModeManager.tabletMode 2>/dev/null; then
            echo "Tablet mode is currently enabled"
        else
            echo "Tablet mode is currently disabled"
        fi
        ;;
    *)
        echo "Usage: yoga-tablet-mode [on|off|status]"
        echo "Toggle tablet mode for Yoga Duet 7"
        exit 1
        ;;
esac
EOF
chmod +x /usr/bin/yoga-tablet-mode

# Screen rotation helper
cat > /usr/bin/yoga-rotate-screen << 'EOF'
#!/bin/bash
# Rotate screen for Yoga Duet 7
# Usage: yoga-rotate-screen [normal|left|right|inverted]

ROTATION="${1:-normal}"

case "$ROTATION" in
    normal|left|right|inverted)
        kscreen-doctor output.1.rotation."$ROTATION"
        echo "Screen rotated to: $ROTATION"
        ;;
    *)
        echo "Usage: yoga-rotate-screen [normal|left|right|inverted]"
        exit 1
        ;;
esac
EOF
chmod +x /usr/bin/yoga-rotate-screen

# Virtual keyboard configuration
echo "Configuring virtual keyboard..."
mkdir -p /etc/xdg/maliit.d
cat > /etc/xdg/maliit.d/maliit-server.conf << 'EOF'
[General]
ActivePluginId=libmaliit-keyboard.so
EOF

echo "::endgroup::"
