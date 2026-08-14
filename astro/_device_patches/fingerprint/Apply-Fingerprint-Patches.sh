if [ "$DEVICE_FINGERPRINT_SENSOR_TYPE" == "capacitive_powerkey_phone" ]; then

LOG_BEGIN "Adding side fingerprint support"
    ADD_FROM_FW "a17" "system" "priv-app/BiometricSetting"
    
    ADD_PATCH "framework.jar" \
        "$SCRPATH/patches/framework.jar/Add-Side-Fingerprint-Support.sh"
    ADD_PATCH "services.jar" \
        "$SCRPATH/patches/services.jar/Add-Side-Fingerprint-Support.sh"
LOG_END

fi