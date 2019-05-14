install! 'cocoapods', :deterministic_uuids => false
source 'https://github.com/CocoaPods/Specs.git'

# Uncomment this line to define a global platform for your project
platform :ios, '11.0'

# ignore all warnings from all pods
inhibit_all_warnings!

# 모든 target 에서 사용할 공용 dependency 선언
def shared_pods
    use_frameworks!
    # RX Core
    pod 'RxSwift', '~> 4.4.2'
    pod 'RxCocoa', '~> 4.4.2'
    pod 'RxSwiftExt', '~> 3.4.0'
    pod 'RxDataSources', '~> 3.1.0'
    pod 'SnapKit', '~> 4.2.0'
    pod 'Cosmos'
end

# 각 target 별 dependency 선언
target 'SearchAppstore' do
    shared_pods
end

target 'SearchAppstoreTests' do
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        swift_version = '4.2'
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = swift_version
        end
    end
end
