LOG "- Patching a52q firmware with m51 device tree"

LOG_BEGIN "- Cleaning up a52q-specific proprietary blobs"

LOG_BEGIN "- Removing a52q init script, qdcm calib and lux mapping"
REMOVE "vendor" "etc/init/hw/init.a52q.rc"
REMOVE "vendor" "etc/ev_lux_map_config.xml"
REMOVE "vendor" "etc/qdcm_calib_data_ss_dsi_panel_S6E3FC3_AMS646YD04_FHD.xml"
LOG_END

LOG_BEGIN "- Purging audio configuration files"
find "$WORKSPACE/vendor/etc/audconf" -type f 2>/dev/null | sort | while IFS= read -r file; do
  file="${file#"$WORKSPACE/vendor/etc/"}"
  REMOVE "vendor" "etc/$file"
done
LOG_END

LOG_BEGIN "- Purging hyper files"
find "$WORKSPACE/vendor/etc/hyper" -type f 2>/dev/null | sort | while IFS= read -r file; do
  file="${file#"$WORKSPACE/vendor/etc/"}"
  REMOVE "vendor" "etc/$file"
done
LOG_END

LOG_BEGIN "- Purging perf files"
find "$WORKSPACE/vendor/etc/perf" -type f 2>/dev/null | sort | while IFS= read -r file; do
  file="${file#"$WORKSPACE/vendor/etc/"}"
  REMOVE "vendor" "etc/$file"
done
LOG_END

LOG_BEGIN "- Purging sensor configuration files"
find "$WORKSPACE/vendor/etc/sensors" -type f 2>/dev/null | sort | while IFS= read -r file; do
  file="${file#"$WORKSPACE/vendor/etc/"}"
  REMOVE "vendor" "etc/$file"
done
LOG_END

LOG_BEGIN "- Purging VslMesDetector"
find "$WORKSPACE/vendor/etc/VslMesDetector" -type f 2>/dev/null | sort | while IFS= read -r file; do
  file="${file#"$WORKSPACE/vendor/etc/"}"
  REMOVE "vendor" "etc/$file"
done
LOG_END

LOG_BEGIN "- Stripping camera libraries"
find "$WORKSPACE/vendor" -type f -path '*/lib*/camera/*' 2>/dev/null | sort | while IFS= read -r file; do
  file="${file#"$WORKSPACE/vendor/"}"
  REMOVE "vendor" "$file"
done
LOG_END

LOG_END 

LOG_BEGIN "- Overriding a52q properties with m51 values"
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
BPROP_FW "product" "ro.product.product.name" "m51nsxx"
LOG_END

LOG_BEGIN "- Applying hex patches for atoll -> sm6150"
find "$WORKSPACE/vendor" -type f -name '*atoll*' -print0 2>/dev/null |
while IFS= read -r -d '' f; do
  HEX_EDIT "${f#$WORKSPACE/}" "61746F6C6C2E736F00" "736D363135302E736F"
  mv -- "$f" "${f//atoll/sm6150}" 2>/dev/null
done
LOG_END

LOG_BEGIN "- Replacing a52q-specific strings with m51"
sed -i -e 's|sm7125|sm7150|g' -e 's|a52q|m51|g' -e 's|A52|M51|g' "$WORKSPACE/vendor/etc/floating_feature.xml"
sed -i 's|a52q|m51|g' "$WORKSPACE/vendor/etc/sensorhub_services.json"
sed -i 's|A52|M51|g' "$WORKSPACE/vendor/etc/selinux/vendor_sepolicy_version"
sed -i 's|atoll|sm6150|g' "$WORKSPACE/vendor/etc/vramdiskd.xml"
LOG_END

LOG_BEGIN "- Injecting m51-specific blobs"
git clone https://github.com/mehedihjoy0/M51-Device-Tree $SCRPATH/tree
cp -r "$SCRPATH/tree/system/"* "$WORKSPACE/system/system"
cp -r "$SCRPATH/tree/system/"* "$STOCK_FW/system/system"
cp -r "$SCRPATH/tree/vendor/"* "$WORKSPACE/vendor"
cp -r "$SCRPATH/tree/vendor/"* "$STOCK_FW/vendor"
rm -rf "$SCRPATH/tree"
LOG_END

LOG "- M51IFY has been completed successfully"
