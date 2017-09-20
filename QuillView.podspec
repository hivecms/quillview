Pod::Spec.new do |s|
  s.name             = "QuillView"
  s.version          = "0.1.0"
  s.summary          = "Display quill format on iOS native views."

  s.description      = <<-DESC
                        Display quill format on iOS native views.
                       DESC

  s.homepage         = "http://github.com/hivecms/QuillView"
  s.license          = { :type => 'Apache 2.0', :file => 'QuillView/LICENSE' }
  s.author           = { "LIN" => "linyize@gmail.com" }
  s.source           = { :git => "http://github.com/hivecms/QuillView.git", :tag => "#{s.version}" }

  s.ios.deployment_target = '8.0'
  s.source_files = "QuillView/*.{h,m}"

  s.dependency "Masonry"
  s.dependency "SDWebImage"
  s.dependency "SDWebImage/GIF"
end