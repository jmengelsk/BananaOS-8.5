LOG "- Patching a52q firmware with m51 device tree"

LOG_BEGIN "- Removing a52q specific vendor blobs"

LOG_BEGIN "- Removing init, soundbooster, audconf"
REMOVE "vendor" "etc/init/hw/init.a52q.rc"
REMOVE "system" "lib/lib_SoundBooster_ver1050.so"
REMOVE "system" "lib64/lib_SoundBooster_ver1050.so"
REMOVE "vendor" "lib/lib_SoundBooster_ver1050.so"
REMOVE "vendor" "lib64/lib_SoundBooster_ver1050.so"
REMOVE "vendor" "lib/hw/audio.primary.atoll.so"
REMOVE "vendor" "etc/audconf/ODM"
LOG_END

LOG_BEGIN "- Removing sensor blobs"
REMOVAL_LIST="$(cd "$WORKSPACE/vendor/etc" 2>/dev/null && find sensors -type f -print 2>/dev/null | sort || true)"
while IFS= read -r file; do 
    [ -z "$file" ] && continue
    [ ! -f "$SCRPATH/vendor/etc/$file" ] && REMOVE "vendor" "etc/$file"
done <<< "$REMOVAL_LIST"
LOG_END

LOG_BEGIN "- Removing camera libraries"
REMOVAL_LIST="$(find "$WORKSPACE/vendor" -type f -path '*/lib*/camera/*' -printf '%P\n' 2>/dev/null | sort || true)"
while IFS= read -r file; do 
    [ -z "$file" ] && continue
    [ ! -f "$SCRPATH/vendor/$file" ] && REMOVE "vendor" "$file"
done <<< "$REMOVAL_LIST"
LOG_END

LOG_END 

LOG_BEGIN "- Patching a52q properties with m51"
BPROP_FW "system" "ro.factory.model" "SM-M515F"
BPROP_FW "system" "ro.build.flavor" "m51nsxx-user"
BPROP_FW "product" "ro.product.product.name" "m51nsxx"
BPROP_FW "vendor" "ro.product.board" "sm6150"
BPROP_FW "vendor" "ro.board.platform" "sm6150"
BPROP_FW "vendor" "ro.hardware.chipname" "SM7150"
BPROP_FW "vendor" "ro.soc.model" "SM7150"
BPROP_FW "vendor" "ro.vendor.build.fingerprint" "samsung/m51nsxx/m51:11/RP1A.200720.012/M515FXXS6DXE4:user/release-keys"
BPROP_FW "vendor" "ro.vendor.build.version.incremental" "M515FXXS6DXE4"
BPROP_FW "vendor" "ro.product.vendor.device" "m51"
BPROP_FW "vendor" "ro.product.vendor.model" "SM-M515F"
BPROP_FW "vendor" "ro.product.vendor.name" "m51nsxx"
BPROP_FW "vendor" "ro.netflix.bsp_rev" "Q7250-19133-1"
BPROP_FW "vendor" "ro.bootimage.build.fingerprint" "samsung/m51nsxx/m51:11/RP1A.200720.012/M515FXXS6DXE4:user/release-keys"
BPROP_FW "odm" "ro.odm.build.fingerprint" "samsung/m51nsxx/m51:11/RP1A.200720.012/M515FXXS6DXE4:user/release-keys"
BPROP_FW "odm" "ro.odm.build.version.incremental" "M515FXXS6DXE4"
BPROP_FW "odm" "ro.product.odm.device" "m51"
BPROP_FW "odm" "ro.product.odm.model" "SM-M515F"
BPROP_FW "odm" "ro.product.odm.name" "m51nsxx"
LOG_END

LOG_BEGIN "- Running hex patches for atoll -> sm6150"
find "$WORKSPACE/vendor" -type f -name '*atoll*' -print0 2>/dev/null |
while IFS= read -r -d '' f; do
  HEX_EDIT "${f#$WORKSPACE/}" "61746F6C6C2E736F00" "736D363135302E736F"
  mv -- "$f" "${f//atoll/sm6150}" 2>/dev/null
done
LOG_END

LOG_BEGIN "- Replacing a52q props with m51"
sed -i -e 's|sm7125|sm7150|g' -e 's|a52q|m51|g' -e 's|A52|M51|g' "$WORKSPACE/vendor/etc/floating_feature.xml"
sed -i 's|a52q|m51|g' "$WORKSPACE/vendor/etc/ev_lux_map_config.xml" "$WORKSPACE/vendor/etc/sensorhub_services.json"
sed -i 's|A52|M51|g' "$WORKSPACE/vendor/etc/selinux/vendor_sepolicy_version"
sed -i 's|atoll|sm6150|g' "$WORKSPACE/vendor/etc/vramdiskd.xml"
LOG_END

LOG_BEGIN "- Replacing media profiles into odm with vendor"
cp -r "$WORKSPACE/vendor/etc/media_profiles_V1_0.xml" "$WORKSPACE/odm/etc"
LOG_END

LOG_BEGIN "- Replacing a52q blobs with m51"
git clone https://github.com/mehedihjoy0/M51-Device-Tree $SCRPATH/tree
cp -r "$SCRPATH/tree/system/"* "$WORKSPACE/system/system"
cp -r "$SCRPATH/tree/system/"* "$STOCK_FW/system/system"
cp -r "$SCRPATH/tree/vendor/"* "$WORKSPACE/vendor"
cp -r "$SCRPATH/tree/vendor/"* "$STOCK_FW/vendor"
rm -rf "$SCRPATH/tree"
LOG_END

LOG_BEGIN "- Replacing csc partitions with $DEVICE_MODEL"
find "$WORKSPACE/optics" -type f -exec \
sed -i -E "s/SM-[A-Z0-9]+/$DEVICE_MODEL/g" {} +
find "$WORKSPACE/prism" -type f -exec \
sed -i -E "s/SM-[A-Z0-9]+/$DEVICE_MODEL/g" {} +
sed -i 's/.*/M515FOXM6DXE4/' "$WORKSPACE/prism/etc/CSCVersion.txt"
xmlstarlet ed -L -u "//CSCName" -v "M515FOXM" "$WORKSPACE/prism/etc/SW_Configuration.xml"
xmlstarlet ed -L -u "//CSCVersion" -v "6DXE4" "$WORKSPACE/prism/etc/SW_Configuration.xml"
LOG_END

LOG "- M51IFY has been completed successfully"