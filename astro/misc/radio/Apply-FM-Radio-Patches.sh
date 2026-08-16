if [ -e "$STOCK_FW/system/system/priv-app/HybridRadio" ]; then
    ADD_PATCH "HybridRadio.apk" \
        "$SCRPATH/HybridRadio.apk/Spoof-Model.sh"
fi