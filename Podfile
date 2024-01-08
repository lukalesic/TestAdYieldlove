# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'TestAdYieldlove' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TestAdYieldlove
  pod 'YieldloveAdIntegration', '~> 9.5.0'
  pod 'YieldloveConsent', '~> 6.0.1'
  
  post_install do |installer|
      installer.generated_projects.each do |project|
          project.targets.each do |target|
                 target.build_configurations.each do |config|
                     config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
     config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
                   end
               end
           end
       end

end
