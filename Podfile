# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'ReactiveArchitecture' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ReactiveArchitecture
  
  ##Dependency Injection
  pod 'Dip'
  pod 'Dip-UI'

  ##Rx
  pod 'RxSwift', '~> 4.0'
  pod 'RxCocoa', '~> 4.0'

  #Networking
  pod 'Alamofire', '~> 4.5.1'
  pod 'RxAlamofire'
  pod 'AlamofireObjectMapper', '~> 5.0'

  #Logging
  pod 'CocoaLumberjack/Swift' 

  target 'ReactiveArchitectureTests' do
    inherit! :search_paths
    # Pods from project (Yes this is needed)
    pod 'Alamofire', '~> 4.5.1'
    pod 'RxAlamofire'
    pod 'AlamofireObjectMapper', '~> 5.0'
    pod 'CocoaLumberjack/Swift' 
    
    # Pods for testing
    pod 'RxBlocking', '~> 4.0'
    pod 'RxTest', '~> 4.0'
    pod 'SwiftHamcrest', '~> 1.0.0'
  end

  target 'ReactiveArchitectureUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
