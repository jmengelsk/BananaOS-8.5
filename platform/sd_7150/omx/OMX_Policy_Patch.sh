# https://github.com/devcore94/MonsterROM/blob/sixteenQPR2/platform/exynos2100/patches/omx/customize.sh

LOG_BEGIN "- Applying omx-patch"
OMX_POLICY="$WORKSPACE/vendor/etc/seccomp_policy/samsung.software.media.c2-base-policy"

if [ -f "$OMX_POLICY" ]; then
    LOG "- Updating mremap rule in $OMX_POLICY"
    # Replace the existing line if present
    sed -i 's/^mremap: arg3 == 3$/mremap: arg3 == 3 || arg3 == MREMAP_MAYMOVE/' "$OMX_POLICY"

    # If the line wasn't found, append it
    if ! grep -q "mremap: arg3 == 3 || arg3 == MREMAP_MAYMOVE" "$OMX_POLICY"; then
        echo "mremap: arg3 == 3 || arg3 == MREMAP_MAYMOVE" >> "$OMX_POLICY"
    fi
fi
LOG_END