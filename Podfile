source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!
#json格式处理
pod 'SwiftyJSON’
#网络
pod 'Alamofire’
#json对象映射
pod 'ObjectMapper’
pod 'AlamofireObjectMapper'
#加密类
#pod 'CryptoSwift’
#jwt加密传输
pod 'JSONWebToken’
#动态效果框架
pod 'IBAnimatable’
#照片获取
pod 'ImagePickerSheetController’
#sqlist数据库操作
pod 'SwiftyDB'
#Mob产品公共库
pod 'MOBFoundation_IDFA'
#SMSSDK必须
pod 'SMSSDK'
#网络图片获取及缓存
pod 'HanekeSwift'
#pod 'Gifu'
#视频播放
pod 'VideoSplashKit'
#IMCHAT
pod 'RongCloudIMKit', '2.4.11'
#响应编程
pod 'RxSwift'
pod 'RxCocoa'
pod 'RxBlocking'
pod 'RxAlamofire'
#引导
pod 'Instructions'
pod 'PageMenu'

post_install do |installer|
    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
        configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    end
end
