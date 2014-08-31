platform :ios, '7.1'

inhibit_all_warnings!

pod 'AFNetworking', '~> 2.0'
pod 'MagicalRecord', '~> 2.0'
pod 'CocoaLumberjack'
pod 'PureLayout'
pod 'TPKeyboardAvoiding'
pod 'libextobjc/EXTScope'
pod 'KVOController'
pod 'UIAlertView-Blocks'
pod 'JGProgressHUD'
pod 'ChameleonFramework'
pod 'NSString-Hashes'

post_install do |installer|
  installer.project.targets.each do |target|
    target.build_configurations.each do |config|
      s = config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']
    if s==nil then s = [ '$(inherited)' ] end
    s.push('MR_ENABLE_ACTIVE_RECORD_LOGGING=0');
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = s
    end
  end
end