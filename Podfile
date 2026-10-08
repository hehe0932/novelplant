# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

# trunk CDN 的 podspec 最终都 302 到被阻断的 raw.githubusercontent.com，改走清华镜像
source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

#忽略所有三方库警告⚠️
inhibit_all_warnings!

target 'novelplant' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Alamofire'
  pod 'MJRefresh'
  pod 'JXSegmentedView','1.3.3'
  pod 'JXPagingView/Paging'
  pod 'Moya'
  pod 'IQKeyboardManagerSwift'
  pod 'RealmSwift'
  pod 'Kingfisher'
  pod 'SnapKit'
  pod 'KakaJSON'
  pod 'AvoidCrash'
  pod 'YYText'
  pod 'EmptyDataSet-Swift'

end

post_install do |installer|
  # 各 pod 的部署目标低于 iOS 11 会触发新 Xcode 链接已删除的 libarclite，统一抬到 15.0
  installer.pods_project.targets.each do |t|
    t.build_configurations.each do |c|
      c.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
