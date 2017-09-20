Pod::Spec.new do |s|
  s.name             = "CSSParser"
  s.version          = "0.1.0"
  s.summary          = "CSSParser."

  s.description      = <<-DESC
                        CSSParser.
                       DESC

  s.homepage         = "http://www.bee-framework.com"
  s.license          = { :type => 'MIT', :file => 'CSSParser/LICENSE.md' }
  s.author           = { "gavinkwoe" => "gavinkwoe@gmail.com" }
  s.source           = { :git => "http://github.com/hivecms/QuillView.git", :tag => "#{s.version}" }

  s.ios.deployment_target = '8.0'
  s.source_files = "CSSParser/**/*.{h,m}"
  s.requires_arc    = false
end