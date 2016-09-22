Pod::Spec.new do |s|
  s.name         = "CYScrollView"
  s.version      = "0.0.1"
  s.summary      = "方便使用的循环滚动的scrollview"
  s.description  = "循环滚动scrollview 轮播bannerview"
  s.homepage     = "https://github.com/ginkgocy/CYScrollView"
  s.authors       = { "Yenge" => "cheny@hulabanban.com" }
  s.source       = { :git => "https://github.com/ginkgocy/CYScrollView.git", :tag => "#{s.version}" }
	s.platform     = :ios, '7.0'
	s.ios.deployment_target = '7.0'
  s.source_files = 'CYScrollView/ScrollView/**/*.{h,m}'
  s.requires_arc = true
  s.dependency 'Masonry'
  s.dependency 'SDWebImage'
end