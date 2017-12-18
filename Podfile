# Uncomment the next line to define a global platform for your project

platform :ios, '9.0'
use_frameworks!

def shared_pods
    # Data
    pod 'RealmSwift'
    pod 'Alamofire'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'SwiftyStoreKit'
    pod 'Firebase/Core'
    pod 'Firebase/Messaging'
    pod 'Firebase/DynamicLinks'
    pod 'Device'
    pod 'Carte'
    pod 'AppUpdater'

    # UI
    pod 'SnapKit'
    pod 'SwiftyJSON'
    pod 'LTMorphingLabel'
    pod 'MXParallaxHeader'
    pod 'Highlighter'
    pod 'FLAnimatedImage'
    pod 'SDWebImage'
    pod 'NotificationBannerSwift'
    pod 'SwiftyAttributes'
    pod 'Reveal-SDK', :configurations => ['Debug']
    pod 'PickColor'
    pod 'Presentation'
    pod 'Hue'

    # Lib Pods
    pod 'expanding-collection'
    pod 'GuillotineMenu'
    pod 'NVActivityIndicatorView'
    pod 'CRToast'
    pod 'Hero'
    pod 'ZCAnimatedLabel'
    pod 'ChameleonFramework'
    pod 'YNDropDownMenu'
    pod 'YNExpandableCell'
    pod 'CircleMenu'
    pod 'SideMenu'
    pod 'RAMAnimatedTabBarController'
    pod 'Pastel'
    pod 'JTMaterialTransition'
    pod 'AnimatedCollectionViewLayout'
    pod 'PreviewTransition'
    pod 'Koloda'
    pod 'TKRubberPageControl'
    pod 'PopupDialog'
    pod 'MIBlurPopup'
    pod 'Spring'
    pod 'RQShineLabel'
    
end

target ‘MotionBook’ do
    shared_pods
    
    post_install do |installer|
        pods_dir = File.dirname(installer.pods_project.path)
        at_exit { `ruby #{pods_dir}/Carte/Sources/Carte/carte.rb configure` }
    end
end
