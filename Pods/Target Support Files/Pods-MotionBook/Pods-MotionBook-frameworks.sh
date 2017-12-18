#!/bin/sh
set -e

echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

SWIFT_STDLIB_PATH="${DT_TOOLCHAIN_DIR}/usr/lib/swift/${PLATFORM_NAME}"

# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

install_framework()
{
  if [ -r "${BUILT_PRODUCTS_DIR}/$1" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$1"
  elif [ -r "${BUILT_PRODUCTS_DIR}/$(basename "$1")" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$(basename "$1")"
  elif [ -r "$1" ]; then
    local source="$1"
  fi

  local destination="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

  if [ -L "${source}" ]; then
      echo "Symlinked..."
      source="$(readlink "${source}")"
  fi

  # Use filter instead of exclude so missing patterns don't throw errors.
  echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" --filter \"- Headers\" --filter \"- PrivateHeaders\" --filter \"- Modules\" \"${source}\" \"${destination}\""
  rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${source}" "${destination}"

  local basename
  basename="$(basename -s .framework "$1")"
  binary="${destination}/${basename}.framework/${basename}"
  if ! [ -r "$binary" ]; then
    binary="${destination}/${basename}"
  fi

  # Strip invalid architectures so "fat" simulator / device frameworks work on device
  if [[ "$(file "$binary")" == *"dynamically linked shared library"* ]]; then
    strip_invalid_archs "$binary"
  fi

  # Resign the code if required by the build settings to avoid unstable apps
  code_sign_if_enabled "${destination}/$(basename "$1")"

  # Embed linked Swift runtime libraries. No longer necessary as of Xcode 7.
  if [ "${XCODE_VERSION_MAJOR}" -lt 7 ]; then
    local swift_runtime_libs
    swift_runtime_libs=$(xcrun otool -LX "$binary" | grep --color=never @rpath/libswift | sed -E s/@rpath\\/\(.+dylib\).*/\\1/g | uniq -u  && exit ${PIPESTATUS[0]})
    for lib in $swift_runtime_libs; do
      echo "rsync -auv \"${SWIFT_STDLIB_PATH}/${lib}\" \"${destination}\""
      rsync -auv "${SWIFT_STDLIB_PATH}/${lib}" "${destination}"
      code_sign_if_enabled "${destination}/${lib}"
    done
  fi
}

# Copies the dSYM of a vendored framework
install_dsym() {
  local source="$1"
  if [ -r "$source" ]; then
    echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" --filter \"- Headers\" --filter \"- PrivateHeaders\" --filter \"- Modules\" \"${source}\" \"${DWARF_DSYM_FOLDER_PATH}\""
    rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${source}" "${DWARF_DSYM_FOLDER_PATH}"
  fi
}

# Signs a framework with the provided identity
code_sign_if_enabled() {
  if [ -n "${EXPANDED_CODE_SIGN_IDENTITY}" -a "${CODE_SIGNING_REQUIRED}" != "NO" -a "${CODE_SIGNING_ALLOWED}" != "NO" ]; then
    # Use the current code_sign_identitiy
    echo "Code Signing $1 with Identity ${EXPANDED_CODE_SIGN_IDENTITY_NAME}"
    local code_sign_cmd="/usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} ${OTHER_CODE_SIGN_FLAGS} --preserve-metadata=identifier,entitlements '$1'"

    if [ "${COCOAPODS_PARALLEL_CODE_SIGN}" == "true" ]; then
      code_sign_cmd="$code_sign_cmd &"
    fi
    echo "$code_sign_cmd"
    eval "$code_sign_cmd"
  fi
}

# Strip invalid architectures
strip_invalid_archs() {
  binary="$1"
  # Get architectures for current file
  archs="$(lipo -info "$binary" | rev | cut -d ':' -f1 | rev)"
  stripped=""
  for arch in $archs; do
    if ! [[ "${ARCHS}" == *"$arch"* ]]; then
      # Strip non-valid architectures in-place
      lipo -remove "$arch" -output "$binary" "$binary" || exit 1
      stripped="$stripped $arch"
    fi
  done
  if [[ "$stripped" ]]; then
    echo "Stripped $binary of architectures:$stripped"
  fi
}


if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_framework "${BUILT_PRODUCTS_DIR}/Alamofire/Alamofire.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AnimatedCollectionViewLayout/AnimatedCollectionViewLayout.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AppUpdater/AppUpdater.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/CRToast/CRToast.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Carte/Carte.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Cartography/Cartography.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ChameleonFramework/ChameleonFramework.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/CircleMenu/CircleMenu.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Device/Device.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FLAnimatedImage/FLAnimatedImage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleToolboxForMac/GoogleToolboxForMac.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GuillotineMenu/GuillotineMenu.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Hero/Hero.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Highlighter/Highlighter.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Hue/Hue.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/JTMaterialTransition/JTMaterialTransition.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Koloda/Koloda.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/LTMorphingLabel/LTMorphingLabel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MIBlurPopup/MIBlurPopup.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MXParallaxHeader/MXParallaxHeader.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MarqueeLabel/MarqueeLabel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/NVActivityIndicatorView/NVActivityIndicatorView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/NotificationBannerSwift/NotificationBannerSwift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Pages/Pages.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Pastel/Pastel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PickColor/PickColor.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PopupDialog/PopupDialog.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Presentation/Presentation.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PreviewTransition/PreviewTransition.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Protobuf/Protobuf.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/RAMAnimatedTabBarController/RAMAnimatedTabBarController.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/RQShineLabel/RQShineLabel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Realm/Realm.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/RealmSwift/RealmSwift.framework"
  install_framework "${PODS_ROOT}/Reveal-SDK/RevealServer-13/iOS/RevealServer.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SDWebImage/SDWebImage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SideMenu/SideMenu.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SnapKit/SnapKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Spring/Spring.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftyAttributes/SwiftyAttributes.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftyJSON/SwiftyJSON.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftyStoreKit/SwiftyStoreKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/TKRubberPageControl/TKRubberPageControl.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/YNDropDownMenu/YNDropDownMenu.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/YNExpandableCell/YNExpandableCell.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ZCAnimatedLabel/ZCAnimatedLabel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/expanding-collection/expanding_collection.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/nanopb/nanopb.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/pop/pop.framework"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_framework "${BUILT_PRODUCTS_DIR}/Alamofire/Alamofire.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AnimatedCollectionViewLayout/AnimatedCollectionViewLayout.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AppUpdater/AppUpdater.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/CRToast/CRToast.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Carte/Carte.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Cartography/Cartography.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ChameleonFramework/ChameleonFramework.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/CircleMenu/CircleMenu.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Device/Device.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FLAnimatedImage/FLAnimatedImage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleToolboxForMac/GoogleToolboxForMac.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GuillotineMenu/GuillotineMenu.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Hero/Hero.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Highlighter/Highlighter.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Hue/Hue.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/JTMaterialTransition/JTMaterialTransition.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Koloda/Koloda.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/LTMorphingLabel/LTMorphingLabel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MIBlurPopup/MIBlurPopup.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MXParallaxHeader/MXParallaxHeader.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MarqueeLabel/MarqueeLabel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/NVActivityIndicatorView/NVActivityIndicatorView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/NotificationBannerSwift/NotificationBannerSwift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Pages/Pages.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Pastel/Pastel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PickColor/PickColor.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PopupDialog/PopupDialog.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Presentation/Presentation.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PreviewTransition/PreviewTransition.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Protobuf/Protobuf.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/RAMAnimatedTabBarController/RAMAnimatedTabBarController.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/RQShineLabel/RQShineLabel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Realm/Realm.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/RealmSwift/RealmSwift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SDWebImage/SDWebImage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SideMenu/SideMenu.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SnapKit/SnapKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Spring/Spring.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftyAttributes/SwiftyAttributes.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftyJSON/SwiftyJSON.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftyStoreKit/SwiftyStoreKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/TKRubberPageControl/TKRubberPageControl.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/YNDropDownMenu/YNDropDownMenu.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/YNExpandableCell/YNExpandableCell.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ZCAnimatedLabel/ZCAnimatedLabel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/expanding-collection/expanding_collection.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/nanopb/nanopb.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/pop/pop.framework"
fi
if [ "${COCOAPODS_PARALLEL_CODE_SIGN}" == "true" ]; then
  wait
fi
