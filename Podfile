# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'MasterWords' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MasterWords
    pod 'RealmSwift'
    pod 'SwipeCellKit', '2.5.4'
    #pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git', :branch => 'develop'
    pod 'ChameleonFramework/Swift', :git => 'https://github.com/ykws/Chameleon.git', :branch => 'develop'
    pod 'Koloda', '~> 5.0'
    pod 'MaterialShowcase'
    pod 'SCLAlertView'
    pod 'Charts'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.name == 'Debug'
        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
  end
end
