Pod::Spec.new do |s|
  s.name         = "STDPickerView"
  s.version      = "0.1.0"
  s.summary      = "STDPickerView is a replacement for UIPickerView"

  s.description  = <<-DESC
                      STDPickerView is an complete, easy-to-use picker view framework.It can be a replacement for UIPickerView.
                      DESC

  s.homepage     = "https://github.com/XuQibin/STDPickerView"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "XuQibin" => "scrat_xu@163.com" }
  # s.social_media_url   = "http://twitter.com/"

  s.platform     = :ios, "8.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/XuQibin/STDPickerView.git", :tag => "#{s.version}" }

  s.source_files  = "STDPickerView/Classes/STDPickerView/*.{h,m}"
  # s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
