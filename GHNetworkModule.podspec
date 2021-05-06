#
# Be sure to run `pod lib lint GHNetworkModule.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GHNetworkModule'
  s.version          = '1.1.5'
  s.summary          = 'AF二次封装'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  组件简介：
  基于AFN的二次封装网络组件.
  增加缓存功能
  由于服务器对post方法中， methodPath后面的斜杆不能去掉， 所以修改了GHNetworkRequest 42行代码
  修改了GHNetworkResponse。116行，原因是服务器修改了http返回的成功code，导致这边直接走失败的提示，但是失败的提示不正确
  增加了网络判断， 在发送消息的时候，如果启动的网络监听， 则判断网络， 如果没有启动， 不判断
  增加TaskId的判断
  修改了cache的保存
  修改了图片的上传
  增加了Token的判断cd

                       DESC

  s.homepage         = 'http://gitea.gosund.com:3000/GHGroup/GHNetworkModule'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Qincc' => '418891087@qq.com' }
  s.source           = { :git => 'http://gitea.gosund.com:3000/GHGroup/GHNetworkModule.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'GHNetworkModule/Classes/**/*'
  
  # s.resource_bundles = {
  #   'GHNetworkModule' => ['GHNetworkModule/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
    s.dependency 'AFNetworking'
    s.dependency 'YYCache'
end
