Pod::Spec.new do |spec|
  spec.name         = "LBAnnularPieView"
  spec.version      = "1.0.0"
  spec.summary      = "环形比例图"
  spec.description  = "一个支持动画的环形比例图，带引线文字标注。"
  spec.homepage     = "https://github.com/A1129434577/LBAnnularPieView"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "刘彬" => "1129434577@qq.com" }
  spec.platform     = :ios
  spec.ios.deployment_target = '8.0'
  spec.source       = { :git => 'https://github.com/A1129434577/LBAnnularPieView.git', :tag => spec.version.to_s }
  spec.source_files = "LBAnnularPieView/**/*.{h,m}"
  spec.requires_arc = true
end
