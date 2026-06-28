if [ ! -f "$WORKSPACE/system/system/lib64/libbluetooth_jni.so" ]; then
    LOG_BEGIN "- Extracting libbluetooth_jni.so from com.android.bt.apex"
    local TMP_DIR="/tmp/bt"
    mkdir -p "$TMP_DIR"

    unzip -j "$WORKSPACE/system/system/apex/com.android.bt.apex" "apex_payload.img" -d "$TMP_DIR"

    if command -v debugfs &> /dev/null; then
        debugfs -R "dump /lib64/libbluetooth_jni.so $TMP_DIR/libbluetooth_jni.so" "$TMP_DIR/apex_payload.img"
        cp -f "$TMP_DIR/libbluetooth_jni.so" "$WORKSPACE/system/system/lib64/libbluetooth_jni.so"
    else
        if ! sudo -n -v &> /dev/null; then
            LOG "\033[0;33m! Asking user for sudo password\033[0m"
            if ! sudo -v 2> /dev/null; then
                ERROR_EXIT "Root permissions are required to unpack APEX image"
            fi
        fi

        mkdir -p "$TMP_DIR/tmp_out"
        sudo mount -o ro "$TMP_DIR/apex_payload.img" "$TMP_DIR/tmp_out"
        sudo cat "$TMP_DIR/tmp_out/lib64/libbluetooth_jni.so" > "$WORKSPACE/system/system/lib64/libbluetooth_jni.so"
        sudo umount "$TMP_DIR/tmp_out"
    fi

    rm -rf "$TMP_DIR"
    
    LOG_END
fi

# Disable VaultKeeper support
# Before: [tbnz w8, #0, #0xXXXXXX]
# After: [b #0xXXXXXX]
if xxd -p -c 0 "$WORKSPACE/system/system/lib64/libbluetooth_jni.so" | grep -q "39d9199428518152"; then
    HEX_EDIT "system/system/lib64/libbluetooth_jni.so" \
        "39d9199428518152" "000080d228518152"
elif xxd -p -c 0 "$WORKSPACE/system/system/lib64/libbluetooth_jni.so" | grep -q "2897773948050037"; then
    HEX_EDIT "system/system/lib64/libbluetooth_jni.so" \
        "2897773948050037" "289777392a000014"
elif xxd -p -c 0 "$WORKSPACE/system/system/lib64/libbluetooth_jni.so" | grep -q "183a009048050037"; then
    HEX_EDIT "system/system/lib64/libbluetooth_jni.so" \
        "183a009048050037" "183a00902a000014"
elif xxd -p -c 0 "$WORKSPACE/system/system/lib64/libbluetooth_jni.so" | grep -q "88f6713948050037"; then
    HEX_EDIT "system/system/lib64/libbluetooth_jni.so" \
        "88f6713948050037" "88f671392a000014"
elif xxd -p -c 0 "$WORKSPACE/system/system/lib64/libbluetooth_jni.so" | grep -q "2897663948050037"; then
    HEX_EDIT "system/system/lib64/libbluetooth_jni.so" \
        "2897663948050037" "289766392a000014"
else
    ERROR_EXIT "No known patch available for the supplied libbluetooth_jni.so"
fi
