
Pod::Spec.new do |s|

  s.name         = "SYMoireView"
  s.version      = "1.0.0"
  s.summary      = "SYMoireView is show a moire wave view"
  s.homepage     = "https://github.com/Call-me-Simon/SYMoireView"

  s.license      = "MIT"
  s.author             = { "Simon" => "348400564@qq.com" }
  s.source       = { :git => "https://github.com/Call-me-Simon/SYMoireView.git", :tag => "#{s.version}" }  
  s.requires_arc = true
  s.ios.deployment_target = "8.0"

  s.source_files  = "SYMoireView/*.{h,m}"

end
