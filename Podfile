# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'RapSheet' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for RapSheet
	pod 'SWRevealViewController'
  pod 'AFNetworking'
  pod 'SwiftyJSON', '~> 4.0'
#  pod 'SkyFloatingLabelTextField', '~> 3.0'
  pod 'HCSStarRatingView'
  pod 'IQKeyboardManager'
  pod 'SVProgressHUD'
  pod 'Google-Mobile-Ads-SDK'
  pod 'DropDown'
  pod 'MBProgressHUD'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'SDWebImage'
  pod 'Alamofire'
  pod 'Toast-Swift'
  pod 'KeychainAccess'
  pod 'UITextView+Placeholder'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Mixpanel-swift'
  
  #pod 'UIFloatLabelTextView'
  # Pods for RapSheet
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end

end
