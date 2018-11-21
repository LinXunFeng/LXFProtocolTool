#
# Be sure to run `pod lib lint LXFProtocolTool.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LXFProtocolTool'
  s.version          = '1.1.1'
  s.summary          = 'LXFProtocolTool是实用的协议应用工具库'
  s.description      = <<-DESC
LXFProtocolTool是使用Swift中的协议来实现多种方便、实用的工具库
                       DESC
  s.homepage         = 'https://github.com/LinXunFeng/LXFProtocolTool'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'LinXunFeng' => '598600855@qq.com' }
  s.source           = { :git => 'https://github.com/LinXunFeng/LXFProtocolTool.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.swift_version = "4.2"

  s.source_files = 'LXFProtocolTool/Classes/**/*.swift'

  s.subspec "Base" do |t|
      t.source_files  = "LXFProtocolTool/Classes/Base/**/*.{swift}"
  end
  
  s.subspec 'LXFNibloadable' do |t|
      t.source_files = 'LXFProtocolTool/Classes/LXFNibloadable/**/*.{swift}'
  end
  
  s.subspec 'Refreshable' do |t|
      t.source_files = 'LXFProtocolTool/Classes/Refreshable/**/*.{swift}'
      t.dependency 'MJRefresh'
      t.dependency 'RxSwift', '>= 4.0.0'
      t.dependency "LXFProtocolTool/AssociatedObjectStore"
      t.dependency "LXFProtocolTool/Base"
  end

  s.subspec 'EmptyDataSetable' do |t|
      t.source_files = 'LXFProtocolTool/Classes/EmptyDataSetable/**/*.{swift}'
      t.dependency 'DZNEmptyDataSet', '>= 1.8.1'
      t.dependency "LXFProtocolTool/AssociatedObjectStore"
      t.dependency "LXFProtocolTool/Base"
  end
  
  s.subspec 'RxEmptyDataSetable' do |t|
      t.source_files = 'LXFProtocolTool/Classes/RxEmptyDataSetable/**/*.{swift}'
      t.dependency 'RxCocoa', '>= 4.0.0'
      t.dependency "LXFProtocolTool/EmptyDataSetable"
  end
  
  s.subspec 'AssociatedObjectStore' do |t|
      t.source_files = 'LXFProtocolTool/Classes/AssociatedObjectStore/**/*.{swift}'
  end
  
  s.subspec 'FullScreenable' do |t|
      t.source_files = 'LXFProtocolTool/Classes/FullScreenable/**/*.{swift}'
      t.dependency "LXFProtocolTool/AssociatedObjectStore"
      t.dependency "LXFProtocolTool/Base"
  end
end
