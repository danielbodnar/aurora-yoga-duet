#!/usr/bin/bash

set -ouex pipefail

echo "=== Building Aurora Yoga Duet 7 ==="
echo "Base Image: Aurora"
echo "Target Device: Lenovo Yoga Duet 7 13IML05 (82AS)"

# Run Yoga-specific build scripts in order
for script in /ctx/build_files/yoga/*.sh; do
    if [[ -f "$script" ]]; then
        echo "=== Running $(basename "$script") ==="
        bash "$script"
    fi
done

# Copy system files
echo "=== Copying Yoga Duet system files ==="
if [[ -d /ctx/system_files/shared ]]; then
    rsync -rlpog /ctx/system_files/shared/ /
fi

if [[ -d /ctx/system_files/yoga ]]; then
    rsync -rlpog /ctx/system_files/yoga/ /
fi

# Update os-release for branding
echo "=== Updating OS branding ==="
sed -i "s/^NAME=.*/NAME=\"Aurora Yoga Duet\"/" /usr/lib/os-release
sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"Aurora Yoga Duet (Fedora ${FEDORA_MAJOR_VERSION})\"/" /usr/lib/os-release
sed -i "s/^ID=.*/ID=aurora-yoga-duet/" /usr/lib/os-release
sed -i "s/^VARIANT_ID=.*/VARIANT_ID=yoga-duet/" /usr/lib/os-release

# Add custom fields
if ! grep -q "^IMAGE_VENDOR=" /usr/lib/os-release; then
    echo "IMAGE_VENDOR=\"${IMAGE_VENDOR:-danielbodnar}\"" >> /usr/lib/os-release
fi

echo "=== Build complete ==="
