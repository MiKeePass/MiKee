source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.2'
use_frameworks!

pod 'SwiftLint'

def app_pods
  pod 'KeePassKit', :git => 'https://github.com/maxep/KeePassKit.git', :branch => 'cocoapods', :submodules => true
  pod 'FontAwesome.swift'
  pod 'Navajo'
  pod 'OneTimePassword'
end

def test_pods
  pod 'Quick'
  pod 'Nimble'
end

target 'MiKee' do

  app_pods

  target 'Tests' do
    inherit! :search_paths
    test_pods
  end

  target 'MiKit' do
      inherit! :search_paths
      pod 'KeychainAccess'
  end

  target 'ExtensionKit' do
      inherit! :search_paths
      pod 'KeychainAccess'
  end

  target 'WebExtension' do
      inherit! :search_paths
  end

  target 'AutoFill' do
      inherit! :search_paths
  end

  target 'Resources' do
      pod 'SwiftGen'
  end

end

target 'UITests' do
  inherit! :search_paths
  app_pods
  test_pods
end

target 'Snapshots' do
  inherit! :search_paths
  app_pods
  test_pods
  pod 'SimulatorStatusMagic', :configurations => ['Debug']
end
